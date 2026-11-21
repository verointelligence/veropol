import Link from 'next/link';
import { headers } from 'next/headers';
import FilterDrawer from '@/components/FilterDrawer';
import Pagination from '@/components/Pagination';
import ReportCard from '@/components/ReportCard';
import { CATEGORIES, RANGES, REGION_KEYS, TOPIC_KEYS } from '@/lib/format';
import { getEngine } from '@/lib/news/engine';
import { clientIp, createLimiter } from '@/lib/rate-limit';
import { ingest } from '@/lib/reports';
import { reportSlug } from '@/lib/slug';

export const dynamic = 'force-dynamic';

const PAGE_SIZE = 9;
const CATS = new Set(['all', ...TOPIC_KEYS, ...REGION_KEYS]);
const RANGE_KEYS = new Set(RANGES.map(r => r.key));
const limiter = createLimiter({ limit: 60, windowMs: 60 * 1000 });
const SUGGESTIONS = ['UN Security Council', 'BRICS', 'Taiwan Strait'];

function readParams(sp) {
    const one = v => (Array.isArray(v) ? v[0] : v);
    const q = String(one(sp.q) || '').replace(/[\u0000-\u001f\u007f]/g, ' ').replace(/\s+/g, ' ').trim().slice(0, 120);
    const cat = CATS.has(String(one(sp.cat))) ? String(one(sp.cat)) : 'all';
    const range = RANGE_KEYS.has(String(one(sp.range))) ? String(one(sp.range)) : 'all';
    const page = Math.min(Math.max(parseInt(one(sp.page), 10) || 1, 1), 500);
    return { q, cat, range, page };
}

function href({ q, cat, range }, page = 1) {
    const p = new URLSearchParams();
    if (q) p.set('q', q);
    if (cat !== 'all') p.set('cat', cat);
    if (range !== 'all') p.set('range', range);
    if (page > 1) p.set('page', String(page));
    const s = p.toString();
    return '/explore' + (s ? '?' + s : '');
}

export async function generateMetadata({ searchParams }) {
    const state = readParams(await searchParams);
    const filtered = state.q || state.cat !== 'all' || state.range !== 'all' || state.page > 1;
    return {
        title: 'Explore',
        description: 'Search any region, leader or crisis across vetted newsrooms. Every report opens as a VERO overview with a link to the original source.',
        alternates: { canonical: '/explore' },
        robots: filtered ? { index: false, follow: true } : { index: true, follow: true }
    };
}

const FOCUS = {
    exact: name => 'Showing reports about ' + name,
    broad: name => 'Showing broader coverage of ' + name,
    web: name => 'Includes wider web reports about ' + name,
    related: name => 'Showing related coverage for ' + name
};

export default async function ExplorePage({ searchParams }) {
    const state = readParams(await searchParams);
    const h = await headers();
    const allowed = limiter.check(clientIp(h)).ok;
    let result = null;
    let failed = false;
    if (allowed) {
        try {
            result = await getEngine().search({ q: state.q, category: state.cat, range: state.range, page: state.page, size: PAGE_SIZE, uiLang: 'en', detect: false, client: null });
        } catch {
            failed = true;
        }
    }
    const articles = result ? result.articles : [];
    const overviews = articles.length ? await ingest(articles, { warm: 0 }).catch(() => new Map()) : new Map();
    const total = result ? result.total : 0;
    const start = total ? (result.page - 1) * PAGE_SIZE + 1 : 0;
    const end = total ? Math.min(result.page * PAGE_SIZE, total) : 0;
    const activeCount = (state.cat !== 'all' ? 1 : 0) + (state.range !== 'all' ? 1 : 0);

    let focusText = '';
    if (result && result.focus) {
        const make = FOCUS[result.focus.tier] || FOCUS.related;
        focusText = make(result.focus.name);
    } else if (result && result.broadened) {
        focusText = 'No exact match. Showing related coverage.';
    }

    const filterLink = (cat, range) => href({ q: state.q, cat, range });

    return (
        <div className="page-explore">
            <main className="container explore-main">
                <header className="page-head">
                    <h1>Explore</h1>
                    <p>Search any region, leader or crisis across 18 vetted sources.</p>
                </header>
                <div className="search-hero-container">
                    <form className="search-bar massive" action="/explore" method="get" role="search">
                        <i className="ph ph-magnifying-glass search-icon" />
                        <input type="text" name="q" defaultValue={state.q} maxLength={120} autoComplete="off" spellCheck={false} placeholder="Search any region, leader or crisis" aria-label="Search" />
                        {state.cat !== 'all' ? <input type="hidden" name="cat" value={state.cat} /> : null}
                        {state.range !== 'all' ? <input type="hidden" name="range" value={state.range} /> : null}
                        <button className="search-pulse-btn" type="submit" aria-label="Run search">
                            <svg className="radar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                                <circle cx="12" cy="12" r="9" />
                                <circle cx="12" cy="12" r="4.8" />
                                <g className="radar-sweep">
                                    <path d="M12 12L19.8 7.5" />
                                    <path d="M12 12V3A9 9 0 0 1 19.8 7.5Z" fill="currentColor" fillOpacity="0.35" stroke="none" />
                                </g>
                                <circle className="radar-blip" cx="15.8" cy="16" r="1.1" fill="currentColor" stroke="none" />
                            </svg>
                        </button>
                    </form>
                    <div className="search-suggestions">
                        {SUGGESTIONS.map(s => (
                            <Link key={s} className="suggestion-pill" href={href({ q: s, cat: 'all', range: 'all' })} prefetch={false}>{s}</Link>
                        ))}
                    </div>
                </div>
                <section className="controls-section" id="intelligence">
                    {focusText ? <p className="focus-note"><i className="ph ph-crosshair-simple" /> {focusText}</p> : null}
                    <p className="results-meta">
                        {!allowed ? 'Too many searches. Please wait a moment.' : failed ? 'The connection to the news feed failed. Please try again.' : total ? 'Showing ' + start + '-' + end + ' of ' + total + ' reports' : ''}
                    </p>
                    {result && result.related && result.related.length ? (
                        <div className="related-box">
                            <span className="rel-label">Related</span>
                            {result.related.map(r => (
                                <Link key={r} href={href({ q: r, cat: 'all', range: 'all' })} prefetch={false}>{r}</Link>
                            ))}
                        </div>
                    ) : null}
                </section>
                <div className="explore-layout">
                    <FilterDrawer count={activeCount}>
                        <div className="filter-groups">
                            <div className="filter-row">
                                <span className="filter-label">Topic</span>
                                <div className="filters">
                                    <Link className={'filter-btn' + (state.cat === 'all' ? ' active' : '')} href={filterLink('all', state.range)} prefetch={false}><i className="ph ph-globe-hemisphere-west" /> Global Overview</Link>
                                    {TOPIC_KEYS.map(k => (
                                        <Link key={k} className={'filter-btn' + (state.cat === k ? ' active' : '')} href={filterLink(k, state.range)} prefetch={false}><i className={'ph ' + CATEGORIES[k].icon} /> {CATEGORIES[k].label}</Link>
                                    ))}
                                </div>
                            </div>
                            <div className="filter-row">
                                <span className="filter-label">Region</span>
                                <div className="filters">
                                    {REGION_KEYS.map(k => (
                                        <Link key={k} className={'filter-btn' + (state.cat === k ? ' active' : '')} href={filterLink(k, state.range)} prefetch={false}><i className={'ph ' + CATEGORIES[k].icon} /> {CATEGORIES[k].label}</Link>
                                    ))}
                                </div>
                            </div>
                            <div className="filter-row">
                                <span className="filter-label">Time</span>
                                <div className="range-filters">
                                    {RANGES.map(r => (
                                        <Link key={r.key} className={'range-btn filter-btn' + (state.range === r.key ? ' active' : '')} href={filterLink(state.cat, r.key)} prefetch={false}>{r.label}</Link>
                                    ))}
                                </div>
                            </div>
                        </div>
                    </FilterDrawer>
                    <div className="explore-results">
                        {articles.length ? (
                            <section className="flex-grid news-grid" id="newsGrid">
                                {articles.map((item, i) => (
                                    <ReportCard key={item.url} item={item} overview={overviews.get(reportSlug(item.title, item.url))} eager={i < 3} />
                                ))}
                            </section>
                        ) : (
                            <section className="flex-grid news-grid" id="newsGrid">
                                <p className="grid-msg">{failed || !allowed ? 'Nothing to show right now.' : 'No reports matched. Try a broader search.'}</p>
                            </section>
                        )}
                        {result ? <Pagination page={result.page} totalPages={result.totalPages} hrefFor={p => href(state, p)} /> : null}
                    </div>
                </div>
            </main>
        </div>
    );
}
