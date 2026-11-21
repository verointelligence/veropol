import crypto from 'node:crypto';
import connect from '@/lib/db';
import Article from '@/models/Article';
import { DAILY_LIMIT, articleSlug, isArticleSlug, validateArticle } from '@/lib/articles-core';
import { authorsById } from '@/lib/auth/public';

function view(doc) {
    return {
        id: String(doc._id),
        slug: doc.slug,
        title: doc.title,
        summary: doc.summary,
        body: doc.body,
        category: doc.category,
        authorId: doc.authorId,
        createdAt: doc.createdAt,
        updatedAt: doc.updatedAt || null
    };
}

export async function createArticle(user, input) {
    if (!(await connect())) return { ok: false, reason: 'unavailable' };
    const checked = validateArticle(input);
    if (!checked.ok) return checked;
    const since = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const count = await Article.countDocuments({ authorId: user.id, createdAt: { $gte: since } });
    if (count >= DAILY_LIMIT) return { ok: false, reason: 'daily_limit' };
    if (await Article.exists({ authorId: user.id, title: checked.value.title, createdAt: { $gte: since } })) return { ok: false, reason: 'duplicate' };
    for (let i = 0; i < 3; i++) {
        const slug = articleSlug(checked.value.title, crypto.randomBytes(3).toString('hex'));
        try {
            const doc = await Article.create({ ...checked.value, slug, authorId: user.id });
            return { ok: true, slug: doc.slug };
        } catch (error) {
            if (!error || error.code !== 11000) throw error;
        }
    }
    return { ok: false, reason: 'unavailable' };
}

export async function getArticle(slug) {
    if (!isArticleSlug(slug) || !(await connect())) return null;
    const doc = await Article.findOne({ slug, status: 'published' }).lean().catch(() => null);
    if (!doc) return null;
    const authors = await authorsById([doc.authorId]);
    return { ...view(doc), author: authors.get(doc.authorId) || null };
}

export async function listArticles({ category = '', authorId = '', page = 1, size = 9 } = {}) {
    if (!(await connect())) return { items: [], total: 0, page: 1, totalPages: 1, available: false };
    const filter = { status: 'published' };
    if (category) filter.category = category;
    if (authorId) filter.authorId = authorId;
    const total = await Article.countDocuments(filter).catch(() => 0);
    const totalPages = Math.max(1, Math.ceil(total / size));
    const current = Math.min(Math.max(page, 1), totalPages);
    const docs = await Article.find(filter).sort({ createdAt: -1 }).skip((current - 1) * size).limit(size).select('-body').lean().catch(() => []);
    const authors = await authorsById(docs.map(d => d.authorId));
    return {
        items: docs.map(d => ({ ...view({ ...d, body: '' }), author: authors.get(d.authorId) || null })),
        total,
        page: current,
        totalPages,
        available: true
    };
}

export async function updateArticle(slug, user, input, isAdmin) {
    if (!isArticleSlug(slug) || !(await connect())) return { ok: false, reason: 'not_found' };
    const doc = await Article.findOne({ slug }).lean();
    if (!doc) return { ok: false, reason: 'not_found' };
    if (doc.authorId !== user.id && !isAdmin) return { ok: false, reason: 'forbidden' };
    const checked = validateArticle(input);
    if (!checked.ok) return checked;
    await Article.updateOne({ slug }, { $set: { ...checked.value, updatedAt: new Date() } });
    return { ok: true, slug };
}

export async function deleteArticle(slug, user, isAdmin) {
    if (!isArticleSlug(slug) || !(await connect())) return { ok: false, reason: 'not_found' };
    const doc = await Article.findOne({ slug }).lean();
    if (!doc) return { ok: false, reason: 'not_found' };
    if (doc.authorId !== user.id && !isAdmin) return { ok: false, reason: 'forbidden' };
    await Article.deleteOne({ slug });
    return { ok: true };
}

export async function articleSlugs(limit = 2000) {
    if (!(await connect())) return [];
    return Article.find({ status: 'published' }).sort({ createdAt: -1 }).limit(limit).select('slug createdAt updatedAt').lean().catch(() => []);
}
