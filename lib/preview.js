import { THEATERS } from '@/content/theaters';
import { getEngine } from '@/lib/news/engine';
import { dbReady } from '@/lib/db';
import { ingest } from '@/lib/reports';
import { reportSlug } from '@/lib/slug';

export async function previewRows(limit = 4) {
    const data = await getEngine().theaters();
    const rows = Object.entries(data.theaters)
        .filter(([, t]) => t && t.lead)
        .map(([id, t]) => ({ id, lead: t.lead }))
        .sort((a, b) => new Date(b.lead.publishedAt) - new Date(a.lead.publishedAt))
        .slice(0, limit);
    const linkable = await dbReady();
    const overviews = new Map();
    if (linkable) {
        await Promise.all(rows.map(async row => {
            const map = await ingest([row.lead], { theater: row.id, warm: 1 }).catch(() => new Map());
            map.forEach((v, k) => overviews.set(k, v));
        }));
    }
    return rows.map(row => {
        const slug = reportSlug(row.lead.title, row.lead.url);
        const overview = overviews.get(slug);
        return {
            id: row.id,
            theater: THEATERS[row.id] ? THEATERS[row.id].title : '',
            title: overview ? overview.title : row.lead.title,
            source: row.lead.source || '',
            publishedAt: new Date(row.lead.publishedAt).toISOString(),
            href: linkable ? '/report/' + slug : row.lead.url,
            external: !linkable
        };
    });
}
