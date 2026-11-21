import connect from '@/lib/db';
import Report from '@/models/Report';
import { matchSource, theaterOf } from '@/lib/news/engine';
import { createLimiter } from '@/lib/rate-limit';
import { isReportSlug, reportSlug, urlHash } from '@/lib/slug';
import { buildMaterial } from '@/lib/overview/prompt';
import { generateOverview, overviewConfig } from '@/lib/overview/generate';
import { THEATERS, isTheater } from '@/content/theaters';

const DAY_MS = 24 * 60 * 60 * 1000;
const QUEUE_KEY = Symbol.for('vero.overview.queue');
const upsertLimiter = createLimiter({ limit: 3000, windowMs: DAY_MS, maxKeys: 4 });

function queueState() {
    if (!globalThis[QUEUE_KEY]) globalThis[QUEUE_KEY] = { running: false, pending: [], queued: new Set() };
    return globalThis[QUEUE_KEY];
}

export function slugFor(item) {
    return reportSlug(item.title, item.url);
}

export async function rememberItems(items, { theater } = {}) {
    if (!Array.isArray(items) || !items.length) return;
    if (!(await connect())) return;
    const now = new Date();
    const ops = [];
    for (const it of items.slice(0, 40)) {
        if (!it || it.web || typeof it.url !== 'string' || typeof it.title !== 'string') continue;
        if (!/^https?:\/\//.test(it.url) || it.url.length > 1500) continue;
        const source = matchSource(it.url);
        if (!source) continue;
        const published = new Date(it.publishedAt);
        if (Number.isNaN(published.getTime())) continue;
        if (!upsertLimiter.check('global').ok) break;
        const found = theater || theaterOf(it.title, it.description) || '';
        ops.push({
            updateOne: {
                filter: { slug: slugFor(it) },
                update: {
                    $setOnInsert: {
                        urlHash: urlHash(it.url),
                        url: it.url,
                        title: it.title.slice(0, 300),
                        description: String(it.description || '').slice(0, 400),
                        source: source.name,
                        sourceRegion: source.region,
                        image: typeof it.image === 'string' && /^https?:\/\//.test(it.image) ? it.image.slice(0, 1000) : '',
                        publishedAt: published,
                        theater: found,
                        category: typeof it.cat === 'string' ? it.cat.slice(0, 24) : 'intel',
                        lang: typeof it.lang === 'string' ? it.lang.slice(0, 8) : 'en',
                        firstSeenAt: now
                    },
                    $set: { lastSeenAt: now }
                },
                upsert: true
            }
        });
    }
    if (ops.length) await Report.bulkWrite(ops, { ordered: false }).catch(() => null);
}

export async function getReport(slug) {
    if (!isReportSlug(slug)) return null;
    if (!(await connect())) return null;
    return Report.findOne({ slug }).lean().catch(() => null);
}

export async function relatedReports(doc, limit = 4) {
    if (!(await connect())) return [];
    const filter = { slug: { $ne: doc.slug }, 'overview.generatedAt': { $exists: true } };
    if (doc.theater) filter.theater = doc.theater;
    return Report.find(filter).sort({ publishedAt: -1 }).limit(limit).lean().catch(() => []);
}

export async function theaterReports(theater, limit = 12) {
    if (!isTheater(theater) || !(await connect())) return [];
    return Report.find({ theater, 'overview.generatedAt': { $exists: true } }).sort({ publishedAt: -1 }).limit(limit).lean().catch(() => []);
}

export async function latestReports(limit = 6) {
    if (!(await connect())) return [];
    return Report.find({ 'overview.generatedAt': { $exists: true } }).sort({ publishedAt: -1 }).limit(limit).lean().catch(() => []);
}

export async function indexableReports(limit = 2000) {
    if (!(await connect())) return [];
    return Report.find({ 'overview.generatedAt': { $exists: true } }).sort({ publishedAt: -1 }).limit(limit).select('slug publishedAt overview.generatedAt').lean().catch(() => []);
}

async function produce(slug) {
    const config = overviewConfig();
    if (!config || !(await connect())) return;
    const doc = await Report.findOne({ slug }).lean();
    if (!doc || (doc.overview && doc.overview.generatedAt)) return;
    if ((doc.overviewFailures || 0) >= 3) return;
    if (doc.lastTriedAt && Date.now() - new Date(doc.lastTriedAt).getTime() < 30 * 60 * 1000) return;
    const start = new Date();
    start.setUTCHours(0, 0, 0, 0);
    const used = await Report.countDocuments({ 'overview.generatedAt': { $gte: start } });
    if (used >= config.dailyLimit) return;
    await Report.updateOne({ slug }, { $set: { lastTriedAt: new Date() } });
    const theater = doc.theater && isTheater(doc.theater) ? THEATERS[doc.theater] : null;
    const related = doc.theater
        ? await Report.find({ theater: doc.theater, slug: { $ne: slug } }).sort({ publishedAt: -1 }).limit(4).select('title source').lean()
        : [];
    const material = buildMaterial({ report: doc, theater, related });
    const result = await generateOverview(material, config);
    if (result.ok) {
        await Report.updateOne({ slug }, { $set: { overview: { ...result.overview, model: result.model, generatedAt: new Date() } } });
    } else {
        await Report.updateOne({ slug }, { $inc: { overviewFailures: 1 } });
    }
}

async function drain() {
    const state = queueState();
    if (state.running) return;
    state.running = true;
    try {
        while (state.pending.length) {
            const slug = state.pending.shift();
            try {
                await produce(slug);
            } catch {
                continue;
            } finally {
                state.queued.delete(slug);
            }
        }
    } finally {
        state.running = false;
    }
}

export function queueOverview(slug) {
    if (!isReportSlug(slug) || !overviewConfig()) return;
    const state = queueState();
    if (state.queued.has(slug) || state.pending.length >= 60) return;
    state.queued.add(slug);
    state.pending.push(slug);
    drain();
}

export async function overviewMap(slugs) {
    const list = (slugs || []).filter(isReportSlug).slice(0, 60);
    if (!list.length || !(await connect())) return new Map();
    const docs = await Report.find({ slug: { $in: list }, 'overview.generatedAt': { $exists: true } })
        .select('slug overview.title overview.summary')
        .lean()
        .catch(() => []);
    return new Map(docs.map(d => [d.slug, { title: d.overview.title, summary: d.overview.summary }]));
}

export async function ingest(items, { theater, warm = 0 } = {}) {
    const list = (Array.isArray(items) ? items : []).filter(it => it && typeof it.title === 'string' && typeof it.url === 'string');
    const slugs = list.map(slugFor);
    await rememberItems(list, { theater });
    const map = await overviewMap(slugs);
    let queued = 0;
    for (let i = 0; i < list.length && queued < warm; i++) {
        if (list[i].web || !matchSource(list[i].url)) continue;
        if (!map.has(slugs[i])) {
            queueOverview(slugs[i]);
            queued++;
        }
    }
    return map;
}
