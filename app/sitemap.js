import { LEGAL_UPDATED, SITE_URL } from '@/lib/site';

export default function sitemap() {
    const stamp = new Date(LEGAL_UPDATED + 'T00:00:00Z');
    return [
        { url: SITE_URL + '/', lastModified: new Date(), changeFrequency: 'daily', priority: 1 },
        { url: SITE_URL + '/methodology', lastModified: stamp, changeFrequency: 'monthly', priority: 0.5 },
        { url: SITE_URL + '/privacy', lastModified: stamp, changeFrequency: 'monthly', priority: 0.3 },
        { url: SITE_URL + '/terms', lastModified: stamp, changeFrequency: 'monthly', priority: 0.3 }
    ];
}
