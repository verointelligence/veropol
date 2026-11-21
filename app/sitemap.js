import { THEATER_IDS } from '@/content/theaters';
import { indexableReports } from '@/lib/reports';
import { LEGAL_UPDATED, SITE_URL } from '@/lib/site';

export const dynamic = 'force-dynamic';

export default async function sitemap() {
    const stamp = new Date(LEGAL_UPDATED + 'T00:00:00Z');
    const now = new Date();
    const base = [
        { url: SITE_URL + '/', lastModified: now, changeFrequency: 'hourly', priority: 1 },
        { url: SITE_URL + '/live', lastModified: now, changeFrequency: 'hourly', priority: 0.9 },
        { url: SITE_URL + '/explore', lastModified: now, changeFrequency: 'hourly', priority: 0.8 },
        { url: SITE_URL + '/methodology', lastModified: stamp, changeFrequency: 'monthly', priority: 0.5 },
        { url: SITE_URL + '/privacy', lastModified: stamp, changeFrequency: 'monthly', priority: 0.3 },
        { url: SITE_URL + '/terms', lastModified: stamp, changeFrequency: 'monthly', priority: 0.3 }
    ];
    const theaters = THEATER_IDS.map(id => ({ url: SITE_URL + '/live/' + id, lastModified: now, changeFrequency: 'hourly', priority: 0.8 }));
    const reports = (await indexableReports(2000)).map(d => ({
        url: SITE_URL + '/report/' + d.slug,
        lastModified: new Date((d.overview && d.overview.generatedAt) || d.publishedAt),
        changeFrequency: 'weekly',
        priority: 0.6
    }));
    return [...base, ...theaters, ...reports];
}
