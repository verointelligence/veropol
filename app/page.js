import Link from 'next/link';
import HomeSearch from '@/components/HomeSearch';
import LivePreview from '@/components/LivePreview';
import ReportCard from '@/components/ReportCard';
import { dbReady } from '@/lib/db';
import sources from '@/lib/news/sources.cjs';
import { previewRows } from '@/lib/preview';
import { latestReports } from '@/lib/reports';

export const dynamic = 'force-dynamic';

export const metadata = {
    alternates: { canonical: '/' }
};

function withTimeout(promise, ms, fallback) {
    return Promise.race([promise.catch(() => fallback), new Promise(resolve => setTimeout(() => resolve(fallback), ms))]);
}

const CHIPS = ['Taiwan Strait', 'Donald Trump', 'BRICS'];

export default async function HomePage() {
    const initial = await withTimeout(previewRows(4), 1500, []);
    const latest = (await dbReady()) ? await withTimeout(latestReports(6), 2500, []) : [];
    const sourceCount = sources.TRUSTED_SOURCES.length;
    return (
        <div className="page-home">
            <header className="home-hero">
                <div className="home-grid">
                    <div className="home-copy">
                        <h1 className="home-title"><span>The world,</span> <em>verified.</em></h1>
                        <p className="home-sub">Live conflict, diplomacy and economy monitoring from vetted sources.</p>
                        <HomeSearch />
                        <div className="home-chips">
                            {CHIPS.map(chip => (
                                <Link key={chip} className="chip-link" href={'/explore?q=' + encodeURIComponent(chip)}>{chip}</Link>
                            ))}
                        </div>
                    </div>
                    <aside className="home-preview" aria-label="Live preview">
                        <div className="pv-card pv-main">
                            <div className="pv-head">
                                <span className="dot" />
                                <b>Live now</b>
                                <Link href="/live" className="pv-more" aria-label="Open Live"><i className="ph ph-arrow-up-right" /></Link>
                            </div>
                            <LivePreview initial={initial} />
                        </div>
                        <div className="pv-card pv-float pv-a"><i className="ph ph-compass" /><div><b>Explore</b><small>Live search</small></div></div>
                        <div className="pv-card pv-float pv-b"><i className="ph ph-seal-check" /><div><b>Vetted sources</b><small>{sourceCount}</small></div></div>
                    </aside>
                </div>
                <div className="service-tiles">
                    <Link href="/live" className="svc-tile">
                        <span className="svc-ico"><i className="ph ph-broadcast" /></span>
                        <span className="svc-text"><b>Live</b><small>Every theater, refreshed every 5 minutes.</small></span>
                        <i className="ph ph-arrow-up-right svc-go" />
                    </Link>
                    <Link href="/explore" className="svc-tile">
                        <span className="svc-ico"><i className="ph ph-compass" /></span>
                        <span className="svc-text"><b>Explore</b><small>{'Search ' + sourceCount + ' vetted sources.'}</small></span>
                        <i className="ph ph-arrow-up-right svc-go" />
                    </Link>
                    <Link href="/articles" className="svc-tile">
                        <span className="svc-ico"><i className="ph ph-newspaper" /></span>
                        <span className="svc-text"><b>Articles</b><small>Signed analysis from independent authors.</small></span>
                        <i className="ph ph-arrow-up-right svc-go" />
                    </Link>
                </div>
            </header>
            <main className="container home-main">
                {latest.length ? (
                    <section className="home-latest" id="latest">
                        <div className="home-latest-head">
                            <h2>Latest VERO overviews</h2>
                            <Link href="/live" className="btn-ghost"><i className="ph ph-broadcast" /> <span>See Live</span></Link>
                        </div>
                        <div className="flex-grid news-grid">
                            {latest.map(d => (
                                <ReportCard
                                    key={d.slug}
                                    item={{ title: d.title, description: d.description, url: d.url, image: d.image, publishedAt: d.publishedAt, source: d.source, cat: d.category }}
                                    overview={{ title: d.overview.title, summary: d.overview.summary }}
                                />
                            ))}
                        </div>
                    </section>
                ) : null}
                <section className="articles-cta" id="writers">
                    <div className="cta-copy">
                        <h2>Have analysis the world should read?</h2>
                        <p>Publish signed articles on diplomacy, security and the global economy. Open to every verified member.</p>
                        <div className="cta-actions">
                            <Link href="/articles" className="btn-primary"><i className="ph ph-newspaper" /> <span>Read articles</span></Link>
                            <Link href="/articles/new" className="btn-ghost"><i className="ph ph-pen-nib" /> <span>Write for VERO</span></Link>
                        </div>
                    </div>
                </section>
                <section className="transparency" id="transparency">
                    <div className="section-title">
                        <h2>How VERO chooses what you read</h2>
                    </div>
                    <div className="flex-grid trans-grid">
                        <div className="trans-card">
                            <i className="ph ph-seal-check" />
                            <h3>Vetted sources only</h3>
                            <p>Headlines come only from established outlets with editorial accountability, across Arab, European, United Nations and US media.</p>
                        </div>
                        <div className="trans-card">
                            <i className="ph ph-scales" />
                            <h3>Compare, don&apos;t merge</h3>
                            <p>Reports are never rewritten or blended. Several outlets covering the same story appear side by side so that readers can compare how each one frames it.</p>
                        </div>
                        <div className="trans-card">
                            <i className="ph ph-link-simple" />
                            <h3>Always link to the source</h3>
                            <p>Every report shows a headline, a short snippet and the outlet. The full report always opens at the original publisher.</p>
                        </div>
                    </div>
                    <div className="center-row">
                        <Link href="/methodology" className="btn-ghost"><i className="ph ph-book-open-text" /> <span>Read the full methodology</span></Link>
                    </div>
                </section>
            </main>
        </div>
    );
}
