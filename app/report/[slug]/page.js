import Link from 'next/link';
import { notFound } from 'next/navigation';
import ReportCard from '@/components/ReportCard';
import { THEATERS, isTheater } from '@/content/theaters';
import { CATEGORIES, clip, formatDate, jsonLd, proxied, timeAgo, validCover } from '@/lib/format';
import { dbReady } from '@/lib/db';
import { getEngine } from '@/lib/news/engine';
import { getReport, queueOverview, relatedReports } from '@/lib/reports';
import { isReportSlug } from '@/lib/slug';
import { SITE_URL } from '@/lib/site';

export const dynamic = 'force-dynamic';

function readyOverview(doc) {
    return doc && doc.overview && doc.overview.generatedAt && doc.overview.title ? doc.overview : null;
}

export async function generateMetadata({ params }) {
    const { slug } = await params;
    const doc = await getReport(slug);
    if (!doc) return { title: 'Report not found', robots: { index: false, follow: false } };
    const overview = readyOverview(doc);
    const canonical = '/report/' + slug;
    if (!overview) {
        return { title: clip(doc.title, 70), alternates: { canonical }, robots: { index: false, follow: true } };
    }
    const description = clip(overview.summary, 155);
    return {
        title: overview.title,
        description,
        alternates: { canonical },
        robots: { index: true, follow: true },
        openGraph: { type: 'article', title: overview.title, description, url: canonical, publishedTime: new Date(doc.publishedAt).toISOString() }
    };
}

async function coverFor(doc) {
    try {
        const engine = getEngine();
        const og = await Promise.race([engine.og(doc.url), new Promise(r => setTimeout(() => r(null), 2500))]);
        if (og) return proxied(og);
        if (validCover(doc.image) && engine.imageAllowed(doc.image)) return proxied(doc.image);
    } catch {
        return null;
    }
    return null;
}

export default async function ReportPage({ params }) {
    const { slug } = await params;
    if (!isReportSlug(slug)) notFound();
    if (!(await dbReady())) {
        return (
            <div className="page-report">
                <main className="report-page">
                    <div className="report-pending">
                        <i className="ph ph-plugs" />
                        <div>
                            <b>This report is temporarily unavailable.</b>
                            <p>Please try again in a minute.</p>
                        </div>
                    </div>
                    <Link href="/live" className="btn-ghost"><i className="ph ph-broadcast" /> <span>Back to Live</span></Link>
                </main>
            </div>
        );
    }
    const doc = await getReport(slug);
    if (!doc) notFound();
    const overview = readyOverview(doc);
    if (!overview) queueOverview(slug);
    const theater = doc.theater && isTheater(doc.theater) ? THEATERS[doc.theater] : null;
    const cat = CATEGORIES[doc.category] || CATEGORIES.intel;
    const [cover, related] = await Promise.all([coverFor(doc), relatedReports(doc, 3)]);

    const graph = overview
        ? {
            '@context': 'https://schema.org',
            '@type': 'NewsArticle',
            headline: overview.title,
            description: overview.summary,
            datePublished: new Date(doc.publishedAt).toISOString(),
            dateModified: new Date(overview.generatedAt).toISOString(),
            author: { '@type': 'Organization', name: 'VERO', url: SITE_URL + '/' },
            publisher: { '@type': 'Organization', name: 'VERO', logo: { '@type': 'ImageObject', url: SITE_URL + '/assets/icon-512.png' } },
            mainEntityOfPage: SITE_URL + '/report/' + slug,
            isBasedOn: doc.url
        }
        : null;

    return (
        <div className="page-report">
            <main className="report-page">
                <nav className="crumbs" aria-label="Breadcrumb">
                    <Link href="/">Home</Link><span>/</span>
                    <Link href="/live">Live</Link><span>/</span>
                    {theater ? <><Link href={'/live/' + doc.theater}>{theater.title}</Link><span>/</span></> : null}
                    <span aria-current="page">Report</span>
                </nav>
                <article>
                    <header className="report-head">
                        <div className="report-chips">
                            <span className="card-tag static"><i className={'ph ' + cat.icon} /> {cat.label}</span>
                            {theater ? <Link className="chip-link" href={'/live/' + doc.theater}>{theater.title}</Link> : null}
                        </div>
                        <h1 className="report-title">{overview ? overview.title : clip(doc.title, 140)}</h1>
                        <p className="report-meta">
                            <span>{doc.source}{doc.sourceRegion ? ' \u00b7 ' + doc.sourceRegion : ''}</span>
                            <span>{formatDate(doc.publishedAt)}</span>
                            <span>{timeAgo(doc.publishedAt)}</span>
                        </p>
                    </header>
                    {cover ? (
                        <figure className="report-cover">
                            <img src={cover} alt="" referrerPolicy="no-referrer" decoding="async" />
                            <figcaption>Image from {doc.source}</figcaption>
                        </figure>
                    ) : null}
                    {overview ? (
                        <>
                            <p className="report-lead">{overview.summary}</p>
                            <section className="report-section">
                                <h2>Key points</h2>
                                <ul className="report-points">
                                    {overview.keyPoints.map(point => <li key={point}>{point}</li>)}
                                </ul>
                            </section>
                            <section className="report-section">
                                <h2>Context</h2>
                                <p>{overview.context}</p>
                            </section>
                        </>
                    ) : (
                        <div className="report-pending">
                            <i className="ph ph-hourglass-medium" />
                            <div>
                                <b>The VERO overview is being prepared.</b>
                                <p>Reload this page in a minute. The original report is available at the source below.</p>
                            </div>
                        </div>
                    )}
                    <section className="report-source">
                        <span className="report-source-label">Original report</span>
                        <p className="report-source-title" dir="auto">{doc.title}</p>
                        <p className="report-source-by">{doc.source}</p>
                        <a href={doc.url} className="btn-primary" target="_blank" rel="noopener noreferrer"><i className="ph ph-arrow-up-right" /> <span>Go to source</span></a>
                    </section>
                    <p className="report-note">A VERO overview places a report in context. It does not replace the original reporting, and every claim belongs to the outlet named above. <Link href="/methodology">How VERO works</Link></p>
                </article>
                {related.length ? (
                    <section className="report-more">
                        <h2>More from this theater</h2>
                        <div className="flex-grid news-grid">
                            {related.map(d => (
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
            {graph ? <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: jsonLd(graph) }} /> : null}
        </div>
    );
}
