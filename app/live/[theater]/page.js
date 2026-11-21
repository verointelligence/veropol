import Link from 'next/link';
import { notFound } from 'next/navigation';
import ReportCard from '@/components/ReportCard';
import { THEATERS, isTheater } from '@/content/theaters';
import { getEngine } from '@/lib/news/engine';
import { ingest, theaterReports } from '@/lib/reports';
import { reportSlug } from '@/lib/slug';
import { jsonLd } from '@/lib/format';
import { SITE_URL } from '@/lib/site';

export const dynamic = 'force-dynamic';

export async function generateMetadata({ params }) {
    const { theater } = await params;
    if (!isTheater(theater)) return { title: 'Not found', robots: { index: false, follow: false } };
    const t = THEATERS[theater];
    return {
        title: t.title + ': live reports and overviews',
        description: t.desc + ' Live reports from vetted newsrooms with VERO overviews.',
        alternates: { canonical: '/live/' + theater },
        openGraph: { title: t.title + ' | VERO', description: t.desc, url: '/live/' + theater, type: 'website' }
    };
}

export default async function TheaterPage({ params }) {
    const { theater } = await params;
    if (!isTheater(theater)) notFound();
    const t = THEATERS[theater];
    let articles = [];
    try {
        const result = await getEngine().search({ q: t.query, category: 'all', range: '7d', page: 1, size: 12, uiLang: 'en', detect: false, client: null });
        articles = result.articles || [];
    } catch {
        articles = [];
    }
    const overviews = await ingest(articles, { theater, warm: 3 }).catch(() => new Map());
    const archive = await theaterReports(theater, 9);
    const shown = new Set(articles.map(a => reportSlug(a.title, a.url)));
    const earlier = archive.filter(d => !shown.has(d.slug));

    const graph = {
        '@context': 'https://schema.org',
        '@type': 'CollectionPage',
        name: t.title,
        description: t.desc,
        url: SITE_URL + '/live/' + theater,
        isPartOf: { '@type': 'WebSite', name: 'VERO', url: SITE_URL + '/' }
    };

    return (
        <div className="page-live">
            <main className="container live-main">
                <nav className="crumbs" aria-label="Breadcrumb">
                    <Link href="/">Home</Link><span>/</span><Link href="/live">Live</Link><span>/</span><span aria-current="page">{t.title}</span>
                </nav>
                <header className="page-head theater-head">
                    <div className={'theater-badge static ' + t.tone}><i className={'ph ' + t.icon} /> {t.badge}</div>
                    <h1>{t.title}</h1>
                    <p>{t.desc}</p>
                    <div className="theater-stats head-stats">
                        {t.stats.map(stat => (
                            <div className="stat-box" key={stat.label}>
                                <span className="stat-label">{stat.label}</span>
                                <span className={'stat-val' + (stat.tone ? ' ' + stat.tone : '')}>{stat.value}</span>
                            </div>
                        ))}
                    </div>
                    <div className="head-actions">
                        <Link href={'/explore?q=' + encodeURIComponent(t.query)} className="btn-primary"><i className="ph ph-compass" /> <span>Search this theater</span></Link>
                        {t.map ? <a href={t.map} target="_blank" rel="noopener noreferrer" className="btn-ghost"><i className="ph ph-arrow-square-out" /> <span>Live map</span></a> : null}
                    </div>
                </header>
                <section className="live-section">
                    <div className="live-section-head">
                        <h2><i className="ph ph-broadcast" /> Latest reports</h2>
                        <p>From the last seven days.</p>
                    </div>
                    {articles.length ? (
                        <div className="flex-grid news-grid">
                            {articles.map((item, i) => (
                                <ReportCard key={item.url} item={item} overview={overviews.get(reportSlug(item.title, item.url))} eager={i < 3} />
                            ))}
                        </div>
                    ) : (
                        <p className="grid-msg">No recent reports yet. Check back in a few minutes.</p>
                    )}
                </section>
                {earlier.length ? (
                    <section className="live-section">
                        <div className="live-section-head">
                            <h2><i className="ph ph-clock-counter-clockwise" /> Earlier overviews</h2>
                            <p>VERO overviews of recent reports from this theater.</p>
                        </div>
                        <div className="flex-grid news-grid">
                            {earlier.map(d => (
                                <ReportCard
                                    key={d.slug}
                                    item={{ title: d.title, description: d.description, url: d.url, image: d.image, publishedAt: d.publishedAt, source: d.source, cat: d.category }}
                                    overview={{ title: d.overview.title, summary: d.overview.summary }}
                                />
                            ))}
                        </div>
                    </section>
                ) : null}
            </main>
            <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: jsonLd(graph) }} />
        </div>
    );
}
