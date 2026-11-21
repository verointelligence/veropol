#!/usr/bin/env bash
set -e

if [ ! -d old-site/css ]; then echo "HATA: Bu komutu veropol klasorunun icinde calistir (old-site/css burada olmali)."; exit 1; fi
mkdir -p app/css
for f in style nav home live explore; do cp "old-site/css/$f.css" "app/css/$f.css"; echo "kopyalandi: app/css/$f.css"; done

cat > ".env.example" <<'VERO_EOF_0'
NEXT_PUBLIC_SITE_URL=http://localhost:3000
MONGODB_URI=
GNEWS_API_KEY=
LLM_BASE_URL=
LLM_API_KEY=
LLM_MODEL=
OVERVIEW_DAILY_LIMIT=150
VERO_EOF_0
echo "yazildi: .env.example"

mkdir -p "app/css"
cat > "app/css/background.css" <<'VERO_EOF_1'
:root {
    --bd-a: rgba(18, 18, 20, 0.045);
    --bd-b: rgba(217, 67, 26, 0.055);
    --bd-c: rgba(18, 18, 20, 0.06);
    --bd-line: rgba(217, 67, 26, 0.32);
    --bd-grid: rgba(18, 18, 20, 0.045);
}

:root[data-theme="dark"] {
    --bd-a: rgba(255, 255, 255, 0.032);
    --bd-b: rgba(255, 106, 61, 0.05);
    --bd-c: rgba(255, 255, 255, 0.045);
    --bd-line: rgba(255, 106, 61, 0.34);
    --bd-grid: rgba(255, 255, 255, 0.035);
}

body::before {
    display: none;
}

.backdrop {
    position: fixed;
    inset: 0;
    z-index: -1;
    overflow: hidden;
    pointer-events: none;
}

.bd-shapes {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
}

.bd-a {
    fill: var(--bd-a);
}

.bd-b {
    fill: var(--bd-b);
}

.bd-c {
    fill: var(--bd-c);
}

.bd-line,
.bd-v {
    fill: none;
    stroke: var(--bd-line);
    vector-effect: non-scaling-stroke;
}

.bd-line {
    stroke-width: 1;
}

.bd-v {
    stroke-width: 1.6;
    stroke-linejoin: miter;
}

.bd-grid {
    position: absolute;
    inset: 0;
    background-image:
        linear-gradient(var(--bd-grid) 1px, transparent 1px),
        linear-gradient(90deg, var(--bd-grid) 1px, transparent 1px);
    background-size: 72px 72px;
    -webkit-mask-image: radial-gradient(ellipse 70% 55% at 50% 22%, #000 0%, transparent 100%);
    mask-image: radial-gradient(ellipse 70% 55% at 50% 22%, #000 0%, transparent 100%);
}

.bd-glow {
    position: absolute;
    inset: 0;
    background:
        radial-gradient(640px 460px at 92% -6%, var(--accent-soft), transparent 68%),
        radial-gradient(520px 420px at -4% 104%, var(--accent-soft), transparent 70%);
}

@media (max-width: 720px) {
    .bd-grid {
        background-size: 56px 56px;
    }

    .bd-v {
        stroke-width: 1.2;
    }
}
VERO_EOF_1
echo "yazildi: app/css/background.css"

mkdir -p "app/css"
cat > "app/css/pages.css" <<'VERO_EOF_2'
.nf-page {
    min-height: 100vh;
    display: grid;
    place-items: center;
    padding: 130px 20px 60px;
    text-align: center;
}

.nf-card {
    width: min(640px, 100%);
    display: grid;
    justify-items: center;
    gap: 18px;
}

.nf-code {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: clamp(8px, 2vw, 18px);
    font-family: 'Unbounded', 'Manrope', sans-serif;
    font-weight: 800;
    font-size: clamp(4.4rem, 20vw, 9rem);
    line-height: 1;
    letter-spacing: -0.04em;
}

.nf-code img {
    width: clamp(64px, 18vw, 128px);
    height: clamp(64px, 18vw, 128px);
    border-radius: 50%;
    object-fit: cover;
    box-shadow: 0 0 0 2px var(--accent), 0 0 60px var(--accent-soft);
}

.nf-card h1 {
    margin: 0;
    font-size: clamp(1.3rem, 4vw, 1.8rem);
}

.nf-card p {
    margin: 0;
    max-width: 460px;
    color: var(--muted);
    line-height: 1.7;
}

.nf-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    justify-content: center;
    margin-top: 8px;
}

.nf-path {
    max-width: 100%;
    overflow-wrap: anywhere;
    padding: 6px 14px;
    border-radius: 999px;
    border: 1px solid var(--line);
    background: var(--surface);
    font-family: ui-monospace, Menlo, Consolas, monospace;
    font-size: 0.78rem;
    color: var(--muted);
}
    

.doc-page {
    max-width: 1040px;
    margin: 0 auto;
    padding: 140px 20px 80px;
}

.doc-head {
    margin-bottom: 44px;
}

.doc-eyebrow {
    margin: 0 0 12px;
    font-size: 0.72rem;
    font-weight: 800;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--accent);
}

.doc-head h1 {
    margin: 0 0 14px;
    font-size: clamp(2rem, 5vw, 3.2rem);
    letter-spacing: -0.03em;
}

.doc-lead {
    max-width: 640px;
    margin: 0 0 12px;
    color: var(--muted);
    font-size: 1.08rem;
    line-height: 1.6;
}

.doc-meta {
    margin: 0;
    font-size: 0.8rem;
    font-weight: 700;
    color: var(--muted);
}

.doc-layout {
    display: grid;
    grid-template-columns: 220px minmax(0, 1fr);
    gap: 48px;
    align-items: start;
}

.doc-toc {
    position: sticky;
    top: 120px;
    padding: 18px;
    border-radius: var(--r-md);
    border: 1px solid var(--line);
    background: var(--surface);
}

.doc-toc p {
    margin: 0 0 10px;
    font-size: 0.68rem;
    font-weight: 800;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: var(--muted);
}

.doc-toc ul {
    display: grid;
    gap: 2px;
    margin: 0;
    padding: 0;
    list-style: none;
}

.doc-toc a {
    display: block;
    padding: 7px 10px;
    border-radius: var(--r-sm);
    color: var(--muted);
    font-size: 0.86rem;
    font-weight: 700;
    transition: color 0.2s, background 0.2s;
}

.doc-toc a:hover {
    color: var(--accent);
    background: var(--accent-soft);
}

.doc-body {
    display: grid;
    gap: 36px;
    min-width: 0;
}

.doc-body section {
    scroll-margin-top: 110px;
}

.doc-body h2 {
    margin: 0 0 12px;
    font-size: clamp(1.2rem, 2.6vw, 1.55rem);
}

.doc-body p {
    margin: 0 0 14px;
    max-width: 68ch;
    color: var(--muted);
    font-size: 1rem;
    line-height: 1.75;
}

.doc-links {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 56px;
    padding-top: 28px;
    border-top: 1px solid var(--line);
}

@media (max-width: 860px) {
    .doc-page {
        padding-top: 120px;
    }

    .doc-layout {
        grid-template-columns: minmax(0, 1fr);
        gap: 28px;
    }

    .doc-toc {
        position: static;
    }
}
VERO_EOF_2
echo "yazildi: app/css/pages.css"

mkdir -p "app/css"
cat > "app/css/report.css" <<'VERO_EOF_3'
.crumbs {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px;
    margin: 0 0 22px;
    font-size: 0.8rem;
    font-weight: 700;
    color: var(--muted);
}

.crumbs a:hover {
    color: var(--accent);
}

.page-live .crumbs,
.page-explore .crumbs {
    padding-top: 130px;
}

.page-report .report-page {
    max-width: 820px;
    margin: 0 auto;
    padding: 130px 20px 80px;
}

.report-head {
    margin-bottom: 26px;
}

.report-chips {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 10px;
    margin-bottom: 16px;
}

.card-tag.static {
    position: static;
}

.chip-link {
    display: inline-flex;
    align-items: center;
    padding: 8px 16px;
    border-radius: 999px;
    border: 1px solid var(--line);
    background: var(--surface);
    font-size: 0.82rem;
    font-weight: 700;
    transition: border-color 0.2s, color 0.2s;
}

.chip-link:hover {
    border-color: var(--accent);
    color: var(--accent);
}

.report-title {
    margin: 0 0 14px;
    font-size: clamp(1.7rem, 4.4vw, 2.7rem);
    letter-spacing: -0.03em;
    line-height: 1.12;
}

.report-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 6px 16px;
    margin: 0;
    font-size: 0.82rem;
    font-weight: 700;
    color: var(--muted);
}

.report-cover {
    margin: 0 0 28px;
    overflow: hidden;
    border-radius: var(--r-lg);
    border: 1px solid var(--line);
    background: var(--surface);
}

.report-cover img {
    width: 100%;
    max-height: 420px;
    object-fit: cover;
}

.report-cover figcaption {
    padding: 10px 16px;
    font-size: 0.72rem;
    font-weight: 700;
    color: var(--muted);
}

.report-lead {
    margin: 0 0 30px;
    font-size: clamp(1.1rem, 2.2vw, 1.3rem);
    line-height: 1.65;
}

.report-section {
    margin-bottom: 30px;
}

.report-section h2,
.report-more h2 {
    margin: 0 0 12px;
    font-size: 1.15rem;
}

.report-section p {
    margin: 0;
    max-width: 68ch;
    color: var(--muted);
    line-height: 1.75;
}

.report-points {
    display: grid;
    gap: 10px;
    margin: 0;
    padding: 0;
    list-style: none;
}

.report-points li {
    position: relative;
    padding: 14px 16px 14px 46px;
    border-radius: var(--r-md);
    border: 1px solid var(--line);
    background: var(--surface);
    line-height: 1.55;
}

.report-points li::before {
    content: '';
    position: absolute;
    inset-inline-start: 18px;
    top: 22px;
    width: 10px;
    height: 10px;
    border-radius: 3px;
    background: var(--accent);
    transform: rotate(45deg);
}

.report-pending {
    display: flex;
    align-items: flex-start;
    gap: 14px;
    margin-bottom: 30px;
    padding: 20px;
    border-radius: var(--r-md);
    border: 1px dashed var(--line);
    background: var(--surface);
}

.report-pending i {
    font-size: 1.6rem;
    color: var(--accent);
}

.report-pending p {
    margin: 4px 0 0;
    color: var(--muted);
}

.report-source {
    display: grid;
    gap: 10px;
    justify-items: start;
    margin-bottom: 22px;
    padding: 22px;
    border-radius: var(--r-lg);
    border: 1px solid var(--line);
    background: var(--surface);
}

.report-source-label {
    font-size: 0.68rem;
    font-weight: 800;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: var(--accent);
}

.report-source-title {
    margin: 0;
    font-size: 1.05rem;
    font-weight: 700;
    line-height: 1.45;
}

.report-source-by {
    margin: 0;
    font-size: 0.84rem;
    font-weight: 700;
    color: var(--muted);
}

.report-note {
    margin: 0 0 54px;
    font-size: 0.8rem;
    line-height: 1.6;
    color: var(--muted);
}

.report-note a {
    color: var(--accent);
    font-weight: 700;
}

.report-more {
    padding-top: 12px;
}

.theater-head {
    display: grid;
    justify-items: center;
    gap: 14px;
    margin-bottom: 40px;
}

.theater-head h1 {
    margin: 0;
}

.theater-head p {
    max-width: 620px;
    margin: 0;
    color: var(--muted);
}

.theater-badge.static {
    position: static;
}

.head-stats {
    width: min(420px, 100%);
}

.head-actions {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 10px;
}

.theater-info h3 a {
    position: relative;
    z-index: 3;
}

.theater-info h3 a:hover {
    color: var(--accent);
}

.page-arrow[aria-disabled="true"] {
    opacity: 0.35;
    cursor: not-allowed;
}

.related-box a {
    padding: 8px 14px;
    border-radius: 999px;
    border: 1px solid var(--line);
    background: var(--surface);
    font-size: 0.82rem;
    font-weight: 700;
    transition: border-color 0.2s, color 0.2s;
}

.related-box a:hover {
    border-color: var(--accent);
    color: var(--accent);
}

.filter-btn {
    text-decoration: none;
}

.home-latest {
    margin-top: 80px;
}

.home-latest-head {
    display: flex;
    flex-wrap: wrap;
    align-items: baseline;
    justify-content: space-between;
    gap: 8px 18px;
    margin-bottom: 22px;
}

.home-latest-head h2 {
    margin: 0;
    font-size: clamp(1.3rem, 3vw, 1.8rem);
}

@media (max-width: 720px) {
    .page-report .report-page {
        padding-top: 110px;
    }

    .page-live .crumbs,
    .page-explore .crumbs {
        padding-top: 110px;
    }
}
VERO_EOF_3
echo "yazildi: app/css/report.css"

mkdir -p "app/explore"
cat > "app/explore/page.js" <<'VERO_EOF_4'
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
VERO_EOF_4
echo "yazildi: app/explore/page.js"

mkdir -p "app/img"
cat > "app/img/route.js" <<'VERO_EOF_5'
import dns from 'node:dns/promises';
import net from 'node:net';
import { getEngine } from '@/lib/news/engine';
import { clientIp, createLimiter } from '@/lib/rate-limit';

export const dynamic = 'force-dynamic';

const MAX_BYTES = 6 * 1024 * 1024;
const CACHE_LIMIT = 70 * 1024 * 1024;
const UA = 'Mozilla/5.0 (compatible; VEROBot/1.0; +https://veropol.onrender.com; veropol@proton.me)';
const STATE = Symbol.for('vero.img.cache');
const limiter = createLimiter({ limit: 400, windowMs: 60 * 1000 });

function state() {
    if (!globalThis[STATE]) globalThis[STATE] = { map: new Map(), bytes: 0 };
    return globalThis[STATE];
}

function privateAddress(ip) {
    if (net.isIPv4(ip)) {
        const p = ip.split('.').map(Number);
        return p[0] === 10 || p[0] === 127 || p[0] === 0 || (p[0] === 169 && p[1] === 254) || (p[0] === 172 && p[1] >= 16 && p[1] <= 31) || (p[0] === 192 && p[1] === 168) || (p[0] === 100 && p[1] >= 64 && p[1] <= 127);
    }
    const v = ip.toLowerCase();
    return v === '::1' || v === '::' || v.startsWith('fc') || v.startsWith('fd') || v.startsWith('fe80') || v.startsWith('::ffff:');
}

async function safeHost(hostname) {
    const list = await dns.lookup(hostname, { all: true });
    return list.length > 0 && list.every(a => !privateAddress(a.address));
}

async function pullImage(u, hops) {
    const url = new URL(u);
    if (!/^https?:$/.test(url.protocol) || !(await safeHost(url.hostname))) throw new Error('blocked');
    const response = await fetch(u, {
        headers: { 'User-Agent': UA, Accept: 'image/avif,image/webp,image/png,image/jpeg,image/*;q=0.8', Referer: url.origin + '/' },
        redirect: 'manual',
        signal: AbortSignal.timeout(10000)
    });
    if (response.status >= 300 && response.status < 400 && response.headers.get('location') && hops < 3) {
        return pullImage(new URL(response.headers.get('location'), u).toString(), hops + 1);
    }
    if (!response.ok) throw new Error('HTTP ' + response.status);
    const type = String(response.headers.get('content-type') || '').split(';')[0].trim().toLowerCase();
    if (!/^image\/(jpeg|png|webp|gif|avif)$/.test(type)) throw new Error('type');
    const len = parseInt(response.headers.get('content-length') || '0', 10);
    if (len > MAX_BYTES) throw new Error('big');
    const buf = Buffer.from(await response.arrayBuffer());
    if (buf.length < 200 || buf.length > MAX_BYTES) throw new Error('size');
    return { buf, type };
}

function remember(key, value, size) {
    const s = state();
    s.map.set(key, value);
    s.bytes += size;
    while (s.bytes > CACHE_LIMIT && s.map.size) {
        const k = s.map.keys().next().value;
        const v = s.map.get(k);
        s.bytes -= v && v.buf ? v.buf.length : 0;
        s.map.delete(k);
    }
}

const plain = status => new Response(null, { status });

export async function GET(request) {
    if (!limiter.check(clientIp(request.headers)).ok) return plain(429);
    const u = String(new URL(request.url).searchParams.get('u') || '').slice(0, 1500);
    let url;
    try {
        url = new URL(u);
    } catch {
        return plain(400);
    }
    const wiki = url.hostname === 'upload.wikimedia.org' || url.hostname === 'commons.wikimedia.org';
    if (!wiki && !getEngine().imageAllowed(u)) return plain(403);
    const s = state();
    let hit = s.map.get(u);
    if (hit && hit.fail && hit.exp < Date.now()) {
        s.map.delete(u);
        hit = null;
    }
    if (!hit) {
        try {
            const got = await pullImage(u, 0);
            hit = { buf: got.buf, type: got.type };
            remember(u, hit, got.buf.length);
        } catch {
            remember(u, { fail: true, exp: Date.now() + 10 * 60 * 1000 }, 0);
            return plain(502);
        }
    }
    if (hit.fail) return plain(502);
    return new Response(hit.buf, {
        headers: {
            'Content-Type': hit.type,
            'Cache-Control': 'public, max-age=604800',
            'X-Content-Type-Options': 'nosniff',
            'Content-Security-Policy': "default-src 'none'; sandbox"
        }
    });
}
VERO_EOF_5
echo "yazildi: app/img/route.js"

mkdir -p "app"
cat > "app/layout.js" <<'VERO_EOF_6'
import Script from 'next/script';
import Nav from '@/components/Nav';
import Footer from '@/components/Footer';
import Backdrop from '@/components/Backdrop';
import { CONTACT_EMAIL, GA_ID, SITE_DESCRIPTION, SITE_NAME, SITE_TITLE, SITE_URL } from '@/lib/site';
import './css/style.css';
import './css/nav.css';
import './css/home.css';
import './css/live.css';
import './css/explore.css';
import './css/pages.css';
import './css/report.css';
import './css/background.css';

export const metadata = {
    metadataBase: new URL(SITE_URL),
    title: { default: SITE_TITLE, template: '%s | VERO' },
    description: SITE_DESCRIPTION,
    applicationName: SITE_NAME,
    authors: [{ name: SITE_NAME }],
    robots: { index: true, follow: true, googleBot: { index: true, follow: true, 'max-image-preview': 'large' } },
    icons: {
        icon: [
            { url: '/favicon.ico', sizes: '48x48' },
            { url: '/assets/icon-48.png', sizes: '48x48', type: 'image/png' },
            { url: '/assets/icon-32.png', sizes: '32x32', type: 'image/png' },
            { url: '/assets/icon-16.png', sizes: '16x16', type: 'image/png' },
            { url: '/assets/icon-192.png', sizes: '192x192', type: 'image/png' }
        ],
        apple: [{ url: '/assets/icon-180.png', sizes: '180x180' }]
    },
    openGraph: {
        type: 'website',
        siteName: SITE_NAME,
        title: SITE_TITLE,
        description: SITE_DESCRIPTION,
        url: '/',
        images: [{ url: '/assets/BANNER.png', width: 1584, height: 672, alt: 'VERO' }]
    },
    twitter: { card: 'summary_large_image', title: SITE_TITLE, description: SITE_DESCRIPTION, images: ['/assets/BANNER.png'] }
};

export const viewport = {
    width: 'device-width',
    initialScale: 1,
    viewportFit: 'cover',
    themeColor: '#0A0A0C'
};

const THEME_SCRIPT = "(function(){try{var t=localStorage.getItem('vero_theme');if(t!=='light'&&t!=='dark'){t=window.matchMedia&&window.matchMedia('(prefers-color-scheme: light)').matches?'light':'dark';}document.documentElement.setAttribute('data-theme',t);}catch(e){}})();";

const GA_SCRIPT = "window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments);}gtag('js',new Date());gtag('config','" + GA_ID + "');";

const JSON_LD = JSON.stringify({
    '@context': 'https://schema.org',
    '@graph': [
        {
            '@type': 'WebSite',
            '@id': SITE_URL + '/#website',
            name: SITE_NAME,
            alternateName: ['VERO Global Intelligence', 'VERO Observatory', 'verointels'],
            url: SITE_URL + '/',
            inLanguage: 'en',
            publisher: { '@id': SITE_URL + '/#organization' }
        },
        {
            '@type': 'Organization',
            '@id': SITE_URL + '/#organization',
            name: SITE_NAME,
            url: SITE_URL + '/',
            logo: { '@type': 'ImageObject', url: SITE_URL + '/assets/icon-512.png', width: 512, height: 512 },
            email: CONTACT_EMAIL
        }
    ]
}).replace(/</g, '\\u003c');

export default function RootLayout({ children }) {
    return (
        <html lang="en" dir="ltr" data-theme="dark" suppressHydrationWarning>
            <head>
                <script dangerouslySetInnerHTML={{ __html: THEME_SCRIPT }} />
                <link rel="preconnect" href="https://fonts.googleapis.com" />
                <link rel="preconnect" href="https://unpkg.com" crossOrigin="" />
                <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
                <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Rubik:ital,wght@0,300..900;1,300..900&family=Unbounded:wght@700;800&display=swap" />
                <script defer src="https://unpkg.com/@phosphor-icons/web@2.1.1" />
            </head>
            <body>
                <Backdrop />
                <div className="toast-box" id="toastBox" role="status" />
                <Nav />
                {children}
                <Footer />
                <Script src={'https://www.googletagmanager.com/gtag/js?id=' + GA_ID} strategy="afterInteractive" />
                <Script id="ga-init" strategy="afterInteractive">{GA_SCRIPT}</Script>
                <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON_LD }} />
            </body>
        </html>
    );
}
VERO_EOF_6
echo "yazildi: app/layout.js"

mkdir -p "app/live/[theater]"
cat > "app/live/[theater]/page.js" <<'VERO_EOF_7'
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
VERO_EOF_7
echo "yazildi: app/live/[theater]/page.js"

mkdir -p "app/live"
cat > "app/live/page.js" <<'VERO_EOF_8'
import { DevelopingCard, TheaterCard } from '@/components/TheaterCard';
import { THEATERS, THEATER_SECTIONS } from '@/content/theaters';
import { theatersWithCovers } from '@/lib/news/engine';
import { ingest } from '@/lib/reports';
import { reportSlug } from '@/lib/slug';

export const dynamic = 'force-dynamic';

export const metadata = {
    title: 'Live Theaters',
    description: 'Active conflicts and strategic flashpoints tracked live from vetted newsrooms, each with a VERO overview and a map link.',
    alternates: { canonical: '/live' },
    openGraph: { title: 'Live Theaters | VERO', description: 'Active conflicts and strategic flashpoints tracked live from vetted newsrooms.', url: '/live', type: 'website' }
};

async function loadData() {
    try {
        return await theatersWithCovers();
    } catch {
        return { theaters: {}, developing: [], updatedAt: null };
    }
}

export default async function LivePage() {
    const data = await loadData();
    const overviews = new Map();
    await Promise.all(Object.keys(data.theaters).map(async id => {
        const t = data.theaters[id];
        if (!t || !t.lead) return;
        const map = await ingest([t.lead, ...(t.more || [])], { theater: id, warm: 1 }).catch(() => new Map());
        map.forEach((v, k) => overviews.set(k, v));
    }));
    const devMap = await ingest((data.developing || []).map(d => d.lead).filter(Boolean), { warm: 0 }).catch(() => new Map());
    devMap.forEach((v, k) => overviews.set(k, v));
    const overviewOf = lead => (lead ? overviews.get(reportSlug(lead.title, lead.url)) : undefined);

    return (
        <div className="page-live">
            <main className="container live-main">
                <header className="page-head">
                    <h1>Live Theaters</h1>
                    <p className="live-status"><span className="dot" /><span>Updated every 5 minutes.</span></p>
                </header>
                {THEATER_SECTIONS.map(section => (
                    <section className="live-section" key={section.key} id={section.key}>
                        <div className="live-section-head">
                            <h2><i className={'ph ' + section.icon} /> {section.title}</h2>
                            <p>{section.sub}</p>
                        </div>
                        <div className="flex-grid theaters-grid">
                            {section.ids.filter(id => THEATERS[id]).map(id => (
                                <TheaterCard key={id} id={id} data={data.theaters[id]} overview={overviewOf(data.theaters[id] && data.theaters[id].lead)} />
                            ))}
                        </div>
                    </section>
                ))}
                {data.developing && data.developing.length ? (
                    <section className="live-section" id="developing">
                        <div className="live-section-head">
                            <h2><i className="ph ph-trend-up" /> Developing</h2>
                            <p>Stories gaining coverage now. Removed when the trend ends.</p>
                        </div>
                        <div className="flex-grid theaters-grid">
                            {data.developing.map(card => (
                                <DevelopingCard key={card.id} card={card} overview={overviewOf(card.lead)} />
                            ))}
                        </div>
                    </section>
                ) : null}
            </main>
        </div>
    );
}
VERO_EOF_8
echo "yazildi: app/live/page.js"

mkdir -p "app/methodology"
cat > "app/methodology/page.js" <<'VERO_EOF_9'
import DocPage from '@/components/DocPage';
import { LEGAL } from '@/content/legal';
import { SITE_NAME } from '@/lib/site';

const doc = LEGAL.methodology;

export const metadata = {
    title: doc.title,
    description: doc.lead,
    alternates: { canonical: '/methodology' },
    openGraph: { title: doc.title + ' | ' + SITE_NAME, description: doc.lead, url: '/methodology', type: 'article' }
};

export default function Page() {
    return <DocPage doc={doc} />;
}
VERO_EOF_9
echo "yazildi: app/methodology/page.js"

mkdir -p "app"
cat > "app/not-found.js" <<'VERO_EOF_10'
import Link from 'next/link';
import NotFoundPath from '@/components/NotFoundPath';

export const metadata = {
    title: 'Page not found',
    robots: { index: false, follow: false }
};

export default function NotFound() {
    return (
        <main className="nf-page">
            <div className="nf-card">
                <div className="nf-code">
                    <span>4</span>
                    <img src="/assets/logo-192.webp" alt="" />
                    <span>4</span>
                </div>
                <h1>This page could not be found</h1>
                <p>The address may be mistyped, or the page may have been moved or removed. Use one of the links below to continue.</p>
                <NotFoundPath />
                <div className="nf-actions">
                    <Link href="/" className="btn-primary"><i className="ph ph-house" /> <span>Back to home</span></Link>
                    <Link href="/articles" className="btn-ghost"><i className="ph ph-newspaper" /> <span>Browse articles</span></Link>
                </div>
            </div>
        </main>
    );
}
VERO_EOF_10
echo "yazildi: app/not-found.js"

mkdir -p "app"
cat > "app/page.js" <<'VERO_EOF_11'
import Link from 'next/link';
import HomeSearch from '@/components/HomeSearch';
import ReportCard from '@/components/ReportCard';
import { THEATERS } from '@/content/theaters';
import { timeAgo } from '@/lib/format';
import { getEngine } from '@/lib/news/engine';
import { ingest, latestReports } from '@/lib/reports';
import { reportSlug } from '@/lib/slug';

export const dynamic = 'force-dynamic';

export const metadata = {
    alternates: { canonical: '/' }
};

function withTimeout(promise, ms, fallback) {
    return Promise.race([promise.catch(() => fallback), new Promise(resolve => setTimeout(() => resolve(fallback), ms))]);
}

async function loadPreview() {
    const data = await getEngine().theaters();
    return Object.entries(data.theaters)
        .filter(([, t]) => t && t.lead)
        .map(([id, t]) => ({ id, lead: t.lead }))
        .sort((a, b) => new Date(b.lead.publishedAt) - new Date(a.lead.publishedAt))
        .slice(0, 4);
}

const CHIPS = ['Taiwan Strait', 'Donald Trump', 'BRICS'];

export default async function HomePage() {
    const rows = await withTimeout(loadPreview(), 1500, []);
    const overviews = new Map();
    await Promise.all(rows.map(async row => {
        const map = await ingest([row.lead], { theater: row.id, warm: 1 }).catch(() => new Map());
        map.forEach((v, k) => overviews.set(k, v));
    }));
    const latest = await withTimeout(latestReports(6), 2500, []);
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
                            <ul className="pv-list" id="previewList">
                                {rows.length ? rows.map(row => {
                                    const overview = overviews.get(reportSlug(row.lead.title, row.lead.url));
                                    return (
                                        <li key={row.id}>
                                            <Link className="pv-item" href={'/report/' + reportSlug(row.lead.title, row.lead.url)} prefetch={false}>
                                                <span className="pv-tag">{THEATERS[row.id].title}</span>
                                                <span className="pv-title" dir="auto">{overview ? overview.title : row.lead.title}</span>
                                                <span className="pv-meta">{row.lead.source} &middot; {timeAgo(row.lead.publishedAt)}</span>
                                            </Link>
                                        </li>
                                    );
                                }) : [0, 1, 2, 3].map(i => <li key={i} className="pv-skel" />)}
                            </ul>
                        </div>
                        <div className="pv-card pv-float pv-a"><i className="ph ph-compass" /><div><b>Explore</b><small>Live search</small></div></div>
                        <div className="pv-card pv-float pv-b"><i className="ph ph-seal-check" /><div><b>Vetted sources</b><small>18</small></div></div>
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
                        <span className="svc-text"><b>Explore</b><small>Search 18 vetted sources.</small></span>
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
                            <Link href="/articles#write" className="btn-ghost"><i className="ph ph-pen-nib" /> <span>Write for VERO</span></Link>
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
VERO_EOF_11
echo "yazildi: app/page.js"

mkdir -p "app/privacy"
cat > "app/privacy/page.js" <<'VERO_EOF_12'
import DocPage from '@/components/DocPage';
import { LEGAL } from '@/content/legal';
import { SITE_NAME } from '@/lib/site';

const doc = LEGAL.privacy;

export const metadata = {
    title: doc.title,
    description: doc.lead,
    alternates: { canonical: '/privacy' },
    openGraph: { title: doc.title + ' | ' + SITE_NAME, description: doc.lead, url: '/privacy', type: 'article' }
};

export default function Page() {
    return <DocPage doc={doc} />;
}
VERO_EOF_12
echo "yazildi: app/privacy/page.js"

mkdir -p "app/report/[slug]"
cat > "app/report/[slug]/page.js" <<'VERO_EOF_13'
import Link from 'next/link';
import { notFound } from 'next/navigation';
import ReportCard from '@/components/ReportCard';
import { THEATERS, isTheater } from '@/content/theaters';
import { CATEGORIES, clip, formatDate, jsonLd, proxied, timeAgo, validCover } from '@/lib/format';
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
VERO_EOF_13
echo "yazildi: app/report/[slug]/page.js"

mkdir -p "app"
cat > "app/robots.js" <<'VERO_EOF_14'
import { SITE_URL } from '@/lib/site';

export default function robots() {
    return {
        rules: [{ userAgent: '*', allow: '/', disallow: ['/api/'] }],
        sitemap: SITE_URL + '/sitemap.xml'
    };
}
VERO_EOF_14
echo "yazildi: app/robots.js"

mkdir -p "app"
cat > "app/sitemap.js" <<'VERO_EOF_15'
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
VERO_EOF_15
echo "yazildi: app/sitemap.js"

mkdir -p "app/terms"
cat > "app/terms/page.js" <<'VERO_EOF_16'
import DocPage from '@/components/DocPage';
import { LEGAL } from '@/content/legal';
import { SITE_NAME } from '@/lib/site';

const doc = LEGAL.terms;

export const metadata = {
    title: doc.title,
    description: doc.lead,
    alternates: { canonical: '/terms' },
    openGraph: { title: doc.title + ' | ' + SITE_NAME, description: doc.lead, url: '/terms', type: 'article' }
};

export default function Page() {
    return <DocPage doc={doc} />;
}
VERO_EOF_16
echo "yazildi: app/terms/page.js"

mkdir -p "components"
cat > "components/Backdrop.js" <<'VERO_EOF_17'
export default function Backdrop() {
    return (
        <div className="backdrop" aria-hidden="true">
            <svg className="bd-shapes" viewBox="0 0 1440 900" preserveAspectRatio="xMidYMid slice" focusable="false">
                <polygon className="bd-a" points="1440,0 1440,560 960,0" />
                <polygon className="bd-b" points="0,900 0,380 560,900" />
                <polygon className="bd-c" points="1440,900 1440,700 1180,900" />
                <path className="bd-line" d="M1020 0 L1440 590" />
                <path className="bd-line" d="M0 330 L580 900" />
                <path className="bd-v" d="M1120 150 L1215 345 L1310 150" />
            </svg>
            <div className="bd-grid" />
            <div className="bd-glow" />
        </div>
    );
}
VERO_EOF_17
echo "yazildi: components/Backdrop.js"

mkdir -p "components"
cat > "components/CoverImage.js" <<'VERO_EOF_18'
'use client';

import { useEffect, useRef, useState } from 'react';

export default function CoverImage({ src, eager = false }) {
    const [failed, setFailed] = useState(false);
    const ref = useRef(null);

    useEffect(() => {
        const img = ref.current;
        if (img && img.complete && img.naturalWidth === 0) setFailed(true);
    }, []);

    if (failed) return <i className="ph ph-globe-hemisphere-west cover-fallback" aria-hidden="true" />;
    return (
        <img
            ref={ref}
            className="ready"
            src={src}
            alt=""
            loading={eager ? 'eager' : 'lazy'}
            decoding="async"
            referrerPolicy="no-referrer"
            onError={() => setFailed(true)}
        />
    );
}
VERO_EOF_18
echo "yazildi: components/CoverImage.js"

mkdir -p "components"
cat > "components/DocPage.js" <<'VERO_EOF_19'
import Link from 'next/link';
import { LEGAL, LEGAL_ORDER } from '@/content/legal';

function formatDate(value) {
    return new Date(value + 'T00:00:00Z').toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric', timeZone: 'UTC' });
}

const ICONS = { methodology: 'ph-book-open-text', privacy: 'ph-shield-check', terms: 'ph-file-text' };

export default function DocPage({ doc }) {
    const others = LEGAL_ORDER.filter(slug => slug !== doc.slug);
    return (
        <main className="doc-page">
            <header className="doc-head">
                <p className="doc-eyebrow">VERO</p>
                <h1>{doc.title}</h1>
                <p className="doc-lead">{doc.lead}</p>
                <p className="doc-meta">Last updated {formatDate(doc.updated)}</p>
            </header>
            <div className="doc-layout">
                <nav className="doc-toc" aria-label="On this page">
                    <p>On this page</p>
                    <ul>
                        {doc.sections.map(section => (
                            <li key={section.id}><a href={'#' + section.id}>{section.title}</a></li>
                        ))}
                    </ul>
                </nav>
                <article className="doc-body">
                    {doc.sections.map(section => (
                        <section key={section.id} id={section.id}>
                            <h2>{section.title}</h2>
                            {section.body.map((paragraph, index) => (
                                <p key={index}>{paragraph}</p>
                            ))}
                        </section>
                    ))}
                </article>
            </div>
            <div className="doc-links">
                {others.map(slug => (
                    <Link key={slug} href={'/' + slug} className="btn-ghost">
                        <i className={'ph ' + ICONS[slug]} /> <span>{LEGAL[slug].title}</span>
                    </Link>
                ))}
            </div>
        </main>
    );
}
VERO_EOF_19
echo "yazildi: components/DocPage.js"

mkdir -p "components"
cat > "components/FilterDrawer.js" <<'VERO_EOF_20'
'use client';

import { useEffect, useRef, useState } from 'react';

export default function FilterDrawer({ count = 0, children }) {
    const [open, setOpen] = useState(false);
    const [wide, setWide] = useState(false);
    const panelRef = useRef(null);
    const openerRef = useRef(null);

    useEffect(() => {
        const mq = window.matchMedia('(min-width: 1100px)');
        const sync = () => {
            setWide(mq.matches);
            if (mq.matches) setOpen(false);
        };
        sync();
        mq.addEventListener('change', sync);
        return () => mq.removeEventListener('change', sync);
    }, []);

    useEffect(() => {
        document.documentElement.classList.toggle('filters-open', open);
        return () => document.documentElement.classList.remove('filters-open');
    }, [open]);

    useEffect(() => {
        if (!open) return undefined;
        const onKey = event => {
            if (event.key === 'Escape') setOpen(false);
        };
        document.addEventListener('keydown', onKey);
        return () => document.removeEventListener('keydown', onKey);
    }, [open]);

    useEffect(() => {
        if (open && panelRef.current) {
            const first = panelRef.current.querySelector('.filter-btn.active') || panelRef.current.querySelector('a, button');
            if (first) first.focus({ preventScroll: true });
        } else if (!open && openerRef.current && typeof openerRef.current.focus === 'function') {
            openerRef.current.focus({ preventScroll: true });
            openerRef.current = null;
        }
    }, [open]);

    function toggle() {
        if (!open) openerRef.current = document.activeElement;
        setOpen(value => !value);
    }

    return (
        <>
            <div className="filter-bar">
                <button type="button" className="filter-toggle" aria-expanded={open} aria-controls="filterPanel" onClick={toggle}>
                    <i className="ph ph-funnel-simple" />
                    <span>Filters</span>
                    {count > 0 ? <span className="filter-count">{count}</span> : null}
                </button>
            </div>
            <aside
                className={'filter-panel' + (open ? ' open' : '')}
                id="filterPanel"
                aria-label="Filters"
                ref={panelRef}
                inert={!wide && !open}
                onClick={event => {
                    if (event.target.closest('a')) setOpen(false);
                }}
            >
                <div className="filter-head">
                    <h2>Filters</h2>
                    <button type="button" className="filter-close" aria-label="Close filters" onClick={() => setOpen(false)}>
                        <i className="ph ph-x" />
                    </button>
                </div>
                {children}
                <button type="button" className="filter-apply" onClick={() => setOpen(false)}>Show results</button>
            </aside>
            <div className={'filter-scrim' + (open ? ' show' : '')} onClick={() => setOpen(false)} />
        </>
    );
}
VERO_EOF_20
echo "yazildi: components/FilterDrawer.js"

mkdir -p "components"
cat > "components/Footer.js" <<'VERO_EOF_21'
import Link from 'next/link';
import { CONTACT_EMAIL, DEV_EMAIL, DISCORD_URL } from '@/lib/site';

export default function Footer() {
    return (
        <footer className="site-footer">
            <div className="banner-wrap">
                <img src="/assets/BANNER.png" width="1584" height="672" loading="lazy" decoding="async" alt="VERO Banner" className="banner-img" />
            </div>
            <div className="footer-grid">
                <div className="footer-brand">
                    <div className="brand-line">
                        <img src="/assets/logo-192.webp" width="44" height="44" alt="VERO" className="brand-logo" />
                        <span>VERO</span>
                    </div>
                    <p>Independent global intelligence and diplomatic monitoring observatory.</p>
                </div>
                <div className="footer-col">
                    <h4>Explore</h4>
                    <Link href="/live"><i className="ph ph-broadcast" /> <span>Live</span></Link>
                    <Link href="/explore"><i className="ph ph-compass" /> <span>Explore</span></Link>
                    <Link href="/articles"><i className="ph ph-newspaper" /> <span>Articles</span></Link>
                </div>
                <div className="footer-col">
                    <h4>Transparency</h4>
                    <Link href="/methodology"><i className="ph ph-book-open-text" /> <span>Sources &amp; Methodology</span></Link>
                    <Link href="/privacy"><i className="ph ph-shield-check" /> <span>Privacy Policy</span></Link>
                    <Link href="/terms"><i className="ph ph-file-text" /> <span>Terms of Service</span></Link>
                </div>
                <div className="footer-col">
                    <h4>Contact</h4>
                    <a href={'mailto:' + CONTACT_EMAIL}><i className="ph ph-envelope-simple" /> <span><small>Secure Email</small>{CONTACT_EMAIL}</span></a>
                    <a href={'mailto:' + DEV_EMAIL}><i className="ph ph-envelope-simple-open" /> <span><small>Developers Email</small>{DEV_EMAIL}</span></a>
                    <a href={DISCORD_URL} target="_blank" rel="noopener noreferrer"><i className="ph ph-discord-logo" /> <span><small>Community</small>Discord server</span></a>
                </div>
            </div>
            <div className="footer-bottom">
                <span>© 2026 VERO</span>
                <span>All rights reserved.</span>
            </div>
        </footer>
    );
}
VERO_EOF_21
echo "yazildi: components/Footer.js"

mkdir -p "components"
cat > "components/HomeSearch.js" <<'VERO_EOF_22'
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function HomeSearch() {
    const router = useRouter();
    const [value, setValue] = useState('');

    function submit(event) {
        event.preventDefault();
        const q = value.trim().slice(0, 120);
        router.push(q ? '/explore?q=' + encodeURIComponent(q) : '/explore');
    }

    return (
        <form className="home-search" role="search" autoComplete="off" onSubmit={submit}>
            <div className="search-bar massive">
                <i className="ph ph-magnifying-glass search-icon" />
                <input type="text" value={value} onChange={event => setValue(event.target.value)} maxLength={120} autoComplete="off" spellCheck={false} placeholder="Search any region, leader or crisis" aria-label="Search" />
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
            </div>
        </form>
    );
}
VERO_EOF_22
echo "yazildi: components/HomeSearch.js"

mkdir -p "components"
cat > "components/Nav.js" <<'VERO_EOF_23'
'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { DISCORD_URL } from '@/lib/site';

const LINKS = [
    { href: '/live', label: 'Live' },
    { href: '/explore', label: 'Explore' },
    { href: '/articles', label: 'Articles' }
];

function systemTheme() {
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark';
}

function storedTheme() {
    try {
        return localStorage.getItem('vero_theme');
    } catch {
        return null;
    }
}

export default function Nav() {
    const pathname = usePathname();
    const [open, setOpen] = useState(false);
    const [scrolled, setScrolled] = useState(false);
    const [theme, setTheme] = useState(null);

    const applyTheme = useCallback((next, persist) => {
        document.documentElement.setAttribute('data-theme', next);
        if (persist) {
            try {
                localStorage.setItem('vero_theme', next);
            } catch {
                setTheme(next);
            }
        }
        setTheme(next);
    }, []);

    useEffect(() => {
        setTheme(document.documentElement.getAttribute('data-theme') === 'light' ? 'light' : 'dark');
        if (!window.matchMedia) return undefined;
        const mq = window.matchMedia('(prefers-color-scheme: light)');
        const follow = () => {
            const saved = storedTheme();
            if (saved !== 'light' && saved !== 'dark') applyTheme(systemTheme(), false);
        };
        mq.addEventListener('change', follow);
        return () => mq.removeEventListener('change', follow);
    }, [applyTheme]);

    useEffect(() => {
        let ticking = false;
        const onScroll = () => {
            if (ticking) return;
            ticking = true;
            requestAnimationFrame(() => {
                setScrolled(window.scrollY > 40);
                ticking = false;
            });
        };
        window.addEventListener('scroll', onScroll, { passive: true });
        onScroll();
        return () => window.removeEventListener('scroll', onScroll);
    }, []);

    useEffect(() => {
        setOpen(false);
    }, [pathname]);

    function toggleTheme() {
        const current = document.documentElement.getAttribute('data-theme');
        applyTheme(current === 'dark' ? 'light' : 'dark', true);
    }

    return (
        <nav className={'nav-container' + (scrolled ? ' scrolled' : '')} id="navbar">
            <Link href="/" className="brand" aria-label="VERO">
                <img src="/assets/logo-96.webp" srcSet="/assets/logo-96.webp 1x, /assets/logo-192.webp 2x" width="36" height="36" alt="VERO" className="brand-logo" />
                <span>VERO</span>
            </Link>
            <div className={'nav-menu' + (open ? ' open' : '')} id="navMenu">
                <div className="nav-center" id="navLinks">
                    {LINKS.map(link => {
                        const active = pathname === link.href || pathname.startsWith(link.href + '/');
                        return (
                            <Link key={link.href} href={link.href} className={'nav-link' + (active ? ' active' : '')} aria-current={active ? 'page' : undefined} onClick={() => setOpen(false)}>
                                <span>{link.label}</span>
                            </Link>
                        );
                    })}
                </div>
                <div className="nav-tools" id="navTools">
                    <a href={DISCORD_URL} className="btn-nav" target="_blank" rel="noopener noreferrer">Discord</a>
                    <button id="themeToggle" className="theme-toggle-btn" type="button" aria-label="Toggle theme" onClick={toggleTheme}>
                        <i className={theme === 'dark' ? 'ph ph-sun' : 'ph ph-moon'} id="themeIcon" />
                    </button>
                </div>
            </div>
            <button className="nav-toggle" id="navBurger" type="button" aria-expanded={open} aria-controls="navMenu" aria-label="Menu" onClick={() => setOpen(value => !value)}>
                <i className="ph ph-list" />
            </button>
        </nav>
    );
}
VERO_EOF_23
echo "yazildi: components/Nav.js"

mkdir -p "components"
cat > "components/NotFoundPath.js" <<'VERO_EOF_24'
'use client';

import { usePathname } from 'next/navigation';

export default function NotFoundPath() {
    const pathname = usePathname();
    return <span className="nf-path" dir="ltr">{String(pathname || '').slice(0, 120)}</span>;
}
VERO_EOF_24
echo "yazildi: components/NotFoundPath.js"

mkdir -p "components"
cat > "components/Pagination.js" <<'VERO_EOF_25'
import Link from 'next/link';

function sequence(current, total) {
    if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
    const pages = [...new Set([1, 2, current - 1, current, current + 1, total - 1, total])].filter(p => p >= 1 && p <= total).sort((a, b) => a - b);
    const out = [];
    pages.forEach((p, i) => {
        if (i > 0 && p - pages[i - 1] > 1) out.push('gap-' + p);
        out.push(p);
    });
    return out;
}

export default function Pagination({ page, totalPages, hrefFor }) {
    if (totalPages <= 1) return null;
    const prev = page > 1;
    const next = page < totalPages;
    return (
        <nav className="pagination" aria-label="Pagination">
            {prev ? (
                <Link className="page-arrow" href={hrefFor(page - 1)} aria-label="Previous page" prefetch={false}><i className="ph ph-caret-left" /></Link>
            ) : (
                <span className="page-arrow" aria-disabled="true"><i className="ph ph-caret-left" /></span>
            )}
            <div className="page-center">
                <div className="page-numbers">
                    {sequence(page, totalPages).map(p => (
                        typeof p === 'string' ? (
                            <span key={p} className="page-gap">&hellip;</span>
                        ) : (
                            <Link key={p} className={'page-num' + (p === page ? ' active' : '')} href={hrefFor(p)} aria-current={p === page ? 'page' : undefined} prefetch={false}>{p}</Link>
                        )
                    ))}
                </div>
            </div>
            {next ? (
                <Link className="page-arrow" href={hrefFor(page + 1)} aria-label="Next page" prefetch={false}><i className="ph ph-caret-right" /></Link>
            ) : (
                <span className="page-arrow" aria-disabled="true"><i className="ph ph-caret-right" /></span>
            )}
        </nav>
    );
}
VERO_EOF_25
echo "yazildi: components/Pagination.js"

mkdir -p "components"
cat > "components/ReportCard.js" <<'VERO_EOF_26'
import Link from 'next/link';
import CoverImage from '@/components/CoverImage';
import { CATEGORIES, clip, formatDate, proxied, validCover } from '@/lib/format';
import { reportSlug } from '@/lib/slug';

export default function ReportCard({ item, overview, eager = false }) {
    const cat = CATEGORIES[item.cat] || CATEGORIES.intel;
    const image = validCover(item.image) ? proxied(item.image) : null;
    const stored = !item.web;
    const title = overview ? overview.title : item.title;
    const description = overview
        ? clip(overview.summary, 170)
        : clip(item.description, 150) || 'Open the report for the full story from the original publisher.';

    const body = (
        <>
            <div className={'card-banner' + (image ? '' : ' noimg')}>
                <div className="card-tag"><i className={'ph ' + cat.icon} /> {cat.label}</div>
                {image ? <CoverImage src={image} eager={eager} /> : <i className="ph ph-globe-hemisphere-west cover-fallback" aria-hidden="true" />}
            </div>
            <div className="card-content">
                <span className="card-date">{formatDate(item.publishedAt) || 'Recent'}</span>
                <h3 className="card-title" dir="auto">{title}</h3>
                <p className="card-desc" dir="auto">{description}</p>
                <div className="card-footer">
                    <div className="source-info">
                        <i className="ph ph-newspaper-clipping" />
                        <span>{item.source || ''}</span>
                        {item.web ? <span className="web-tag">Web</span> : null}
                    </div>
                    <div className="read-more">{stored ? 'Read overview' : 'Read source'} <i className="ph ph-arrow-up-right" /></div>
                </div>
            </div>
        </>
    );

    if (stored) {
        return <Link href={'/report/' + reportSlug(item.title, item.url)} className="card" prefetch={false}>{body}</Link>;
    }
    return <a href={item.url} className="card" target="_blank" rel="noopener noreferrer">{body}</a>;
}
VERO_EOF_26
echo "yazildi: components/ReportCard.js"

mkdir -p "components"
cat > "components/TheaterCard.js" <<'VERO_EOF_27'
import Link from 'next/link';
import { THEATERS } from '@/content/theaters';
import { timeAgo } from '@/lib/format';
import { reportSlug } from '@/lib/slug';

const TAGS = { breaking: 'Breaking news', new: 'New', latest: 'Latest' };

function LiveBox({ data, overview }) {
    if (!data || !data.lead) return null;
    const lead = data.lead;
    const title = overview ? overview.title : lead.title;
    return (
        <Link className="theater-live" href={'/report/' + reportSlug(lead.title, lead.url)} prefetch={false}>
            <div className="live-head">
                <span className={'live-tag ' + data.tag}>{TAGS[data.tag] || 'Latest'}</span>
                <span className="live-time">{timeAgo(lead.publishedAt)}</span>
            </div>
            <span className="live-title" dir="auto">{title}</span>
            <div className="live-foot">
                <span>{lead.source || ''}</span>
                <span className="go">Read overview <i className="ph ph-arrow-up-right" /></span>
            </div>
            <div className="live-meta">
                <span>Reports (24h): <b>{data.count24h}</b></span>
                <span>Sources: <b>{data.sources24h}</b></span>
            </div>
        </Link>
    );
}

function Cover({ className, cover, children }) {
    return (
        <div className={className + (cover ? ' has-photo' : '')}>
            {cover ? <img className="cover-live ready" src={cover.url} alt="" loading="lazy" decoding="async" referrerPolicy="no-referrer" /> : null}
            {children}
            {cover && cover.label ? (
                <a className="cover-credit" href={cover.page} target="_blank" rel="noopener noreferrer">{cover.label}</a>
            ) : null}
        </div>
    );
}

export function TheaterCard({ id, data, overview }) {
    const t = THEATERS[id];
    if (!t) return null;
    const cover = data && data.cover ? data.cover : null;
    return (
        <article className="theater-card" data-theater={id}>
            <Cover className={'theater-cover ' + t.cover} cover={cover}>
                <div className={'theater-badge ' + t.tone}><i className={'ph ' + t.icon} /> {t.badge}</div>
            </Cover>
            <div className="theater-info">
                <h3><Link href={'/live/' + id}>{t.title}</Link></h3>
                <span className="theater-overview-label">VERO Overview</span>
                <p className="theater-desc">{t.desc}</p>
                <div className="theater-stats">
                    {t.stats.map(stat => (
                        <div className="stat-box" key={stat.label}>
                            <span className="stat-label">{stat.label}</span>
                            <span className={'stat-val' + (stat.tone ? ' ' + stat.tone : '')}>{stat.value}</span>
                        </div>
                    ))}
                </div>
                <LiveBox data={data} overview={overview} />
                <div className="theater-actions">
                    <Link href={'/explore?q=' + encodeURIComponent(t.query)} className="btn-theater-action" prefetch={false}>
                        <i className="ph ph-arrows-clockwise" /> Explore reports
                    </Link>
                    {t.map ? (
                        <a href={t.map} target="_blank" rel="noopener noreferrer" className="theater-link">Live Map <i className="ph ph-arrow-square-out" /></a>
                    ) : null}
                </div>
            </div>
        </article>
    );
}

export function DevelopingCard({ card, overview }) {
    const data = { lead: card.lead, tag: card.tag, count24h: card.count24h, sources24h: card.sources24h };
    const cover = card.cover || null;
    return (
        <article className="theater-card" data-dev={card.id}>
            <Cover className="theater-cover cv-dev" cover={cover}>
                <div className="theater-badge warning"><i className="ph ph-trend-up" /> Developing</div>
            </Cover>
            <div className="theater-info">
                <h3 dir="auto">{card.title}</h3>
                <span className="theater-overview-label">Gaining coverage</span>
                <LiveBox data={data} overview={overview} />
                <div className="theater-actions">
                    <Link href={'/explore?q=' + encodeURIComponent(card.query || card.title)} className="btn-theater-action" prefetch={false}>
                        <i className="ph ph-arrows-clockwise" /> Explore reports
                    </Link>
                </div>
            </div>
        </article>
    );
}
VERO_EOF_27
echo "yazildi: components/TheaterCard.js"

mkdir -p "content"
cat > "content/legal.js" <<'VERO_EOF_28'
import { CONTACT_EMAIL, LEGAL_UPDATED } from '@/lib/site';

export const LEGAL = {
    methodology: {
        slug: 'methodology',
        title: 'Sources & Methodology',
        lead: 'How information reaches VERO, how outlets are chosen and what VERO never does.',
        updated: LEGAL_UPDATED,
        sections: [
            {
                id: 'how-information-reaches-vero',
                title: 'How information reaches VERO',
                body: [
                    'VERO does not write news. It reads the public RSS feeds that vetted outlets publish and adds results from a licensed news aggregation interface. Only outlets on the vetted list can appear. Every report is shown in the language its publisher used.'
                ]
            },
            {
                id: 'how-outlets-are-chosen',
                title: 'How outlets are chosen',
                body: [
                    'VERO selects established outlets with a public editorial process, a large audience and a track record of issuing corrections. Perspectives are deliberately mixed: Arab regional media, European public and independent media, United Nations reporting, and US-based wire services and non-profit broadcasters.',
                    'No outlet is perfectly neutral, and VERO does not claim otherwise. Some outlets on the list are funded or owned by states or state-linked groups. They are included for regional perspective, and the region of each outlet is shown so that readers can weigh its viewpoint.',
                    'When the vetted sources hold little on a topic, Explore adds reports from the wider web. These are labeled Web and are not part of the vetted list.'
                ]
            },
            {
                id: 'how-results-are-ranked',
                title: 'How results are compared and ranked',
                body: [
                    'Results are ranked by how closely a headline and description match the search, how relevant they are to geopolitics, and how recent they are. Duplicate headlines are removed. Different reports are never merged, rewritten or summarized into one, so differences between outlets stay visible.'
                ]
            },
            {
                id: 'vero-overviews',
                title: 'VERO overviews',
                body: [
                    'Every report on VERO has its own page. The page opens with a VERO overview: a short, original summary that places the report in context, followed by the publisher\u2019s headline and a link to the full report. An overview never replaces the original and is never presented as the publisher\u2019s own words.'
                ]
            },
            {
                id: 'what-vero-does-not-do',
                title: 'What VERO does not do',
                body: [
                    'VERO does not copy full articles, bypass paywalls, use anonymous blogs or social media posts as sources, or sell placement. Every report links to the original publisher.'
                ]
            },
            {
                id: 'corrections',
                title: 'Corrections',
                body: [
                    'If a page appears misleading, or a source should be added or removed, report it by email to ' + CONTACT_EMAIL + ' or in the VERO Discord server.'
                ]
            }
        ]
    },
    privacy: {
        slug: 'privacy',
        title: 'Privacy Policy',
        lead: 'What VERO collects, why, and the control you keep.',
        updated: LEGAL_UPDATED,
        sections: [
            {
                id: 'scope',
                title: 'Scope',
                body: [
                    'This policy describes how VERO processes personal data when the site is visited, searched, or used through an account.'
                ]
            },
            {
                id: 'visitors',
                title: 'Visitors',
                body: [
                    'VERO uses Google Analytics to measure anonymous, aggregate usage such as pages viewed, device type and approximate region. Cookies may be set for this purpose. The hosting provider processes IP addresses in server logs as part of normal operation. Personal data is never sold.'
                ]
            },
            {
                id: 'search',
                title: 'Search',
                body: [
                    'Search terms are sent to the news provider to return relevant reports. Searches are not stored in the VERO database. Recent searches and the theme choice remain in the visitor\u2019s own browser and can be cleared at any time.'
                ]
            },
            {
                id: 'accounts',
                title: 'Accounts',
                body: [
                    'Accounts are available to persons aged 13 or older. VERO stores a username, an email address, a date of birth, and an optional display name, photo and short bio. The date of birth is used only to apply age requirements and is never displayed.',
                    'The username, display name, photo, bio, badges, articles, edits, comments and follower counts are public. The email address is never displayed.'
                ]
            },
            {
                id: 'sign-in',
                title: 'Sign-in',
                body: [
                    'VERO has no passwords. To sign in, VERO emails a one-time code to the address on the account. A code expires after ten minutes and works once. Email is delivered through Resend, which processes the address for that purpose.'
                ]
            },
            {
                id: 'sessions-and-security',
                title: 'Sessions and security',
                body: [
                    'After sign-in, VERO sets a secure session cookie and creates a cryptographic key that stays in the browser on that device. Requests are signed with that key, so a copied cookie does not work on another device. Signing out ends the session. Traffic is encrypted and administrative access is restricted.'
                ]
            },
            {
                id: 'activity-and-notifications',
                title: 'Activity and notifications',
                body: [
                    'Articles, edit proposals, comments, reactions and follows are stored to operate the service. Articles and the history of their edits are public. In-app notifications can be switched off, in whole or by type, in the account settings. Browser alerts are shown only with the user\u2019s permission.'
                ]
            },
            {
                id: 'messages',
                title: 'Messages',
                body: [
                    'Messages sent to VERO by email are used only to reply and to improve the service.'
                ]
            },
            {
                id: 'providers',
                title: 'Providers',
                body: [
                    'VERO relies on a small number of providers: the hosting provider, Google Analytics, Resend for email delivery, and news providers for reports. Each processes data under its own terms.'
                ]
            },
            {
                id: 'retention-and-rights',
                title: 'Retention and rights',
                body: [
                    'An account and all associated content can be deleted at any time in the account settings. Access, correction or deletion of personal data can also be requested by email to ' + CONTACT_EMAIL + '.'
                ]
            },
            {
                id: 'changes',
                title: 'Changes',
                body: [
                    'This policy may be updated. The date above shows the latest version.'
                ]
            }
        ]
    },
    terms: {
        slug: 'terms',
        title: 'Terms of Service',
        lead: 'The rules for using VERO.',
        updated: LEGAL_UPDATED,
        sections: [
            {
                id: 'service',
                title: 'Service',
                body: [
                    'VERO is an information service that organizes public reporting. It is not legal, financial, military or investment advice. Original reports remain the property of their publishers.'
                ]
            },
            {
                id: 'accounts',
                title: 'Accounts',
                body: [
                    'Users must be at least 13 years old and must provide accurate information. An account is tied to a verified email address at a supported provider. Impersonation, harassment, spam and unlawful content are prohibited. VERO may remove content or suspend accounts that breach these terms.'
                ]
            },
            {
                id: 'articles',
                title: 'Articles',
                body: [
                    'Articles may be published by adults with a verified email address. Authors keep the copyright of their work and grant VERO a non-exclusive licence to publish and display it. Articles are published without prior review and express the views of their authors, not of VERO. VERO may remove an article that breaches these terms.'
                ]
            },
            {
                id: 'edit-proposals',
                title: 'Edit proposals',
                body: [
                    'Members can propose edits to an article. A proposal appears as its own thread beside the original, with its own reactions and comments, and never changes the original article. Proposals follow the same rules as articles.'
                ]
            },
            {
                id: 'comments',
                title: 'Comments',
                body: [
                    'Comments must be respectful and relevant. VERO may delete comments that breach these terms.'
                ]
            },
            {
                id: 'ownership',
                title: 'Ownership',
                body: [
                    'The VERO name, logo, design and software are the property of VERO. All rights reserved. Content from third-party publishers belongs to those publishers.'
                ]
            },
            {
                id: 'links-and-availability',
                title: 'Links and availability',
                body: [
                    'VERO links to third-party sites and is not responsible for their content. The service is provided as is, without warranty, and may change or be interrupted without notice.'
                ]
            },
            {
                id: 'changes',
                title: 'Changes',
                body: [
                    'These terms may be updated. Continued use of the site constitutes acceptance of the current version.'
                ]
            }
        ]
    }
};

export const LEGAL_ORDER = ['methodology', 'privacy', 'terms'];
VERO_EOF_28
echo "yazildi: content/legal.js"

mkdir -p "content"
cat > "content/theaters.js" <<'VERO_EOF_29'
export const THEATER_SECTIONS = [
    {
        key: "war",
        title: "War Theaters",
        icon: "ph-crosshair",
        sub: "Active fronts, each with a live map.",
        ids: ["ukraine", "mideast", "yemen", "syria", "lebanon", "sudan"]
    },
    {
        key: "strategic",
        title: "Strategic Watch",
        icon: "ph-binoculars",
        sub: "Diplomatic and economic flashpoints.",
        ids: ["taiwan", "brics", "korea", "sahel"]
    }
];

export const THEATERS = {
    ukraine: {
        "id": "ukraine",
        "cover": "cv-ukraine",
        "tone": "danger",
        "icon": "ph-warning-diamond",
        "badge": "Active War Zone",
        "title": "Russo-Ukrainian Conflict",
        "desc": "Frontline monitoring, territory changes, and tactical air/artillery activity.",
        "stats": [
                {
                        "label": "Artillery Posture",
                        "value": "Heavy",
                        "tone": "alert"
                },
                {
                        "label": "Air Defense",
                        "value": "Active",
                        "tone": ""
                }
        ],
        "query": "Ukraine war Russia conflict",
        "map": "https://liveuamap.com/"
    },
    mideast: {
        "id": "mideast",
        "cover": "cv-mideast",
        "tone": "danger",
        "icon": "ph-crosshair",
        "badge": "Escalation Index",
        "title": "Middle East Conflict",
        "desc": "US-Israeli military stance, Lebanese front, Iranian proxy strikes, and naval security.",
        "stats": [
                {
                        "label": "Interceptions",
                        "value": "Active",
                        "tone": "alert"
                },
                {
                        "label": "Naval Posture",
                        "value": "CSG Deployed",
                        "tone": ""
                }
        ],
        "query": "Israel Lebanon Iran Middle East",
        "map": "https://israelpalestine.liveuamap.com/"
    },
    yemen: {
        "id": "yemen",
        "cover": "cv-yemen",
        "tone": "danger",
        "icon": "ph-anchor",
        "badge": "Chokepoint Crisis",
        "title": "Yemeni Civil War & Red Sea",
        "desc": "Houthi anti-ship ballistic missile strikes, naval coalition defenses, and maritime trade disruption.",
        "stats": [
                {
                        "label": "Shipping Risk",
                        "value": "Critical",
                        "tone": "alert"
                },
                {
                        "label": "Naval Escort",
                        "value": "Active",
                        "tone": ""
                }
        ],
        "query": "Yemen Houthi Red Sea military",
        "map": "https://yemen.liveuamap.com/"
    },
    syria: {
        "id": "syria",
        "cover": "cv-syria",
        "tone": "danger",
        "icon": "ph-flag-banner",
        "badge": "Transition Watch",
        "title": "Syria, Israel & the Druze",
        "desc": "Transitional authorities, Suwayda tensions, Israeli strikes and the Golan line.",
        "stats": [
                {
                        "label": "Transition",
                        "value": "Fragile",
                        "tone": "alert"
                },
                {
                        "label": "Southern Front",
                        "value": "Tense",
                        "tone": ""
                }
        ],
        "query": "Syria Israel Druze Suwayda",
        "map": "https://syria.liveuamap.com/"
    },
    lebanon: {
        "id": "lebanon",
        "cover": "cv-lebanon",
        "tone": "danger",
        "icon": "ph-crosshair",
        "badge": "Border Front",
        "title": "Lebanon, Israel & Hezbollah",
        "desc": "South Lebanon strikes, ceasefire terms, Hezbollah disarmament and reconstruction.",
        "stats": [
                {
                        "label": "Ceasefire",
                        "value": "Contested",
                        "tone": "alert"
                },
                {
                        "label": "Border Strikes",
                        "value": "Ongoing",
                        "tone": ""
                }
        ],
        "query": "Lebanon Israel Hezbollah ceasefire",
        "map": "https://lebanon.liveuamap.com/"
    },
    sudan: {
        "id": "sudan",
        "cover": "cv-sudan",
        "tone": "danger",
        "icon": "ph-first-aid",
        "badge": "Humanitarian Crisis",
        "title": "Sudan War",
        "desc": "Army and Rapid Support Forces fighting, El Fasher, famine and displacement.",
        "stats": [
                {
                        "label": "Fronts",
                        "value": "Multiple",
                        "tone": "alert"
                },
                {
                        "label": "Displacement",
                        "value": "Critical",
                        "tone": ""
                }
        ],
        "query": "Sudan RSF army El Fasher",
        "map": "https://sudan.liveuamap.com/"
    },
    taiwan: {
        "id": "taiwan",
        "cover": "cv-taiwan",
        "tone": "warning",
        "icon": "ph-eye",
        "badge": "Indo-Pacific Watch",
        "title": "China - Taiwan Strait",
        "desc": "PLA naval encirclement exercises, ADIZ incursions, and US deterrence shifts.",
        "stats": [
                {
                        "label": "ADIZ Incursions",
                        "value": "Elevated",
                        "tone": "warning"
                },
                {
                        "label": "Chokepoint",
                        "value": "Monitored",
                        "tone": ""
                }
        ],
        "query": "China Taiwan US military",
        "map": ""
    },
    brics: {
        "id": "brics",
        "cover": "cv-brics",
        "tone": "info",
        "icon": "ph-currency-dollar-simple",
        "badge": "Geo-Economics",
        "title": "BRICS & Multipolarity",
        "desc": "De-dollarization initiatives, alternative payment routing, and resource corridors.",
        "stats": [
                {
                        "label": "Trade Currency",
                        "value": "Local Pivot",
                        "tone": ""
                },
                {
                        "label": "Sanctions",
                        "value": "Systemic",
                        "tone": ""
                }
        ],
        "query": "BRICS economy sanctions trade",
        "map": ""
    },
    korea: {
        "id": "korea",
        "cover": "cv-korea",
        "tone": "warning",
        "icon": "ph-warning",
        "badge": "East Asia Watch",
        "title": "Korean Peninsula",
        "desc": "Ballistic missile tests, demilitarized zone tensions, and trilateral defense pacts.",
        "stats": [
                {
                        "label": "Missile Tests",
                        "value": "Frequent",
                        "tone": "alert"
                },
                {
                        "label": "Border Status",
                        "value": "Tense",
                        "tone": ""
                }
        ],
        "query": "North Korea South Korea military",
        "map": ""
    },
    sahel: {
        "id": "sahel",
        "cover": "cv-sahel",
        "tone": "danger",
        "icon": "ph-fire",
        "badge": "High Instability",
        "title": "Sahel Region Crisis",
        "desc": "Military juntas, insurgent expansions, and shifts in foreign military influence.",
        "stats": [
                {
                        "label": "Regime Status",
                        "value": "Transitional",
                        "tone": "alert"
                },
                {
                        "label": "Insurgency",
                        "value": "Expanding",
                        "tone": ""
                }
        ],
        "query": "Sahel Africa military coup",
        "map": ""
    }
};

export const THEATER_IDS = Object.keys(THEATERS);

export function isTheater(id) {
    return Object.prototype.hasOwnProperty.call(THEATERS, id);
}
VERO_EOF_29
echo "yazildi: content/theaters.js"

cat > "jsconfig.json" <<'VERO_EOF_30'
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"]
    }
  }
}
VERO_EOF_30
echo "yazildi: jsconfig.json"

mkdir -p "lib"
cat > "lib/db.js" <<'VERO_EOF_31'
import mongoose from 'mongoose';

const KEY = Symbol.for('vero.mongo');

export default async function connect() {
    const uri = process.env.MONGODB_URI;
    if (!uri) return false;
    if (!globalThis[KEY]) {
        mongoose.set('strictQuery', true);
        globalThis[KEY] = mongoose
            .connect(uri, { serverSelectionTimeoutMS: 8000, maxPoolSize: 5 })
            .then(() => true)
            .catch(() => {
                globalThis[KEY] = null;
                return false;
            });
    }
    return globalThis[KEY];
}
VERO_EOF_31
echo "yazildi: lib/db.js"

mkdir -p "lib"
cat > "lib/device-key-client.mjs" <<'VERO_EOF_32'
const DB_NAME = 'vero-device';
const STORE_NAME = 'keys';
const KEY_ID = 'primary';

function toBase64Url(bytes) {
    let bin = '';
    for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i]);
    return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function indexedDbStore() {
    function open() {
        return new Promise((resolve, reject) => {
            const req = indexedDB.open(DB_NAME, 1);
            req.onupgradeneeded = () => req.result.createObjectStore(STORE_NAME);
            req.onsuccess = () => resolve(req.result);
            req.onerror = () => reject(req.error);
        });
    }
    return {
        async get(id) {
            const db = await open();
            return new Promise((resolve, reject) => {
                const r = db.transaction(STORE_NAME, 'readonly').objectStore(STORE_NAME).get(id);
                r.onsuccess = () => resolve(r.result || null);
                r.onerror = () => reject(r.error);
            });
        },
        async set(id, value) {
            const db = await open();
            return new Promise((resolve, reject) => {
                const tx = db.transaction(STORE_NAME, 'readwrite');
                tx.objectStore(STORE_NAME).put(value, id);
                tx.oncomplete = () => resolve();
                tx.onerror = () => reject(tx.error);
            });
        },
        async remove(id) {
            const db = await open();
            return new Promise((resolve, reject) => {
                const tx = db.transaction(STORE_NAME, 'readwrite');
                tx.objectStore(STORE_NAME).delete(id);
                tx.oncomplete = () => resolve();
                tx.onerror = () => reject(tx.error);
            });
        }
    };
}

export function createDeviceKey({
    store,
    subtle = globalThis.crypto.subtle,
    getRandomValues = bytes => globalThis.crypto.getRandomValues(bytes),
    now = () => Date.now()
} = {}) {
    const keyStore = store || indexedDbStore();
    let cached = null;

    async function ensure() {
        if (cached) return cached;
        const saved = await keyStore.get(KEY_ID);
        if (saved && saved.privateKey && saved.publicJwk) {
            cached = saved;
            return cached;
        }
        const pair = await subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, false, ['sign', 'verify']);
        const jwk = await subtle.exportKey('jwk', pair.publicKey);
        cached = { privateKey: pair.privateKey, publicJwk: { kty: jwk.kty, crv: jwk.crv, x: jwk.x, y: jwk.y } };
        await keyStore.set(KEY_ID, cached);
        return cached;
    }

    async function publicJwk() {
        return (await ensure()).publicJwk;
    }

    async function sign(method, path) {
        const { privateKey } = await ensure();
        const ts = String(now());
        const nonceBytes = new Uint8Array(16);
        getRandomValues(nonceBytes);
        const nonce = toBase64Url(nonceBytes);
        const data = new TextEncoder().encode([String(method).toUpperCase(), String(path), ts, nonce].join('\n'));
        const sig = await subtle.sign({ name: 'ECDSA', hash: 'SHA-256' }, privateKey, data);
        return ts + '.' + nonce + '.' + toBase64Url(new Uint8Array(sig));
    }

    async function reset() {
        cached = null;
        await keyStore.remove(KEY_ID);
    }

    return { publicJwk, sign, reset };
}
VERO_EOF_32
echo "yazildi: lib/device-key-client.mjs"

mkdir -p "lib"
cat > "lib/device-session.mjs" <<'VERO_EOF_33'
import crypto from 'node:crypto';

export const SESSION_ABSOLUTE_MS = 30 * 24 * 60 * 60 * 1000;
export const SESSION_IDLE_MS = 7 * 24 * 60 * 60 * 1000;
export const SESSION_COOKIE = '__Host-vero_session';

const B64U = /^[A-Za-z0-9_-]+$/;

export function hashToken(token) {
    return crypto.createHash('sha256').update(String(token)).digest('hex');
}

export function normalizeDeviceKey(jwk) {
    if (!jwk || typeof jwk !== 'object') return null;
    if (jwk.kty !== 'EC' || jwk.crv !== 'P-256') return null;
    if (typeof jwk.x !== 'string' || typeof jwk.y !== 'string') return null;
    if (jwk.x.length !== 43 || jwk.y.length !== 43 || !B64U.test(jwk.x) || !B64U.test(jwk.y)) return null;
    const clean = { kty: 'EC', crv: 'P-256', x: jwk.x, y: jwk.y };
    try {
        crypto.createPublicKey({ key: clean, format: 'jwk' });
    } catch {
        return null;
    }
    const thumbprint = crypto.createHash('sha256')
        .update(JSON.stringify({ crv: clean.crv, kty: clean.kty, x: clean.x, y: clean.y }))
        .digest('base64url');
    return { jwk: clean, thumbprint };
}

export function createSession({ userId, deviceJwk, now = Date.now() }) {
    const device = normalizeDeviceKey(deviceJwk);
    if (!device || !userId) return null;
    const token = crypto.randomBytes(32).toString('base64url');
    return {
        token,
        record: {
            idHash: hashToken(token),
            userId: String(userId),
            device,
            createdAt: now,
            lastSeenAt: now,
            expiresAt: now + SESSION_ABSOLUTE_MS
        }
    };
}

export function sessionState(record, now = Date.now()) {
    if (!record) return 'missing';
    if (now > record.expiresAt) return 'expired';
    if (now - record.lastSeenAt > SESSION_IDLE_MS) return 'idle';
    return 'ok';
}

export function sessionCookie(token) {
    return SESSION_COOKIE + '=' + token + '; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=' + Math.floor(SESSION_ABSOLUTE_MS / 1000);
}

export function clearedSessionCookie() {
    return SESSION_COOKIE + '=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0';
}

export function createProofVerifier({ now = () => Date.now(), windowMs = 60000, maxNonces = 5000 } = {}) {
    const seen = new Map();

    function prune(t) {
        for (const [k, exp] of seen) {
            if (exp > t) break;
            seen.delete(k);
        }
        while (seen.size > maxNonces) seen.delete(seen.keys().next().value);
    }

    return function verifyProof({ method, path, record, proof }) {
        if (!record || !record.device) return { ok: false, reason: 'session' };
        if (typeof proof !== 'string' || proof.length < 20 || proof.length > 400) return { ok: false, reason: 'proof_missing' };
        const parts = proof.split('.');
        if (parts.length !== 3) return { ok: false, reason: 'proof_format' };
        const [ts, nonce, sig] = parts;
        if (!/^\d{13}$/.test(ts) || !/^[A-Za-z0-9_-]{16,32}$/.test(nonce) || !B64U.test(sig)) return { ok: false, reason: 'proof_format' };
        const t = now();
        if (Math.abs(t - Number(ts)) > windowMs) return { ok: false, reason: 'proof_stale' };
        const replayKey = record.idHash + ':' + nonce;
        if (seen.has(replayKey)) return { ok: false, reason: 'proof_replay' };
        const data = Buffer.from([String(method).toUpperCase(), String(path), ts, nonce].join('\n'));
        let valid = false;
        try {
            const key = crypto.createPublicKey({ key: record.device.jwk, format: 'jwk' });
            valid = crypto.verify('sha256', data, { key, dsaEncoding: 'ieee-p1363' }, Buffer.from(sig, 'base64url'));
        } catch {
            valid = false;
        }
        if (!valid) return { ok: false, reason: 'proof_invalid' };
        seen.set(replayKey, t + windowMs * 2);
        prune(t);
        return { ok: true };
    };
}
VERO_EOF_33
echo "yazildi: lib/device-session.mjs"

mkdir -p "lib"
cat > "lib/email-policy.mjs" <<'VERO_EOF_34'
const FAMILIES = [
    { id: 'google', domains: ['gmail.com', 'googlemail.com'], canonicalDomain: 'gmail.com', stripDots: true, stripPlus: true },
    { id: 'microsoft', domains: ['outlook.com', 'hotmail.com', 'live.com', 'msn.com'], stripDots: false, stripPlus: true },
    { id: 'proton', domains: ['proton.me', 'protonmail.com', 'pm.me'], canonicalDomain: 'proton.me', stripDots: false, stripPlus: true },
    { id: 'icloud', domains: ['icloud.com', 'me.com'], stripDots: false, stripPlus: true },
    { id: 'yahoo', domains: ['yahoo.com'], stripDots: false, stripPlus: false }
];

const DOMAIN_INDEX = new Map();
FAMILIES.forEach(f => f.domains.forEach(d => DOMAIN_INDEX.set(d, f)));

const LOCAL_RE = /^[a-z0-9](?:[a-z0-9._+-]*[a-z0-9])?$/;

export const ALLOWED_DOMAINS = Object.freeze([...DOMAIN_INDEX.keys()]);

export function checkEmail(input) {
    if (typeof input !== 'string') return { ok: false, reason: 'format' };
    const raw = input.trim().toLowerCase();
    if (raw.length < 6 || raw.length > 254) return { ok: false, reason: 'format' };
    const at = raw.lastIndexOf('@');
    if (at < 1 || at !== raw.indexOf('@')) return { ok: false, reason: 'format' };
    const local = raw.slice(0, at);
    const domain = raw.slice(at + 1);
    if (local.length > 64 || !LOCAL_RE.test(local) || local.includes('..')) return { ok: false, reason: 'format' };
    const family = DOMAIN_INDEX.get(domain);
    if (!family) return { ok: false, reason: 'domain_not_allowed' };
    let base = local;
    if (family.stripPlus) base = base.split('+')[0];
    if (family.stripDots) base = base.replace(/\./g, '');
    if (!base || !/^[a-z0-9]/.test(base)) return { ok: false, reason: 'format' };
    const canonicalDomain = family.canonicalDomain || domain;
    return {
        ok: true,
        address: raw,
        canonical: base + '@' + canonicalDomain,
        family: family.id
    };
}
VERO_EOF_34
echo "yazildi: lib/email-policy.mjs"

mkdir -p "lib"
cat > "lib/format.js" <<'VERO_EOF_35'
export const CATEGORIES = {
    military: { label: 'Military', icon: 'ph-crosshair' },
    economy: { label: 'Economy', icon: 'ph-chart-line-up' },
    diplomacy: { label: 'Diplomacy', icon: 'ph-handshake' },
    energy: { label: 'Energy', icon: 'ph-gas-pump' },
    humanitarian: { label: 'Humanitarian', icon: 'ph-first-aid-kit' },
    security: { label: 'Security', icon: 'ph-shield-warning' },
    cyber: { label: 'Cyber & Tech', icon: 'ph-cpu' },
    middleeast: { label: 'Middle East', icon: 'ph-mosque' },
    europe: { label: 'Europe', icon: 'ph-castle-turret' },
    asia: { label: 'Asia-Pacific', icon: 'ph-buildings' },
    africa: { label: 'Africa', icon: 'ph-compass' },
    americas: { label: 'Americas', icon: 'ph-flag' },
    intel: { label: 'Global', icon: 'ph-globe' }
};

export const TOPIC_KEYS = ['diplomacy', 'military', 'economy', 'energy', 'humanitarian', 'security', 'cyber'];
export const REGION_KEYS = ['middleeast', 'europe', 'asia', 'africa', 'americas'];
export const RANGES = [
    { key: 'all', label: 'Any time' },
    { key: '24h', label: '24h' },
    { key: '7d', label: '7 days' },
    { key: '30d', label: '30 days' }
];

export function timeAgo(value, now = Date.now()) {
    const t = new Date(value).getTime();
    if (Number.isNaN(t)) return '';
    const minutes = Math.max(0, Math.round((now - t) / 60000));
    if (minutes < 1) return 'just now';
    if (minutes < 60) return minutes + (minutes === 1 ? ' minute ago' : ' minutes ago');
    const hours = Math.round(minutes / 60);
    if (hours < 24) return hours + (hours === 1 ? ' hour ago' : ' hours ago');
    const days = Math.round(hours / 24);
    return days + (days === 1 ? ' day ago' : ' days ago');
}

export function formatDate(value) {
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return '';
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric', timeZone: 'UTC' });
}

export function clip(text, max) {
    const s = String(text || '').replace(/\s+/g, ' ').trim();
    if (s.length <= max) return s;
    return s.slice(0, max).replace(/\s+\S*$/, '') + '\u2026';
}

export function proxied(url) {
    return '/img?u=' + encodeURIComponent(url);
}

export function validCover(img) {
    if (typeof img !== 'string' || !/^https?:\/\//.test(img)) return false;
    const low = img.toLowerCase();
    return !['generic', 'business', 'placeholder', 'logo', 'avatar', 'default', 'icon', 'stock'].some(k => low.includes(k));
}

export function jsonLd(data) {
    return JSON.stringify(data).replace(/</g, '\\u003c');
}
VERO_EOF_35
echo "yazildi: lib/format.js"

mkdir -p "lib/news"
cat > "lib/news/cover.cjs" <<'VERO_EOF_36'
const UA = 'VEROBot/1.0 (https://veropol.onrender.com; veropol@proton.me)';
const API = 'https://commons.wikimedia.org/w/api.php';
const TTL = 12 * 3600 * 1000;
const MISS_TTL = 20 * 60 * 1000;

const THEATER_TERMS = {
    ukraine: ['Ukraine war', 'Ukraine'],
    mideast: ['Israel', 'Middle East'],
    yemen: ['Houthi', 'Red Sea', 'Yemen'],
    taiwan: ['Taiwan Strait', 'Taiwan'],
    brics: ['BRICS summit', 'BRICS'],
    korea: ['North Korea', 'Korean Peninsula'],
    sahel: ['Sahel', 'Niger'],
    syria: ['Syria', 'Damascus'],
    lebanon: ['Lebanon', 'Beirut'],
    sudan: ['Sudan', 'Khartoum']
};

const TOPICS = [
    [/drone/i, 'drone'],
    [/missile|rocket/i, 'missile'],
    [/typhoon|storm|hurricane|flood/i, 'typhoon'],
    [/tanker|oil|crude/i, 'oil tanker'],
    [/protest|rally|demonstrat/i, 'protest'],
    [/election|vote|ballot/i, 'election'],
    [/summit|talks|negotiat|diplomat/i, 'summit'],
    [/ceasefire|truce/i, 'ceasefire'],
    [/navy|naval|warship|destroyer|carrier|fleet/i, 'warship'],
    [/troops|soldier|army|military/i, 'soldiers'],
    [/airport|flight/i, 'airport'],
    [/refugee|humanitarian|aid/i, 'humanitarian aid'],
    [/earthquake/i, 'earthquake'],
    [/strike|attack|bomb|explosion/i, 'airstrike'],
    [/border|bridge/i, 'border']
];

const STOP = new Set(['the', 'why', 'how', 'what', 'who', 'when', 'where', 'is', 'are', 'was', 'were', 'will', 'would', 'could', 'after', 'over', 'with', 'from', 'into', 'amid', 'says', 'said', 'new', 'and', 'for', 'its', 'his', 'her', 'this', 'that', 'ahead', 'before', 'than', 'but', 'not', 'war', 'news', 'live', 'update', 'breaking', 'report', 'reports', 'three', 'two', 'four', 'five', 'first', 'days', 'day', 'week', 'year', 'years']);
const BAD_TITLE = /logo|flag|map\b|coat of arms|emblem|diagram|chart|poster|screenshot|icon|portrait|stamp|cartoon|banknote|graph|wikimania|infographic|locator|collage|signature|\.svg|book cover|album|tournament|football|soccer|olympic|concert|cosplay/i;

const cache = new Map();
const inflight = new Map();
const recent = {};

function entities(title) {
    const words = String(title || '').replace(/[“”"':;,.!?()\[\]–—|/]/g, ' ').split(/\s+/).filter(Boolean);
    const out = [];
    words.forEach(w => {
        if (w.length < 4 || !/^[A-Z][A-Za-z-]+$/.test(w)) return;
        if (STOP.has(w.toLowerCase())) return;
        out.push(w);
    });
    return [...new Set(out)];
}

function topicOf(title) {
    for (const [re, name] of TOPICS) if (re.test(title)) return name;
    return '';
}

function buildQueries(id, title) {
    const terms = THEATER_TERMS[id] || [];
    const ents = entities(title).filter(e => !terms.some(t => t.toLowerCase().includes(e.toLowerCase())));
    const topic = topicOf(title);
    const qs = [];
    if (ents.length >= 2) qs.push(ents.slice(0, 3).join(' '));
    if (ents.length) qs.push(ents[0] + ' ' + (topic && topic.toLowerCase() !== ents[0].toLowerCase() ? topic : terms[0] || ''));
    if (terms[0] && topic) qs.push(terms[0] + ' ' + topic);
    if (terms[1] && topic) qs.push(terms[1] + ' ' + topic);
    if (terms[0]) qs.push(terms[0]);
    if (terms[1]) qs.push(terms[1]);
    return [...new Set(qs.map(q => q.trim()).filter(Boolean))];
}

function clean(v) {
    return String(v || '').replace(/<[^>]*>/g, ' ').replace(/&[a-z]+;/gi, ' ').replace(/\s+/g, ' ').trim();
}

async function search(q) {
    const url = API + '?action=query&format=json&generator=search&gsrnamespace=6&gsrlimit=30&gsrsearch=' + encodeURIComponent(q + ' filetype:bitmap') +
        '&prop=imageinfo&iiprop=url|size|mime|extmetadata&iiurlwidth=1280&iiextmetadatafilter=Artist|LicenseShortName|ImageDescription|DateTimeOriginal|Categories';
    const r = await fetch(url, { headers: { 'User-Agent': UA, Accept: 'application/json' }, signal: AbortSignal.timeout(5000) });
    if (!r.ok) return [];
    const d = await r.json();
    const pages = d && d.query && d.query.pages ? Object.values(d.query.pages) : [];
    return pages;
}

function pick(pages, q, id) {
    const tokens = q.toLowerCase().split(/\s+/).filter(t => t.length >= 3);
    const year = new Date().getFullYear();
    const used = recent[id] || [];
    const scored = [];
    for (const p of pages) {
        const ii = p.imageinfo && p.imageinfo[0];
        if (!ii || !ii.thumburl) continue;
        if (ii.mime !== 'image/jpeg') continue;
        if (ii.width < 1400 || ii.height < 800) continue;
        const ratio = ii.width / ii.height;
        if (ratio < 1.25 || ratio > 2.3) continue;
        if (BAD_TITLE.test(p.title || '')) continue;
        const meta = ii.extmetadata || {};
        const hay = ((p.title || '') + ' ' + clean(meta.ImageDescription && meta.ImageDescription.value) + ' ' + clean(meta.Categories && meta.Categories.value)).toLowerCase();
        const matches = tokens.filter(t => hay.includes(t)).length;
        if (!matches) continue;
        const y = parseInt(String((meta.DateTimeOriginal && meta.DateTimeOriginal.value) || '').slice(0, 4), 10);
        const recency = y >= year - 2 ? 3 : y >= year - 6 ? 2 : y >= 2010 ? 1 : 0;
        scored.push({
            score: matches * 3 + recency + Math.min(ii.width / 4000, 1),
            url: ii.thumburl,
            page: ii.descriptionurl || '',
            credit: clean(meta.Artist && meta.Artist.value).slice(0, 48),
            license: clean(meta.LicenseShortName && meta.LicenseShortName.value).slice(0, 24)
        });
    }
    scored.sort((a, b) => b.score - a.score);
    const fresh = scored.find(x => !used.includes(x.url));
    return fresh || (scored.length ? scored[scored.length - 1] : null);
}

async function compute(id, title) {
    const queries = buildQueries(id, title);
    const generic = new Set((THEATER_TERMS[id] || []).map(t => t.toLowerCase()));
    for (const q of queries) {
        if (generic.has(q.toLowerCase())) continue;
        try {
            const pages = await search(q);
            const chosen = pick(pages, q, id);
            if (chosen) {
                recent[id] = (recent[id] || []).concat(chosen.url).slice(-24);
                return { url: chosen.url, page: chosen.page, credit: chosen.credit, license: chosen.license };
            }
        } catch (e) { }
    }
    return null;
}

function resolve(id, title) {
    const key = id + '|' + title;
    const hit = cache.get(key);
    if (hit && Date.now() - hit.at < (hit.val ? TTL : MISS_TTL)) return Promise.resolve(hit.val);
    if (inflight.has(key)) return inflight.get(key);
    const job = compute(id, title).then(val => {
        if (cache.size > 300) cache.clear();
        cache.set(key, { at: Date.now(), val });
        return val;
    }).finally(() => { inflight.delete(key); });
    inflight.set(key, job);
    return job;
}

module.exports = { resolve, buildQueries };
VERO_EOF_36
echo "yazildi: lib/news/cover.cjs"

mkdir -p "lib/news"
cat > "lib/news/engine.js" <<'VERO_EOF_37'
import createSearch from './search.cjs';
import translator from './translator.cjs';
import { matchSource } from './sources.cjs';
import coverFinder from './cover.cjs';

const KEY = Symbol.for('vero.news.engine');

function build() {
    const search = createSearch({ translator, matchSource });
    search.warm();
    return search;
}

export function getEngine() {
    if (!globalThis[KEY]) globalThis[KEY] = build();
    return globalThis[KEY];
}

export async function theatersWithCovers() {
    const engine = getEngine();
    const data = await engine.theaters();
    const theaters = { ...data.theaters };
    await Promise.all(Object.keys(theaters).map(async id => {
        const t = theaters[id];
        if (!t || !t.lead) return;
        const og = await Promise.race([engine.og(t.lead.url), new Promise(r => setTimeout(() => r(null), 2500))]).catch(() => null);
        if (og) {
            theaters[id] = { ...t, cover: { url: '/img?u=' + encodeURIComponent(og), page: t.lead.url, label: t.lead.source || '' } };
            return;
        }
        if (t.tag !== 'breaking') return;
        const found = await Promise.race([coverFinder.resolve(id, t.lead.title), new Promise(r => setTimeout(() => r(null), 1500))]).catch(() => null);
        if (found) theaters[id] = { ...t, cover: { url: found.url, page: found.page, label: [found.credit, found.license, 'Wikimedia Commons'].filter(Boolean).join(' · ') } };
    }));
    const developing = await Promise.all((data.developing || []).map(async card => {
        const og = await Promise.race([engine.og(card.lead.url), new Promise(r => setTimeout(() => r(null), 2500))]).catch(() => null);
        return og ? { ...card, cover: { url: '/img?u=' + encodeURIComponent(og), page: card.lead.url, label: card.lead.source || '' } } : card;
    }));
    return { theaters, developing, updatedAt: data.updatedAt };
}

export function theaterOf(title, description) {
    return createSearch.theaterOf(title, description);
}

export { matchSource };
VERO_EOF_37
echo "yazildi: lib/news/engine.js"

mkdir -p "lib/news"
cat > "lib/news/search.cjs" <<'VERO_EOF_38'
const UA = 'Mozilla/5.0 (compatible; VEROBot/1.0; +https://veropol.onrender.com)';
const BBC = 'https://feeds.bbci.co.uk/news/';
const GU = 'https://www.theguardian.com/';

const FEEDS = [
    { u: 'https://www.aljazeera.com/xml/rss/all.xml', s: 'Al Jazeera', l: 'en' },
    { u: 'https://www.aljazeera.net/aljazeerarss/a7c186be-1baa-4bd4-9d80-a84db769f779/73d0e1b4-532f-45ef-b135-bfdff8b8cab9', s: 'Al Jazeera', l: 'ar' },
    { u: 'https://english.alarabiya.net/tools/rss', s: 'Al Arabiya', l: 'en' },
    { u: 'https://www.al-monitor.com/rss', s: 'Al-Monitor', l: 'en' },
    { u: 'https://www.aa.com.tr/en/rss/default?cat=world', s: 'Anadolu Agency', l: 'en' },
    { u: 'https://www.aa.com.tr/ar/rss/default?cat=world', s: 'Anadolu Agency', l: 'ar' },
    { u: 'https://www.aa.com.tr/tr/rss/default?cat=dunya', s: 'Anadolu Agency', l: 'tr' },
    { u: BBC + 'world/rss.xml', s: 'BBC News', l: 'en' },
    { u: BBC + 'world/middle_east/rss.xml', s: 'BBC News', l: 'en' },
    { u: BBC + 'world/asia/rss.xml', s: 'BBC News', l: 'en' },
    { u: BBC + 'world/africa/rss.xml', s: 'BBC News', l: 'en' },
    { u: BBC + 'world/europe/rss.xml', s: 'BBC News', l: 'en' },
    { u: BBC + 'world/us_and_canada/rss.xml', s: 'BBC News', l: 'en' },
    { u: BBC + 'world/latin_america/rss.xml', s: 'BBC News', l: 'en' },
    { u: BBC + 'business/rss.xml', s: 'BBC News', l: 'en' },
    { u: 'https://feeds.bbci.co.uk/arabic/rss.xml', s: 'BBC News', l: 'ar' },
    { u: 'https://feeds.bbci.co.uk/turkce/rss.xml', s: 'BBC News', l: 'tr' },
    { u: 'https://feeds.bbci.co.uk/russian/rss.xml', s: 'BBC News', l: 'ru' },
    { u: 'https://feeds.bbci.co.uk/zhongwen/simp/rss.xml', s: 'BBC News', l: 'zh' },
    { u: 'https://feeds.bbci.co.uk/mundo/rss.xml', s: 'BBC News', l: 'es' },
    { u: GU + 'world/rss', s: 'The Guardian', l: 'en' },
    { u: GU + 'world/middleeast/rss', s: 'The Guardian', l: 'en' },
    { u: GU + 'world/europe-news/rss', s: 'The Guardian', l: 'en' },
    { u: GU + 'world/africa/rss', s: 'The Guardian', l: 'en' },
    { u: GU + 'world/asia-pacific/rss', s: 'The Guardian', l: 'en' },
    { u: GU + 'world/americas/rss', s: 'The Guardian', l: 'en' },
    { u: GU + 'business/rss', s: 'The Guardian', l: 'en' },
    { u: 'https://www.france24.com/en/rss', s: 'France 24', l: 'en' },
    { u: 'https://www.france24.com/fr/rss', s: 'France 24', l: 'fr' },
    { u: 'https://www.france24.com/es/rss', s: 'France 24', l: 'es' },
    { u: 'https://www.france24.com/ar/rss', s: 'France 24', l: 'ar' },
    { u: 'https://www.lemonde.fr/international/rss_full.xml', s: 'Le Monde', l: 'fr' },
    { u: 'https://feeds.elpais.com/mrss-s/pages/ep/site/elpais.com/section/internacional/portada', s: 'El País', l: 'es' },
    { u: 'https://rss.dw.com/rdf/rss-en-world', s: 'Deutsche Welle', l: 'en' },
    { u: 'https://rss.dw.com/rdf/rss-ar-all', s: 'Deutsche Welle', l: 'ar' },
    { u: 'https://rss.dw.com/rdf/rss-es-all', s: 'Deutsche Welle', l: 'es' },
    { u: 'https://rss.dw.com/rdf/rss-ru-all', s: 'Deutsche Welle', l: 'ru' },
    { u: 'https://rss.dw.com/rdf/rss-tr-all', s: 'Deutsche Welle', l: 'tr' },
    { u: 'https://www.euronews.com/rss?format=mrss', s: 'Euronews', l: 'en' },
    { u: 'https://fr.euronews.com/rss?format=mrss', s: 'Euronews', l: 'fr' },
    { u: 'https://arabic.euronews.com/rss?format=mrss', s: 'Euronews', l: 'ar' },
    { u: 'https://www.swissinfo.ch/eng/rss/top-news', s: 'SWI swissinfo.ch', l: 'en' },
    { u: 'https://news.un.org/feed/subscribe/en/news/all/rss.xml', s: 'UN News', l: 'en' },
    { u: 'https://news.un.org/feed/subscribe/ar/news/all/rss.xml', s: 'UN News', l: 'ar' },
    { u: 'https://news.un.org/feed/subscribe/fr/news/all/rss.xml', s: 'UN News', l: 'fr' },
    { u: 'https://news.un.org/feed/subscribe/es/news/all/rss.xml', s: 'UN News', l: 'es' },
    { u: 'https://news.un.org/feed/subscribe/ru/news/all/rss.xml', s: 'UN News', l: 'ru' },
    { u: 'https://news.un.org/feed/subscribe/zh/news/all/rss.xml', s: 'UN News', l: 'zh' },
    { u: 'https://feeds.npr.org/1004/rss.xml', s: 'NPR', l: 'en' },
    { u: 'https://www.pbs.org/newshour/feeds/rss/world', s: 'PBS NewsHour', l: 'en' },
    { u: 'https://rss.csmonitor.com/feeds/world', s: 'The Christian Science Monitor', l: 'en' }
];

const COUNTRIES = ['afghanistan', 'algeria', 'america', 'argentina', 'armenia', 'australia', 'austria', 'azerbaijan', 'bahrain', 'bangladesh', 'belarus', 'belgium', 'bolivia', 'brazil', 'britain', 'bulgaria', 'canada', 'chad', 'chile', 'china', 'colombia', 'congo', 'cuba', 'cyprus', 'denmark', 'ecuador', 'egypt', 'england', 'estonia', 'ethiopia', 'finland', 'france', 'georgia', 'germany', 'ghana', 'greece', 'hungary', 'iceland', 'india', 'indonesia', 'iran', 'iraq', 'ireland', 'israel', 'italy', 'japan', 'jordan', 'kazakhstan', 'kenya', 'korea', 'kosovo', 'kuwait', 'latvia', 'lebanon', 'libya', 'lithuania', 'malaysia', 'mali', 'mexico', 'moldova', 'morocco', 'myanmar', 'nepal', 'netherlands', 'niger', 'nigeria', 'norway', 'oman', 'pakistan', 'palestine', 'peru', 'philippines', 'poland', 'portugal', 'qatar', 'romania', 'russia', 'rwanda', 'saudi', 'serbia', 'singapore', 'slovakia', 'somalia', 'spain', 'sudan', 'sweden', 'switzerland', 'syria', 'taiwan', 'thailand', 'tunisia', 'turkey', 'turkiye', 'uganda', 'ukraine', 'emirates', 'venezuela', 'vietnam', 'yemen', 'zimbabwe', 'gaza', 'europe', 'africa', 'asia', 'nato', 'brics', 'opec'];

const ALIASES = [
    ['usa', 'us', 'america', 'american', 'americans', 'washington', 'united states'],
    ['uk', 'britain', 'british', 'london', 'united kingdom'],
    ['uae', 'emirates', 'emirati', 'dubai', 'abu dhabi'],
    ['russia', 'russian', 'moscow', 'kremlin'],
    ['china', 'chinese', 'beijing'],
    ['turkey', 'turkiye', 'turkish', 'ankara'],
    ['israel', 'israeli', 'tel aviv'],
    ['palestine', 'palestinian', 'palestinians'],
    ['iran', 'iranian', 'tehran'],
    ['ukraine', 'ukrainian', 'kyiv', 'kiev'],
    ['syria', 'syrian', 'damascus'],
    ['saudi', 'saudi arabia', 'riyadh'],
    ['eu', 'european union', 'brussels']
];

const STOP = new Set(['al', 'el', 'de', 'la', 'le', 'les', 'des', 'du', 'der', 'di', 'the', 'and', 'for', 'with', 'from', 'about', 'into', 'over', 'that', 'this', 'news', 'latest', 'of', 'in', 'on', 'to', 'an', 'is', 'are', 'was', 'what', 'who', 'how']);

const GEO = /geopolit|diplomat|sanction|military|defen[cs]e|troops|missile|navy|army|\bwar\b|conflict|ceasefire|treaty|summit|nato|security council|foreign (policy|minister)|embassy|alliance|nuclear|tariff|border|insurg|coup|junta|ukrain|russia|china|taiwan|iran|israel|gaza|syria|korea|sahel|brics|opec|airstrike|drone|президент|война|حرب|رئيس|وزير|guerre|guerra|savaş|战争/i;

const mk = (latin, other) => new RegExp('\\b(?:' + latin.join('|') + ')' + (other.length ? '|' + other.join('|') : ''), 'giu');

const CAT_DEFS = {
    military: mk(
        ['wars?\\b', 'warfare', 'wartime', 'militar', 'army\\b', 'armies', 'armée', 'ejército', 'ordu', 'troops?\\b', 'soldiers?\\b', 'soldat', 'soldado', 'asker', 'navy\\b', 'naval\\b', 'warships?', 'airstrikes?', 'air strikes?', 'missiles?', 'drones?\\b', 'artillery', 'bombing', 'shelling', 'offensive', 'front ?line', 'battles?\\b', 'combat', 'weapons?\\b', 'arms\\b', 'nato\\b', 'pentagon', 'idf\\b', 'rebels?\\b', 'insurgen', 'militia', 'fighters?\\b', 'defen[cs]e (?:minister|ministry|forces|budget)', 'guerre', 'frappes?\\b', 'misil', 'guerra', 'saldırı', 'savaş', 'füze', 'ceasefire violat'],
        ['حرب', 'عسكري', 'جيش', 'صاروخ', 'قصف', 'هجوم', 'غارة', 'مسيرة', 'معركة', 'سلاح', 'войн', 'военн', 'армия', 'армии', 'ракет', 'обстрел', 'беспилотник', 'оборон', 'наступлен', '战争', '军事', '军队', '导弹', '袭击', '国防', '空袭', '无人机', '战斗']
    ),
    diplomacy: mk(
        ['diplomat', 'summit', 'talks\\b', 'treaty', 'envoy', 'ambassador', 'embassy', 'negotiat', 'ceasefire', 'truce', 'accord\\b', 'foreign (?:minister|ministry|policy|affairs)', 'security council', 'general assembly', 'mediat', 'peace (?:deal|plan|talks|process)', 'sommet', 'négociat', 'ambassad', 'cessez', 'cumbre', 'negociaci', 'embajad', 'alto el fuego', 'zirve', 'müzakere', 'büyükelçi', 'ateşkes', 'diplomasi'],
        ['دبلوماس', 'قمة', 'محادثات', 'مفاوضات', 'معاهدة', 'مبعوث', 'سفير', 'سفارة', 'وقف إطلاق', 'هدنة', 'وساطة', 'дипломат', 'саммит', 'перегов', 'посол', 'посольств', 'перемири', '外交', '峰会', '谈判', '条约', '大使', '停火', '会谈', '和平']
    ),
    economy: mk(
        ['econom', 'trade\\b', 'tariffs?', 'inflation', 'markets?\\b', 'stocks?\\b', 'currenc', 'gdp\\b', 'bank', 'invest', 'financ', 'budget', 'debt\\b', 'recession', 'exports?\\b', 'imports?\\b', 'sanctions?', 'dollar', 'imf\\b', 'world bank', 'prices?\\b', 'économie', 'commerce', 'marché', 'economía', 'comercio', 'mercado', 'ekonomi', 'ticaret', 'piyasa', 'enflasyon', 'yaptırım'],
        ['اقتصاد', 'تجارة', 'تضخم', 'سوق', 'عقوبات', 'بنك', 'ميزانية', 'ديون', 'استثمار', 'عملة', 'دولار', 'эконом', 'торгов', 'инфляц', 'рынок', 'санкци', 'банк', 'бюджет', 'инвест', 'валют', 'пошлин', '经济', '贸易', '通胀', '市场', '制裁', '银行', '关税', '投资', '货币']
    ),
    energy: mk(
        ['oil\\b', 'gas\\b', 'lng\\b', 'pipelines?', 'opec', 'crude', 'petrol', 'energy', 'fuel', 'refiner', 'nuclear power', 'electricity', 'power grid', 'solar\\b', 'coal\\b', 'énergie', 'pétrole', 'gaz\\b', 'energía', 'gas natural', 'enerji', 'doğalgaz', 'akaryakıt'],
        ['نفط', 'غاز', 'طاقة', 'أوبك', 'بترول', 'أنابيب', 'كهرباء', 'нефт', 'газопровод', 'природный газ', 'энерг', 'опек', 'топлив', '石油', '天然气', '能源', '欧佩克', '管道', '电力']
    ),
    humanitarian: mk(
        ['humanitarian', 'refugees?\\b', 'famine', 'hunger', 'relief\\b', 'displace', 'asylum', 'migrants?\\b', 'migration', 'civilians?\\b', 'casualt', 'unicef', 'unhcr', 'red cross', 'red crescent', 'wfp\\b', 'cholera', 'epidemic', 'earthquake', 'floods?\\b', 'genocide', 'war crimes?', 'human rights', 'humanitaire', 'réfugi', 'humanitari', 'refugiad', 'insani', 'mülteci', 'açlık', 'deprem'],
        ['إنساني', 'لاجئ', 'مجاعة', 'إغاثة', 'نازح', 'مساعدات', 'ضحايا', 'مدني', 'حقوق الإنسان', 'كارثة', 'زلزال', 'فيضان', 'гуманитар', 'беженц', 'голод', 'эвакуац', 'мирные жител', 'жертв', 'права человека', 'катастроф', 'землетряс', 'наводнен', '人道', '难民', '饥荒', '援助', '平民', '伤亡', '人权', '灾难', '地震', '洪水']
    ),
    security: mk(
        ['terror', 'extremis', 'jihad', 'isis\\b', 'islamic state', 'daesh', 'al-?qaeda', 'taliban', 'hostages?\\b', 'kidnap', 'assassinat', 'espionage', 'spy\\b', 'spies\\b', 'intelligence (?:agency|service|chief)', 'mossad', 'shin bet', 'cia\\b', 'fbi\\b', 'mi6\\b', 'coup\\b', 'militants?\\b', 'crackdown', 'riots?\\b', 'unrest', 'attentat', 'secuestr', 'terrorismo', 'terör', 'casus', 'suikast', 'rehine'],
        ['إرهاب', 'إرهابي', 'داعش', 'القاعدة', 'رهائن', 'اختطاف', 'اغتيال', 'تجسس', 'استخبارات', 'انقلاب', 'اضطرابات', 'متشدد', 'террор', 'теракт', 'игил', 'заложник', 'похищен', 'убийств', 'шпион', 'разведк', 'переворот', 'беспорядк', 'экстремис', '恐怖', '极端', '人质', '绑架', '暗杀', '间谍', '情报', '政变', '骚乱']
    ),
    cyber: mk(
        ['cyber', 'hack', 'ransomware', 'malware', 'spyware', 'data breach', 'surveillance', 'artificial intelligence', 'ai\\b', 'chips?\\b', 'semiconductor', 'satellite', 'space\\b', 'quantum', '5g\\b', 'technolog', 'tech\\b', 'internet shutdown', 'disinformation', 'cybersécurité', 'piratage', 'ciberseguridad', 'hackeo', 'siber', 'yapay zeka', 'uydu', 'yarı iletken'],
        ['سيبراني', 'اختراق', 'قرصنة', 'برمجيات خبيثة', 'ذكاء اصطناعي', 'قمر صناعي', 'أقمار', 'فضاء', 'رقائق', 'تقنية', 'تكنولوجيا', 'кибер', 'хакер', 'взлом', 'искусственн', 'спутник', 'космос', 'чип', 'полупроводник', 'технолог', '网络', '黑客', '勒索', '人工智能', '卫星', '太空', '芯片', '半导体', '科技', '量子']
    ),
    middleeast: mk(
        ['israel', 'gaza', 'palestin', 'west bank', 'hamas', 'hezbollah', 'lebanon', 'beirut', 'syria', 'damascus', 'iraq', 'baghdad', 'iran\\b', 'iranian', 'tehran', 'yemen', 'houthi', 'saudi', 'riyadh', 'emirates', 'uae\\b', 'dubai', 'qatar', 'doha', 'kuwait', 'bahrain', 'oman\\b', 'jordan\\b', 'amman', 'egypt', 'cairo', 'red sea', 'persian gulf', 'jerusalem', 'tel aviv', 'golan', 'middle east', 'moyen-orient', 'oriente medio', 'orta doğu', 'israël', 'liban\\b', 'líbano', 'irak\\b', 'siria', 'suriye', 'filistin', 'lübnan', 'israil', 'égypte', 'egipto', 'mısır', 'katar'],
        ['إسرائيل', 'غزة', 'فلسطين', 'الضفة', 'حماس', 'حزب الله', 'لبنان', 'بيروت', 'سوريا', 'دمشق', 'العراق', 'بغداد', 'إيران', 'طهران', 'اليمن', 'الحوثي', 'السعودية', 'الرياض', 'الإمارات', 'قطر', 'الكويت', 'البحرين', 'الأردن', 'مصر', 'القاهرة', 'البحر الأحمر', 'الخليج', 'القدس', 'الشرق الأوسط', 'израил', 'сектор.? газа', 'палестин', 'хамас', 'хезболл', 'ливан', 'иран', 'тегеран', 'сири', 'дамаск', 'ирак', 'йемен', 'хуси', 'саудов', 'катар', 'египет', 'ближн\\S* восток', '以色列', '加沙', '巴勒斯坦', '哈马斯', '真主党', '黎巴嫩', '伊朗', '叙利亚', '伊拉克', '也门', '胡塞', '沙特', '卡塔尔', '埃及', '中东']
    ),
    europe: mk(
        ['europe', 'european', 'eu\\b', 'brussels', 'germany', 'berlin', 'france\\b', 'paris', 'macron', 'britain', 'london', 'italy', 'rome\\b', 'spain\\b', 'madrid', 'poland', 'warsaw', 'ukrain', 'kyiv', 'kiev', 'russia', 'moscow', 'kremlin', 'putin', 'baltic', 'finland', 'sweden', 'norway', 'denmark', 'netherlands', 'belgium', 'austria', 'switzerland', 'greece', 'hungary', 'orban', 'romania', 'serbia', 'balkans', 'allemagne', 'royaume-uni', 'alemania', 'reino unido', 'avrupa', 'almanya', 'fransa', 'rusya', 'ukrayna'],
        ['أوروبا', 'الاتحاد الأوروبي', 'بروكسل', 'ألمانيا', 'فرنسا', 'بريطانيا', 'إيطاليا', 'إسبانيا', 'بولندا', 'أوكرانيا', 'روسيا', 'موسكو', 'بوتين', 'كييف', 'европ', 'евросоюз', 'брюссел', 'герман', 'франци', 'британи', 'италия', 'испани', 'польш', 'украин', 'росси', 'москв', 'путин', 'киев', '欧洲', '欧盟', '德国', '法国', '英国', '意大利', '西班牙', '波兰', '乌克兰', '俄罗斯', '莫斯科', '普京', '基辅']
    ),
    asia: mk(
        ['china\\b', 'chinese', 'beijing', 'xi jinping', 'taiwan', 'taipei', 'japan', 'tokyo', 'korea', 'pyongyang', 'seoul', 'india\\b', 'delhi', 'modi\\b', 'pakistan', 'islamabad', 'afghanistan', 'kabul', 'bangladesh', 'myanmar', 'indonesia', 'jakarta', 'philippines', 'manila', 'vietnam', 'thailand', 'malaysia', 'singapore', 'asean', 'south china sea', 'indo-pacific', 'kazakhstan', 'central asia', 'chine\\b', 'japon', 'inde\\b', 'corée', 'japón', 'çin\\b', 'japonya', 'hindistan', 'kore\\b', 'tayvan'],
        ['الصين', 'بكين', 'تايوان', 'اليابان', 'طوكيو', 'كوريا', 'الهند', 'باكستان', 'أفغانستان', 'كابول', 'بنغلاديش', 'ميانمار', 'إندونيسيا', 'الفلبين', 'فيتنام', 'آسيا', 'китай', 'пекин', 'тайван', 'япони', 'токио', 'коре', 'индия', 'индии', 'пакистан', 'афганистан', 'мьянм', 'индонез', 'филиппин', 'вьетнам', 'азии', '中国', '北京', '台湾', '日本', '东京', '朝鲜', '韩国', '印度', '巴基斯坦', '阿富汗', '缅甸', '印尼', '菲律宾', '越南', '亚洲', '南海', '印太']
    ),
    africa: mk(
        ['africa', 'sahel', 'sudan', 'khartoum', 'ethiopia', 'addis', 'somalia', 'kenya', 'nairobi', 'nigeria', 'lagos', 'congo', 'kinshasa', 'rwanda', 'uganda', 'mali\\b', 'niger\\b', 'burkina', 'chad\\b', 'libya', 'tripoli', 'tunisia', 'algeria', 'morocco', 'mozambique', 'tigray', 'darfur', 'ghana', 'senegal', 'cameroon', 'afrique', 'soudan', 'éthiopie', 'libye', 'algérie', 'maroc', 'áfrica', 'sudán', 'libia', 'afrika', 'etiyopya', 'cezayir'],
        ['أفريقيا', 'إفريقيا', 'الساحل', 'السودان', 'الخرطوم', 'إثيوبيا', 'الصومال', 'كينيا', 'نيجيريا', 'الكونغو', 'رواندا', 'مالي', 'النيجر', 'بوركينا', 'تشاد', 'ليبيا', 'طرابلس', 'تونس', 'الجزائر', 'المغرب', 'موزمبيق', 'دارفور', 'африк', 'сахел', 'судан', 'хартум', 'эфиопи', 'сомали', 'кени', 'нигери', 'конго', 'руанд', 'мали', 'буркина', 'ливи', 'тунис', 'алжир', 'марокко', '非洲', '萨赫勒', '苏丹', '埃塞俄比亚', '索马里', '肯尼亚', '尼日利亚', '刚果', '卢旺达', '马里', '尼日尔', '布基纳', '乍得', '利比亚', '突尼斯', '阿尔及利亚', '摩洛哥']
    ),
    americas: mk(
        ['united states', 'u\\.s\\.', 'washington', 'white house', 'trump', 'biden', 'congress', 'canada', 'ottawa', 'mexico', 'brazil', 'lula\\b', 'argentina', 'milei', 'venezuela', 'maduro', 'colombia', 'cuba\\b', 'peru\\b', 'chile\\b', 'latin america', 'caribbean', 'panama', 'haiti', 'ecuador', 'bolivia', 'états-unis', 'etats-unis', 'estados unidos', 'amerika birleşik', 'abd\\b', 'kanada', 'meksika', 'brezilya', 'brésil', 'brasil', 'méxico'],
        ['الولايات المتحدة', 'واشنطن', 'البيت الأبيض', 'ترامب', 'بايدن', 'الكونغرس', 'كندا', 'المكسيك', 'البرازيل', 'الأرجنتين', 'فنزويلا', 'مادورو', 'كولومبيا', 'كوبا', 'أمريكا', 'сша', 'вашингтон', 'белый дом', 'трамп', 'байден', 'конгресс', 'канад', 'мексик', 'бразил', 'аргентин', 'венесуэл', 'мадуро', 'колумби', 'америк', '美国', '华盛顿', '白宫', '特朗普', '拜登', '国会', '加拿大', '墨西哥', '巴西', '阿根廷', '委内瑞拉', '马杜罗', '哥伦比亚', '古巴', '秘鲁', '智利', '美洲']
    )
};

const CAT_KEYS = Object.keys(CAT_DEFS);
const TOPIC_KEYS = ['military', 'diplomacy', 'economy', 'energy', 'humanitarian', 'security', 'cyber'];
const REGION_KEYS = ['middleeast', 'europe', 'asia', 'africa', 'americas'];

const THEATER_DEFS = {
    yemen: mk(
        ['yemen', 'houthi', 'red sea', 'sanaa', 'sana\'a', 'aden\\b', 'bab el-mandeb', 'bab al-mandab', 'yémen', 'mer rouge', 'hutíes', 'kızıldeniz'],
        ['اليمن', 'الحوثي', 'البحر الأحمر', 'صنعاء', 'йемен', 'хуси', 'хути', 'красное море', '也门', '胡塞', '红海']
    ),
    ukraine: mk(
        ['ukrain', 'kyiv', 'kiev', 'zelensk', 'donbas', 'donetsk', 'kharkiv', 'kherson', 'zaporizh', 'crimea', 'odesa', 'odessa', 'kremlin', 'moscow', 'putin', 'poutine', 'ucrania', 'ukrayna'],
        ['украин', 'киев', 'зеленск', 'донбас', 'донецк', 'харьков', 'херсон', 'запорож', 'крым', 'одесс', 'кремл', 'москв', 'путин', 'أوكرانيا', 'كييف', 'زيلينسكي', 'دونباس', 'القرم', 'الكرملين', 'موسكو', 'بوتين', '乌克兰', '基辅', '泽连斯基', '顿巴斯', '克里米亚', '克里姆林', '莫斯科', '普京']
    ),
    syria: mk(
        ['syria', 'syrian', 'damascus', 'druze', 'suwayda', 'sweida', 'sharaa', 'golan', 'syrie', 'siria', 'suriye', 'süveyda', 'dürzi'],
        ['سوريا', 'سوري', 'دمشق', 'الدروز', 'السويداء', 'الجولان', 'الشرع', 'сири', 'дамаск', 'друз', 'сувейд', 'голан', '叙利亚', '大马士革', '德鲁兹', '戈兰']
    ),
    lebanon: mk(
        ['lebanon', 'lebanese', 'beirut', 'hezbollah', 'hizbullah', 'litani', 'nabatieh', 'south lebanon', 'liban\\b', 'líbano', 'lübnan', 'hizbullah'],
        ['لبنان', 'لبناني', 'بيروت', 'حزب الله', 'الليطاني', 'جنوب لبنان', 'ливан', 'бейрут', 'хезболл', '黎巴嫩', '贝鲁特', '真主党']
    ),
    sudan: mk(
        ['sudan\\b', 'sudanese', 'khartoum', 'darfur', 'rsf\\b', 'rapid support forces', 'el fasher', 'al fashir', 'omdurman', 'soudan', 'sudán', 'sudan ordusu'],
        ['السودان', 'سوداني', 'الخرطوم', 'دارفور', 'الدعم السريع', 'الفاشر', 'أم درمان', 'судан', 'хартум', 'дарфур', '苏丹', '喀土穆', '达尔富尔']
    ),
    taiwan: mk(
        ['taiwan', 'taipei', 'taïwan', 'tayvan', 'south china sea', 'pla\\b', 'indo-pacific', 'senkaku', 'philippine sea', 'mer de chine', 'mar de china'],
        ['台湾', '台海', '南海', '解放军', '印太', 'тайван', 'южно-китайск', 'تايوان', 'بحر الصين الجنوبي']
    ),
    korea: mk(
        ['north korea', 'south korea', 'pyongyang', 'seoul', 'kim jong', 'korean peninsula', 'dmz\\b', 'corée', 'corea', 'kuzey kore', 'güney kore'],
        ['朝鲜', '韩国', '平壤', '首尔', '金正恩', 'северная коре', 'южная коре', 'пхеньян', 'сеул', 'ким чен', 'كوريا الشمالية', 'كوريا الجنوبية', 'بيونغ يانغ', 'سيول']
    ),
    sahel: mk(
        ['sahel', 'mali\\b', 'niger\\b', 'burkina', 'chad\\b', 'bamako', 'niamey', 'ouagadougou', 'jnim', 'africa corps', 'wagner', 'mauritania'],
        ['الساحل', 'مالي', 'النيجر', 'بوركينا', 'تشاد', 'باماكو', 'сахел', 'мали', 'буркина', '萨赫勒', '马里', '尼日尔', '布基纳', '乍得']
    ),
    brics: mk(
        ['brics', 'de-?dollari[sz]', 'opec', 'oil price', 'petrodollar', 'new development bank', 'shanghai cooperation', 'g20\\b', 'g7\\b', 'imf\\b', 'world bank'],
        ['بريكس', 'أوبك', 'سعر النفط', 'брикс', 'опек', '金砖', '欧佩克', '去美元化']
    ),
    mideast: mk(
        ['israel', 'gaza', 'hamas', 'hezbollah', 'lebanon', 'beirut', 'iran\\b', 'iranian', 'tehran', 'syria', 'damascus', 'iraq', 'baghdad', 'west bank', 'palestin', 'idf\\b', 'jerusalem', 'tel aviv', 'golan', 'middle east', 'moyen-orient', 'oriente medio', 'orta doğu', 'israël', 'liban\\b', 'líbano', 'irak\\b', 'siria', 'suriye', 'filistin', 'lübnan', 'israil'],
        ['إسرائيل', 'غزة', 'حماس', 'حزب الله', 'لبنان', 'بيروت', 'إيران', 'طهران', 'سوريا', 'دمشق', 'العراق', 'بغداد', 'الضفة', 'فلسطين', 'القدس', 'الشرق الأوسط', 'израил', 'сектор.? газа', 'хамас', 'хезболл', 'ливан', 'иран', 'тегеран', 'сири', 'дамаск', 'ирак', 'ближн\\S* восток', '以色列', '加沙', '哈马斯', '真主党', '黎巴嫩', '伊朗', '叙利亚', '伊拉克', '中东']
    )
};
const THEATER_ORDER = ['yemen', 'ukraine', 'syria', 'lebanon', 'sudan', 'taiwan', 'korea', 'sahel', 'brics', 'mideast'];

const ENTITY_WORDS = ['afghanistan', 'africa', 'algeria', 'america', 'argentina', 'armenia', 'assad', 'azerbaijan', 'bahrain', 'baghdad', 'beijing', 'beirut', 'belarus', 'biden', 'brazil', 'brics', 'britain', 'canada', 'china', 'council', 'crimea', 'cuba', 'cyprus', 'damascus', 'donbas', 'egypt', 'erdogan', 'ethiopia', 'europe', 'france', 'gaza', 'germany', 'greece', 'hamas', 'hezbollah', 'houthi', 'india', 'indonesia', 'iran', 'iraq', 'israel', 'italy', 'japan', 'jerusalem', 'jordan', 'kashmir', 'khamenei', 'korea', 'kremlin', 'kuwait', 'lebanon', 'libya', 'macron', 'mexico', 'morocco', 'moscow', 'myanmar', 'nato', 'netanyahu', 'nigeria', 'north', 'opec', 'pakistan', 'palestine', 'pentagon', 'poland', 'putin', 'pyongyang', 'qatar', 'russia', 'sahel', 'saudi', 'security', 'sharaa', 'somalia', 'south', 'strait', 'strip', 'sudan', 'syria', 'taiwan', 'tehran', 'trump', 'tunisia', 'turkey', 'turkiye', 'ukraine', 'vietnam', 'yemen', 'zelensky', 'zelenskyy'];
const ENTITY_TOKENS = new Set(ENTITY_WORDS);



function hits(re, text) {
    if (!text) return 0;
    const m = String(text).match(re);
    if (!m) return 0;
    return new Set(m.map(x => x.toLowerCase())).size;
}

function annotate(it) {
    const cs = {};
    for (const k of CAT_KEYS) {
        const th = hits(CAT_DEFS[k], it.title);
        const dh = hits(CAT_DEFS[k], it.description);
        if (th >= 1 || dh >= 2) cs[k] = th * 3 + dh;
    }
    it._cs = cs;
    let best = null;
    let bs = 0;
    for (const k of TOPIC_KEYS) if (cs[k] > bs) { best = k; bs = cs[k]; }
    if (!best) for (const k of REGION_KEYS) if (cs[k] > bs) { best = k; bs = cs[k]; }
    it._cat = best || 'intel';
    return it;
}


const RANGE_HOURS = { '24h': 24, '7d': 168, '30d': 720 };
const FEED_TTL = 5 * 60 * 1000;

function upgradeImage(u) {
    if (!u) return u;
    return u.replace(/(\/ace\/standard\/|\/news\/)\d{2,4}\//, '$1800/');
}

function decodeEntities(s) {
    return s
        .replace(/&#x([0-9a-f]+);/gi, (m, h) => String.fromCodePoint(parseInt(h, 16)))
        .replace(/&#(\d+);/g, (m, n) => String.fromCodePoint(+n))
        .replace(/&quot;/g, '"')
        .replace(/&apos;/g, "'")
        .replace(/&nbsp;/g, ' ')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
        .replace(/&amp;/g, '&');
}

function stripHtml(s) {
    let t = String(s || '').replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1');
    t = decodeEntities(t);
    t = t.replace(/<[^>]+>/g, ' ');
    t = decodeEntities(t);
    return t.replace(/\s+/g, ' ').trim();
}

function tag(block, name) {
    const m = block.match(new RegExp('<' + name + '(?:\\s[^>]*)?>([\\s\\S]*?)</' + name + '>', 'i'));
    return m ? m[1] : '';
}

function attr(block, name, a) {
    const m = block.match(new RegExp('<' + name + '\\s[^>]*?' + a + '="([^"]+)"', 'i'));
    return m ? decodeEntities(m[1]) : '';
}

function norm(s) {
    return String(s).toLowerCase().normalize('NFKD')
        .replace(/[\u064B-\u065F\u0670\u0640]/g, '')
        .replace(/\p{M}/gu, '')
        .replace(/[أإآٱ]/g, 'ا')
        .replace(/ى/g, 'ي')
        .replace(/ة/g, 'ه')
        .replace(/ı/g, 'i')
        .replace(/ß/g, 'ss')
        .replace(/[^\p{L}\p{N}]+/gu, ' ')
        .trim();
}

const isCJK = s => /[\u3400-\u9FFF]/.test(s);
const stemAr = t => (t.length > 4 ? t.replace(/^ال/, '') : t);
const tokensOf = s => norm(s).split(' ').filter(Boolean).map(stemAr);

function dist(a, b, max) {
    if (Math.abs(a.length - b.length) > max) return max + 1;
    const al = a.length;
    const bl = b.length;
    const d = [];
    for (let i = 0; i <= al; i++) d[i] = [i];
    for (let j = 1; j <= bl; j++) d[0][j] = j;
    for (let i = 1; i <= al; i++) {
        for (let j = 1; j <= bl; j++) {
            const c = a[i - 1] === b[j - 1] ? 0 : 1;
            d[i][j] = Math.min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + c);
            if (i > 1 && j > 1 && a[i - 1] === b[j - 2] && a[i - 2] === b[j - 1]) d[i][j] = Math.min(d[i][j], d[i - 2][j - 2] + 1);
        }
    }
    return d[al][bl];
}

function parseFeed(xml, feed) {
    const blocks = xml.match(/<(item|entry)[\s>][\s\S]*?<\/\1>/gi) || [];
    const items = [];
    for (const b of blocks.slice(0, 60)) {
        const title = stripHtml(tag(b, 'title'));
        if (!title) continue;
        let url = stripHtml(tag(b, 'link'));
        if (!url) url = attr(b, 'link', 'href');
        if (!/^https?:\/\//.test(url)) url = stripHtml(tag(b, 'guid'));
        if (!/^https?:\/\//.test(url)) continue;
        const rawDesc = tag(b, 'description') || tag(b, 'summary') || tag(b, 'content:encoded') || tag(b, 'content');
        const desc = stripHtml(rawDesc).slice(0, 320);
        let image = attr(b, 'media:content', 'url') || attr(b, 'media:thumbnail', 'url');
        if (!image) {
            const enc = b.match(/<enclosure\s[^>]*>/i);
            if (enc && /image/i.test(enc[0])) {
                const m = enc[0].match(/url="([^"]+)"/i);
                if (m) image = decodeEntities(m[1]);
            }
        }
        if (!image) {
            const html = decodeEntities(String(rawDesc).replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1') + tag(b, 'content:encoded'));
            const m = html.match(/<img[^>]+src=["']([^"']+)["']/i);
            if (m) image = m[1];
        }
        const dateRaw = stripHtml(tag(b, 'pubDate') || tag(b, 'dc:date') || tag(b, 'published') || tag(b, 'updated'));
        let when = new Date(dateRaw);
        if (isNaN(when.getTime())) when = new Date();
        const tl = tokensOf(title);
        const dl = tokensOf(desc);
        items.push({
            title,
            description: desc,
            url,
            image: /^https?:\/\//.test(image) ? upgradeImage(image) : null,
            publishedAt: when.toISOString(),
            ts: when.getTime(),
            source: feed.s,
            lang: feed.l,
            _tl: tl,
            _dl: dl,
            _t: new Set(tl),
            _d: new Set(dl),
            _tn: norm(title),
            _dn: norm(desc)
        });
    }
    items.forEach(annotate);
    return items;
}

function dedupe(list) {
    const seen = new Set();
    const seenTok = [];
    const out = [];
    for (const it of list) {
        const key = norm(it.title).slice(0, 48) + '|' + it.lang;
        if (seen.has(key) || seen.has(it.url) || (it.image && seen.has(it.image))) continue;
        const tok = new Set(norm(it.title).split(' ').filter(w => w.length > 3));
        let dup = false;
        if (tok.size >= 4) {
            for (const o of seenTok) {
                let n = 0;
                tok.forEach(w => { if (o.has(w)) n++; });
                if (n / Math.min(tok.size, o.size) >= 0.7) { dup = true; break; }
            }
        }
        if (dup) continue;
        seen.add(key);
        seen.add(it.url);
        if (it.image) seen.add(it.image);
        seenTok.push(tok);
        out.push(it);
    }
    return out;
}

module.exports = function createSearch({ translator, matchSource }) {
    const store = new Map();
    let corpus = [];
    let vocab = new Map();
    let refreshing = null;
    let lastRefresh = 0;
    const gnewsCache = new Map();
    const imageSet = new Set();
    const knownUrls = new Set();
    const ogCache = new Map();
    const ogUses = new Map();
    const entityCache = new Map();
    const suggestCache = new Map();
    const webCache = new Map();
    const devState = new Map();
    let trending = [];

    function allowImage(u) {
        if (!u) return;
        if (imageSet.size > 6000) imageSet.clear();
        imageSet.add(u);
    }

    async function pull(feed) {
        try {
            const response = await fetch(feed.u, {
                headers: { 'User-Agent': UA, 'Accept': 'application/rss+xml, application/xml, text/xml, */*' },
                signal: AbortSignal.timeout(9000),
                redirect: 'follow'
            });
            if (!response.ok) throw new Error('HTTP ' + response.status);
            const xml = await response.text();
            const items = parseFeed(xml, feed);
            if (!items.length) throw new Error('no items');
            store.set(feed.u, { items, at: Date.now(), ok: true, error: '' });
        } catch (e) {
            const prev = store.get(feed.u);
            store.set(feed.u, { items: prev ? prev.items : [], at: Date.now(), ok: false, error: String(e.message || e) });
        }
    }

    async function refresh() {
        let i = 0;
        await Promise.all(Array.from({ length: 8 }, async () => {
            while (i < FEEDS.length) await pull(FEEDS[i++]);
        }));
        const all = [];
        store.forEach(v => all.push(...v.items));
        corpus = dedupe(all);
        corpus.forEach(it => { allowImage(it.image); knownUrls.add(it.url); });
        if (knownUrls.size > 12000) knownUrls.clear();
        trending = computeTrending();
        const v = new Map();
        for (const it of corpus) {
            for (const t of it._tl) if (t.length >= 4 && !isCJK(t)) v.set(t, (v.get(t) || 0) + 2);
            for (const t of it._dl) if (t.length >= 4 && !isCJK(t)) v.set(t, (v.get(t) || 0) + 1);
        }
        COUNTRIES.forEach(c => v.set(c, (v.get(c) || 0) + 5));
        vocab = v;
        lastRefresh = Date.now();
    }

    const CAP_STOP = new Set(['the', 'why', 'how', 'what', 'who', 'when', 'where', 'after', 'amid', 'over', 'with', 'from', 'into', 'new', 'says', 'said', 'will', 'live', 'news', 'update', 'watch', 'video', 'photos', 'here', 'this', 'that', 'its', 'his', 'her', 'and', 'for', 'but', 'not', 'are', 'was', 'were', 'has', 'have', 'could', 'would', 'should', 'more', 'than', 'first', 'last', 'one', 'two', 'three', 'four', 'five', 'all', 'now', 'day', 'week', 'year', 'years', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday', 'january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december']);

    function phrases(title) {
        const words = String(title).replace(/[“”"':;,.!?()\[\]–—|/]/g, ' ').split(/\s+/).filter(Boolean);
        const out = [];
        let cur = [];
        const flush = () => {
            if (cur.length) out.push(cur.join(' '));
            cur = [];
        };
        words.forEach(w => {
            if (/^[A-Z][A-Za-z-]{2,}$/.test(w) && !CAP_STOP.has(w.toLowerCase())) cur.push(w);
            else flush();
        });
        flush();
        return out.filter(p => p.split(' ').length <= 3 && p.length >= 4);
    }

    function computeTrending() {
        const now = Date.now();
        const counts = new Map();
        for (const it of corpus) {
            if (it.lang !== 'en' || now - it.ts > 48 * 3600000) continue;
            const seen = new Set(phrases(it.title));
            seen.forEach(p => {
                const e = counts.get(p) || { n: 0, src: new Set() };
                e.n++;
                e.src.add(it.source);
                counts.set(p, e);
            });
        }
        return [...counts.entries()]
            .filter(([p, e]) => e.src.size >= 2 && !/^(Al|The)\s/.test(p))
            .sort((a, b) => b[1].src.size - a[1].src.size || b[1].n - a[1].n)
            .slice(0, 40)
            .map(([p]) => p);
    }

    function relatedFor(list, exclude) {
        const counts = new Map();
        const ex = new Set(exclude.map(x => x.toLowerCase()));
        list.slice(0, 30).forEach(r => {
            if (r.it.lang !== 'en') return;
            new Set(phrases(r.it.title)).forEach(p => {
                const low = p.toLowerCase();
                if ([...ex].some(e => low.includes(e) || e.includes(low))) return;
                counts.set(p, (counts.get(p) || 0) + 1);
            });
        });
        return [...counts.entries()].filter(([, n]) => n >= 2).sort((a, b) => b[1] - a[1]).slice(0, 8).map(([p]) => p);
    }

    const LANG_SCRIPT = q => (/[\u0600-\u06FF]/.test(q) ? 'ar' : /[\u0400-\u04FF]/.test(q) ? 'ru' : /[\u3400-\u9FFF]/.test(q) ? 'zh' : null);
    const WD = 'https://www.wikidata.org/w/api.php';
    const WD_HEADERS = { 'User-Agent': UA, Accept: 'application/json' };
    const KIND_RULES = [
        ['Leader', /\b(president|prime minister|head of state|head of government|chancellor|monarch|king of|queen of|emir|sultan|supreme leader|dictator|minister of|governor|mayor|politician|statesman|leader of)\b/i],
        ['Company', /\b(company|corporation|conglomerate|manufacturer|startup|retailer|bank|airline|firm|brand|publisher|studio|enterprise)\b/i],
        ['Market', /\b(stock exchange|stock market|stock index|securities exchange|currency|cryptocurrency|commodity|index of|financial market)\b/i],
        ['Software', /\b(software|operating system|chatbot|language model|artificial intelligence|programming language|framework|library for|web browser|search engine|application|mobile app|platform|online service|distribution service|website|social network|messaging)\b/i],
        ['Game', /\b(video game|mobile game|board game|computer game|game series|esports|role-playing|strategy game)\b/i],
        ['Country', /\b(sovereign state|country in|country of|nation state|federal republic|kingdom in|republic in|emirate)\b/i],
        ['Place', /\b(city|town|village|river|mountain|range|region|territory|island|sea|strait|capital|province|county|desert|lake|peninsula|plateau|municipality|district|valley|bay|gulf|ocean|continent|canal|port|airport|state of|area in|neighbourhood|border)\b/i],
        ['Organization', /\b(organization|organisation|alliance|union|political party|agency|movement|group|council|militant|army|armed forces|association|institution|committee|ministry|court|university)\b/i],
        ['Event', /\b(election|war|battle|conflict|summit|crisis|disaster|earthquake|treaty|revolution|attack|protest|referendum|pandemic|hurricane|siege)\b/i],
        ['Person', /\b(businessman|entrepreneur|actor|actress|singer|rapper|footballer|player|journalist|activist|scientist|writer|author|engineer|billionaire|investor|born|philosopher|physicist|astronaut|youtuber|streamer|comedian|director|producer|musician|artist|economist|general|commander)\b/i]
    ];

    function kindOf(description) {
        const d = String(description || '');
        for (const [kind, re] of KIND_RULES) if (re.test(d)) return kind;
        return 'Topic';
    }

    async function wdFetch(params) {
        const r = await fetch(WD + '?format=json&origin=*&' + params, { headers: WD_HEADERS, signal: AbortSignal.timeout(4500) });
        if (!r.ok) throw new Error('wd');
        return r.json();
    }

    async function resolveEntity(q) {
        const text = String(q || '').trim();
        const nq = norm(text);
        if (!nq || nq.length < 2 || text.length > 60 || text.split(/\s+/).length > 5 || /[0-9]{3,}/.test(text)) return null;
        const hit = entityCache.get(nq);
        if (hit && hit.exp > Date.now()) return hit.v;
        let value = null;
        try {
            const lang = LANG_SCRIPT(text) || 'en';
            const found = await wdFetch('action=wbsearchentities&type=item&limit=6&language=' + lang + '&uselang=en&search=' + encodeURIComponent(text));
            const list = Array.isArray(found.search) ? found.search : [];
            const exact = list.find(e => {
                const label = norm(e.label || '');
                const alias = norm((e.match && e.match.text) || '');
                if (label === nq || alias === nq) return true;
                if (!isCJK(nq) && nq.length >= 6 && !nq.includes(' ') && (dist(nq, label, 1) <= 1 || dist(nq, alias, 1) <= 1)) return true;
                return false;
            });
            if (exact && (exact.description || '').length) {
                const info = await wdFetch('action=wbgetentities&props=labels|aliases&languages=en|ar|tr|fr|es|ru|zh&ids=' + exact.id);
                const ent = info.entities && info.entities[exact.id];
                const labels = ent && ent.labels ? Object.values(ent.labels).map(l => l.value) : [exact.label];
                const aliases = ent && ent.aliases ? [].concat(...Object.values(ent.aliases).map(a => a.map(x => x.value))) : [];
                const names = [...new Set([exact.label].concat(labels, aliases, [text]))].slice(0, 60);
                const kind = kindOf(exact.description);
                const ctx = [...new Set(String(exact.description).toLowerCase().replace(/[^a-z\s-]/g, ' ').split(/\s+/).filter(w => w.length >= 5 && !STOP.has(w) && !['which', 'since', 'their', 'between', 'known', 'former', 'current', 'country', 'american'].includes(w)))].slice(0, 6);
                value = { en: exact.label, keys: [...new Set(names.map(n => norm(n)).filter(Boolean))], vars: names.filter(n => n.length <= 60).slice(0, 14), ctx, person: kind === 'Leader' || kind === 'Person', kind, desc: exact.description };
            }
        } catch (e) {
            value = null;
        }
        if (entityCache.size > 600) entityCache.clear();
        entityCache.set(nq, { v: value, exp: Date.now() + (value ? 24 * 3600000 : 30 * 60000) });
        return value;
    }

    async function suggestAsync(q, uiLang) {
        const text = String(q || '').trim().slice(0, 60);
        const key = norm(text) + '|' + (LANG_SCRIPT(text) || 'x');
        const hit = suggestCache.get(key);
        if (hit && hit.exp > Date.now()) return hit.v;
        const out = [];
        const add = (item, front) => {
            if (out.length >= 8 || out.some(o => o.text.toLowerCase() === item.text.toLowerCase())) return;
            if (front) out.unshift(item);
            else out.push(item);
        };
        const nq = norm(text);
        if (!nq) {
            trending.slice(0, 8).forEach(t => add({ text: t, type: 'Trending', desc: '' }));
            return out;
        }
        const tasks = [];
        const lang = LANG_SCRIPT(text) || 'en';
        tasks.push(wdFetch('action=wbsearchentities&type=item&limit=7&language=' + lang + '&uselang=en&search=' + encodeURIComponent(text)).then(d => d.search || []).catch(() => []));
        if (lang !== 'en' || /[^\x00-\x7f]/.test(text)) tasks.push(Promise.resolve([]));
        const [entities] = await Promise.all(tasks);
        entities.forEach(e => {
            if (!e.label || !(e.description || '').length) return;
            add({ text: e.label, type: kindOf(e.description), desc: e.description.slice(0, 64) });
        });
        trending.forEach(t => {
            const n = norm(t);
            if (n.startsWith(nq) || n.split(' ').some(w => w.startsWith(nq))) add({ text: t, type: 'Trending', desc: '' });
        });
        if (out.length < 3 && nq.length >= 4 && !isCJK(nq) && !/[^\x00-\x7f]/.test(nq)) {
            const fix = correct(nq);
            if (fix && fix !== nq) add({ text: fix.charAt(0).toUpperCase() + fix.slice(1), type: 'Topic', desc: '' });
        }
        if (suggestCache.size > 400) suggestCache.clear();
        suggestCache.set(key, { v: out, exp: Date.now() + 10 * 60000 });
        return out;
    }

    const WEB_LOCALES = { en: ['en-US', 'US', 'en'], tr: ['tr-TR', 'TR', 'tr'], ar: ['ar-SA', 'SA', 'ar'], fr: ['fr-FR', 'FR', 'fr'], es: ['es-ES', 'ES', 'es'], ru: ['ru-RU', 'RU', 'ru'], zh: ['zh-CN', 'CN', 'zh-Hans'] };

    function xmlText(block, tag) {
        const m = block.match(new RegExp('<' + tag + '[^>]*>([\\s\\S]*?)</' + tag + '>', 'i'));
        if (!m) return '';
        return decodeEntities(m[1].replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1')).trim();
    }

    function webItem(title, description, url, image, source, when, lang) {
        const t = stripHtml(title);
        const d = stripHtml(description || '');
        const ts = Number.isFinite(new Date(when).getTime()) ? new Date(when).getTime() : Date.now();
        if (!t || !url || ts > Date.now() + 3600000) return null;
        knownUrls.add(url);
        const item = {
            title: t,
            description: d,
            url,
            image: image && /^https?:\/\//.test(image) ? image : null,
            publishedAt: new Date(ts).toISOString(),
            ts,
            source: source || new URL(url).hostname.replace(/^www\./, ''),
            lang,
            _tl: tokensOf(t),
            _dl: tokensOf(d),
            _t: new Set(tokensOf(t)),
            _d: new Set(tokensOf(d)),
            _tn: norm(t),
            _dn: norm(d),
            web: true
        };
        return annotate(item);
    }

    async function bingNews(query, uiLang) {
        const [mkt, , setlang] = WEB_LOCALES[uiLang] || WEB_LOCALES.en;
        const r = await fetch('https://www.bing.com/news/search?q=' + encodeURIComponent(query) + '&format=rss&mkt=' + mkt + '&setlang=' + setlang, { headers: { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36', 'Accept-Language': mkt }, signal: AbortSignal.timeout(6000) });
        if (!r.ok) return [];
        const xml = await r.text();
        const out = [];
        (xml.match(/<item>[\s\S]*?<\/item>/gi) || []).slice(0, 20).forEach(block => {
            const link = xmlText(block, 'link');
            let real = link;
            try {
                const u = new URL(link);
                real = u.searchParams.get('url') || link;
            } catch (e) { }
            const item = webItem(xmlText(block, 'title'), xmlText(block, 'description'), real, xmlText(block, 'News:Image'), xmlText(block, 'News:Source'), xmlText(block, 'pubDate'), uiLang);
            if (item) out.push(item);
        });
        return out;
    }

    async function googleNews(query, uiLang) {
        const [hl, gl, ceidLang] = WEB_LOCALES[uiLang] || WEB_LOCALES.en;
        const r = await fetch('https://news.google.com/rss/search?q=' + encodeURIComponent(query) + '&hl=' + hl + '&gl=' + gl + '&ceid=' + gl + ':' + ceidLang, { headers: { 'User-Agent': UA }, signal: AbortSignal.timeout(6000) });
        if (!r.ok) return [];
        const xml = await r.text();
        const out = [];
        (xml.match(/<item>[\s\S]*?<\/item>/gi) || []).slice(0, 20).forEach(block => {
            const source = xmlText(block, 'source');
            let title = xmlText(block, 'title');
            if (source && title.endsWith(' - ' + source)) title = title.slice(0, -(source.length + 3));
            const item = webItem(title, '', xmlText(block, 'link'), null, source, xmlText(block, 'pubDate'), uiLang);
            if (item) out.push(item);
        });
        return out;
    }

    async function webNews(query, uiLang) {
        const q = String(query || '').trim().slice(0, 100);
        if (!q) return [];
        const key = q.toLowerCase() + '|' + uiLang;
        const hit = webCache.get(key);
        if (hit && hit.exp > Date.now()) return hit.v;
        let list = [];
        try {
            list = await bingNews(q, uiLang);
        } catch (e) { }
        if (list.length < 5) {
            try {
                list = list.concat(await googleNews(q, uiLang));
            } catch (e) { }
        }
        const seen = new Set();
        list = list.filter(it => {
            const k = it._tn.slice(0, 80);
            if (seen.has(k)) return false;
            seen.add(k);
            return true;
        });
        if (webCache.size > 200) webCache.clear();
        webCache.set(key, { v: list, exp: Date.now() + (list.length ? 20 : 3) * 60000 });
        return list;
    }

    const GENERIC_WORDS = new Set(['after', 'about', 'their', 'would', 'could', 'people', 'government', 'president', 'minister', 'officials', 'police', 'killed', 'attack', 'attacks', 'country', 'report', 'reports', 'says', 'said', 'news', 'latest', 'world', 'years', 'since', 'first', 'second', 'amid', 'where', 'while', 'during', 'against', 'between', 'under', 'ahead', 'without', 'within', 'three', 'several', 'another', 'other', 'there', 'these', 'those', 'being', 'become', 'becomes', 'across', 'update', 'live', 'video', 'photos', 'watch', 'week', 'month', 'today', 'tonight', 'yesterday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday', 'military', 'forces', 'troops', 'state', 'states', 'united', 'foreign', 'national', 'international', 'american', 'russian', 'israeli', 'iranian', 'ukrainian', 'chinese', 'european', 'british', 'french', 'german', 'trump', 'putin']);

    function developing(now) {
        const recent = [];
        const older = [];
        for (const it of corpus) {
            if (it.lang !== 'en') continue;
            const age = now - it.ts;
            if (age <= 12 * 3600000) recent.push(it);
            else if (age <= 60 * 3600000) older.push(it);
        }
        const termsOf = it => {
            const set = new Set();
            phrases(it.title).forEach(p => { if (p.split(' ').length >= 1 && !GENERIC_WORDS.has(p.toLowerCase())) set.add(p.toLowerCase()); });
            tokensOf(it.title).forEach(t => { if (t.length >= 6 && !STOP.has(t) && !GENERIC_WORDS.has(t) && /^[a-z]+$/.test(t)) set.add(t); });
            return set;
        };
        const recentMap = new Map();
        recent.forEach(it => termsOf(it).forEach(t => {
            if (!recentMap.has(t)) recentMap.set(t, { sources: new Set(), items: [] });
            const e = recentMap.get(t);
            e.sources.add(it.source);
            e.items.push(it);
        }));
        const baseMap = new Map();
        older.forEach(it => termsOf(it).forEach(t => {
            if (!baseMap.has(t)) baseMap.set(t, new Set());
            baseMap.get(t).add(it.source);
        }));
        const candidates = [];
        recentMap.forEach((e, t) => {
            const sources = e.sources.size;
            if (sources < 7 || e.items.length < 8) return;
            const base = (baseMap.get(t) ? baseMap.get(t).size : 0) / 4;
            const burst = sources / (base + 1);
            if (burst >= 2.2) candidates.push({ term: t, sources, burst, items: e.items });
        });
        candidates.sort((a, b) => b.burst * b.sources - a.burst * a.sources);
        const chosen = [];
        for (const c of candidates) {
            const urls = new Set(c.items.map(i => i.url));
            const overlap = chosen.some(x => {
                let shared = 0;
                x.items.forEach(i => { if (urls.has(i.url)) shared++; });
                return shared / Math.min(urls.size, x.items.length) >= 0.5;
            });
            if (!overlap) chosen.push(c);
            if (chosen.length >= 3) break;
        }
        const out = [];
        const capital = w => w.replace(/\b[a-z]/g, m => m.toUpperCase());
        chosen.forEach(c => {
            const counts = new Map();
            c.items.forEach(it => new Set(phrases(it.title)).forEach(p => {
                const low = p.toLowerCase();
                if (low === c.term || c.term.includes(low) || low.includes(c.term) || GENERIC_WORDS.has(low)) return;
                counts.set(p, (counts.get(p) || 0) + 1);
            }));
            const co = [...counts.entries()].sort((a, b) => b[1] - a[1])[0];
            const isEntity = c.items.some(it => phrases(it.title).some(p => p.toLowerCase() === c.term));
            const title = isEntity ? capital(c.term) : (co && co[1] >= 2 ? co[0] + ' ' + capital(c.term) : capital(c.term));
            const id = 'dev-' + c.term.replace(/[^a-z0-9]+/g, '-');
            devState.set(id, { title, term: c.term, at: now, query: (co && co[1] >= 2 && !isEntity ? co[0] + ' ' : '') + c.term });
            out.push(id);
        });
        const keep = [];
        devState.forEach((st, id) => {
            if (out.includes(id)) keep.push(id);
            else if (now - st.at < 3 * 3600000 && keep.length + out.length < 3) keep.push(id);
            else if (now - st.at >= 3 * 3600000) devState.delete(id);
        });
        const cards = [];
        keep.slice(0, 3).forEach(id => {
            const st = devState.get(id);
            const list = corpus.filter(it => now - it.ts <= 72 * 3600000 && it._tn.includes(st.term)).sort((a, b) => b.ts - a.ts);
            if (!list.length) return;
            const day = list.filter(it => now - it.ts <= 24 * 3600000);
            const lead = list[0];
            const h = (now - lead.ts) / 3600000;
            cards.push({ id, title: st.title, query: st.query, lead: pub(lead), more: list.slice(1, 3).map(pub), tag: h < 1.5 ? 'breaking' : h < 8 ? 'new' : 'latest', count24h: day.length, sources24h: new Set(day.map(it => it.source)).size });
        });
        return cards;
    }

    async function ogImage(u) {
        if (!u || !knownUrls.has(u)) return null;
        const hit = ogCache.get(u);
        if (hit && hit.exp > Date.now()) return hit.v;
        let v = null;
        try {
            const r = await fetch(u, { headers: { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36 VEROBot/1.0', Accept: 'text/html,application/xhtml+xml', 'Accept-Language': 'en-US,en;q=0.9' }, redirect: 'follow', signal: AbortSignal.timeout(6500) });
            if (r.ok) {
                const html = (await r.text()).slice(0, 400000);
                const metas = html.match(/<meta\s[^>]*>/gi) || [];
                let best = null;
                for (const m of metas) {
                    const key = (m.match(/(?:property|name)=["']([^"']+)["']/i) || [])[1];
                    if (!key || !/^(og:image(:secure_url)?|twitter:image(:src)?)$/i.test(key)) continue;
                    const content = (m.match(/content=["']([^"']+)["']/i) || [])[1];
                    if (!content) continue;
                    try {
                        const abs = new URL(decodeEntities(content), r.url || u).href;
                        if (/^https?:\/\//.test(abs) && !/logo|favicon|placeholder|default[-_]|sprite|blank|1x1|share[-_]?(image|img)|social[-_]|og[-_]?(default|image)\\.|brand|fallback|generic/i.test(abs)) {
                            if (/^og:image/i.test(key)) { best = abs; break; }
                            if (!best) best = abs;
                        }
                    } catch (e) { }
                }
                v = best ? upgradeImage(best) : null;
            }
        } catch (e) { }
        if (v) {
            const uses = (ogUses.get(v) || 0) + 1;
            ogUses.set(v, uses);
            if (ogUses.size > 4000) ogUses.clear();
            if (uses >= 3) v = null;
        }
        if (ogCache.size > 1500) ogCache.clear();
        ogCache.set(u, { v, exp: Date.now() + (v ? 24 * 3600000 : 20 * 60000) });
        if (v) allowImage(v);
        return v;
    }

    async function ensure() {
        if (corpus.length && Date.now() - lastRefresh < FEED_TTL) return;
        if (!refreshing) refreshing = refresh().finally(() => { refreshing = null; });
        if (!corpus.length) await refreshing;
    }

    function nearest(token, source, max) {
        let best = null;
        let bestD = max + 1;
        let bestW = -1;
        const weight = source instanceof Map ? c => source.get(c) : () => 1;
        for (const cand of (source instanceof Map ? source.keys() : source)) {
            if (cand[0] !== token[0] || Math.abs(cand.length - token.length) > max) continue;
            const d = dist(token, cand, max);
            const w = weight(cand);
            if (d <= max && d > 0 && (d < bestD || (d === bestD && w > bestW))) {
                best = cand;
                bestD = d;
                bestW = w;
            }
        }
        return best;
    }

    function correct(token) {
        if (token.length < 4 || isCJK(token) || /[^\x00-\x7f]/.test(token) || ENTITY_TOKENS.has(token)) return null;
        const known = vocab.get(token) || 0;
        if (known < 4) {
            const e = nearest(token, ENTITY_TOKENS, token.length >= 7 ? 2 : 1);
            if (e) return e;
        }
        if (known) return null;
        return nearest(token, vocab, token.length >= 5 ? 2 : 1);
    }

    async function expand(q, client) {
        const found = { exact: await resolveEntity(q), partial: null };
        const d = await translator.detectToEnglish(q);
        let english = q;
        let detected = null;
        let ok = false;
        if (d) {
            english = d.text || q;
            detected = d.detected;
            ok = true;
        } else if (client && client.english) {
            english = String(client.english).slice(0, 120);
            detected = translator.normalizeLang(client.detected);
            ok = true;
        }
        if (found.exact) {
            english = found.exact.en;
            ok = true;
            if (!detected) detected = /[\u0600-\u06FF]/.test(q) ? 'ar' : /[\u0400-\u04FF]/.test(q) ? 'ru' : /[\u3400-\u9FFF]/.test(q) ? 'zh' : null;
        }
        const variants = new Map();
        variants.set(q, 1);
        variants.set(english, 1);
        const concept = found.exact || found.partial;
        if (concept) {
            variants.set(concept.en, 1);
            concept.vars.forEach(v => variants.set(v, 0.9));
        }
        if (client && Array.isArray(client.vars) && !found.exact) client.vars.slice(0, 12).forEach(v => variants.set(String(v).slice(0, 80), 0.9));
        if (ok && !(client && client.vars && client.vars.length && !found.exact)) {
            const langs = ['ar', 'fr', 'es', 'ru', 'zh', 'tr'];
            const res = await Promise.all(langs.map(l => translator.translateTexts([english], l, 'en').catch(() => [null])));
            res.forEach(r => { if (r && r[0]) variants.set(r[0], 0.9); });
        }
        return { english, detected, ok, variants, concept: !!found.exact, conceptObj: found.exact || null };
    }

    function buildTerms(q, ex) {
        const terms = new Map();
        terms.exact = new Set();
        const put = (t, w) => {
            if (!t || t.length < 2 || STOP.has(t)) return;
            if (!terms.has(t) || terms.get(t) < w) terms.set(t, w);
        };
        ex.variants.forEach((w, text) => tokensOf(text).forEach(t => put(t, w)));
        const joined = norm(ex.english);
        ALIASES.forEach(group => {
            const hit = group.some(g => joined === g || tokensOf(ex.english).includes(g));
            if (hit) group.forEach(g => g.split(' ').forEach(p => put(p, 0.8)));
        });
        tokensOf(q).concat(tokensOf(ex.english)).forEach(t => {
            const fix = correct(t);
            if (!fix) return;
            put(fix, 0.9);
            terms.exact.add(fix);
            if (ENTITY_TOKENS.has(fix) && (vocab.get(t) || 0) < 4) terms.delete(t);
        });
        return terms;
    }

    function matchTerm(term, it, exact) {
        if (isCJK(term)) {
            if (it._tn.includes(term)) return 4;
            if (it._dn.includes(term)) return 2;
            return 0;
        }
        if (it._t.has(term)) return 4;
        if (it._d.has(term)) return 2;
        if (term.length >= 4 && !exact) {
            for (const t of it._tl) if (t.length >= 4 && (t.startsWith(term) || term.startsWith(t))) return 3;
            for (const t of it._dl) if (t.length >= 4 && (t.startsWith(term) || term.startsWith(t))) return 1.5;
        }
        return 0;
    }

    async function gnews(english, from, key, phrase) {
        const tokens = tokensOf(english).filter(t => t.length >= 3 && !STOP.has(t) && !/[^\x00-\x7f]/.test(t)).slice(0, 6);
        if (!tokens.length || !key) return [];
        const query = phrase ? '"' + phrase + '"' : tokens.join(' OR ');
        const ck = query + '|' + (from || '');
        const hit = gnewsCache.get(ck);
        if (hit && hit.exp > Date.now()) return hit.items;
        const out = [];
        for (let p = 1; p <= 2; p++) {
            try {
                let url = 'https://gnews.io/api/v4/search?q=' + encodeURIComponent(query) + '&lang=en&max=10&in=title,description&apikey=' + key;
                if (p > 1) url += '&page=' + p;
                if (from) url += '&from=' + encodeURIComponent(from);
                const response = await fetch(url, { signal: AbortSignal.timeout(10000) });
                if (!response.ok) break;
                const data = await response.json();
                const list = data && Array.isArray(data.articles) ? data.articles : [];
                list.forEach(a => {
                    knownUrls.add(a.url);
                    const src = matchSource(a.source && a.source.url ? a.source.url : a.url);
                    if (!src || !a.title) return;
                    const t = stripHtml(a.title);
                    const dsc = stripHtml(a.description || '');
                    const ts = new Date(a.publishedAt || Date.now()).getTime();
                    out.push({
                        title: t,
                        description: dsc,
                        url: a.url,
                        image: a.image && /^https?:\/\//.test(a.image) ? a.image : null,
                        publishedAt: new Date(ts).toISOString(),
                        ts,
                        source: src.name,
                        lang: 'en',
                        _tl: tokensOf(t),
                        _dl: tokensOf(dsc),
                        _t: new Set(tokensOf(t)),
                        _d: new Set(tokensOf(dsc)),
                        _tn: norm(t),
                        _dn: norm(dsc),
                        gnews: true
                    });
                });
                if (list.length < 10) break;
            } catch (e) {
                break;
            }
        }
        out.forEach(annotate);
        if (gnewsCache.size > 120) gnewsCache.delete(gnewsCache.keys().next().value);
        gnewsCache.set(ck, { items: out, exp: Date.now() + 30 * 60 * 1000 });
        return out;
    }

    function decideLang(q, english, detected, ui) {
        const script = /[\u0600-\u06FF]/.test(q) ? 'ar' : /[\u0400-\u04FF]/.test(q) ? 'ru' : /[\u3400-\u9FFF]/.test(q) ? 'zh' : null;
        if (script) return script;
        const words = q.trim().split(/\s+/).length;
        const changed = english.trim().toLowerCase() !== q.trim().toLowerCase();
        const latinUi = !['ar', 'ru', 'zh'].includes(ui);
        if (detected && detected !== 'en' && (words >= 2 || changed)) return detected;
        if (detected === 'en' && words >= 2) return 'en';
        return latinUi ? ui : 'en';
    }

    async function search(opts) {
        await ensure();
        const q = (opts.q || '').trim();
        const size = opts.size;
        const cutoffHours = RANGE_HOURS[opts.range];
        const cutoff = cutoffHours ? Date.now() - cutoffHours * 3600000 : 0;
        const cat = CAT_DEFS[opts.category] ? opts.category : 'all';
        const catOk = it => cat === 'all' || !!(it._cs && it._cs[cat]);
        const catBoost = it => (cat === 'all' ? 0 : Math.min(3, (it._cs[cat] || 0) / 3));
        const now = Date.now();
        let uiLang = opts.uiLang;
        let english = q;
        let needsExpansion = false;
        let results = [];
        let focusInfo = null;
        let broadened = false;

        const recency = it => {
            const h = (now - it.ts) / 3600000;
            return h < 24 ? 1.5 : h < 72 ? 1 : h < 168 ? 0.5 : 0;
        };

        if (!q) {
            results = corpus
                .filter(it => it.ts >= cutoff && catOk(it))
                .map(it => ({ it, score: (GEO.test(it.title) ? 2 : 0) + (GEO.test(it.description) ? 1 : 0) + recency(it) + catBoost(it) + (it.lang === uiLang ? 1.5 : 0) + (it.image ? 0.3 : 0) }));
        } else {
            const ex = await expand(q, opts.client);
            english = ex.english;
            needsExpansion = !ex.ok && !(opts.client && opts.client.english);
            if (opts.detect) uiLang = decideLang(q, english, ex.detected, uiLang);
            if (ex.conceptObj) {
                const c = ex.conceptObj;
                const aliases = [...new Set([c.en, ...c.vars, ...c.keys].map(norm).filter(a => a.length >= 3))];
                const ctx = c.ctx || [];
                const from0 = cutoffHours ? new Date(Math.floor((now - cutoffHours * 3600000) / 3600000) * 3600000).toISOString() : null;
                const extra0 = await gnews(c.en, from0, process.env.GNEWS_API_KEY, c.en);
                const pool0 = dedupe(corpus.concat(extra0)).filter(it => it.ts >= cutoff && catOk(it));
                const wb = (text, a) => !!text && (' ' + text + ' ').includes(' ' + a + ' ');
                const rows = pool0.map(it => {
                    let t = 0;
                    let d = 0;
                    let cx = 0;
                    for (const a of aliases) {
                        if (isCJK(a)) {
                            if (it._tn.includes(a)) t++;
                            if (it._dn.includes(a)) d++;
                        } else {
                            if (wb(it._tn, a)) t++;
                            if (wb(it._dn, a)) d++;
                        }
                    }
                    for (const k of ctx) if (wb(it._tn, k) || wb(it._dn, k)) cx++;
                    return { it, t, d, cx };
                });
                let tier = 'exact';
                let picked = rows.filter(r => r.t > 0);
                if (picked.length < 6) {
                    tier = 'broad';
                    picked = rows.filter(r => r.t > 0 || r.d >= 2 || (r.d >= 1 && r.cx >= 1));
                }
                if (picked.length < 6) {
                    tier = 'related';
                    picked = rows.filter(r => r.t > 0 || r.d >= 1 || r.cx >= 2);
                }
                focusInfo = { name: c.en, tier, person: !!c.person };
                picked.forEach(r => {
                    const score = r.t * 10 + r.d * 3 + Math.min(r.cx, 3) * 1.5 + recency(r.it) + catBoost(r.it) + (r.it.lang === uiLang ? 1.5 : 0) + (r.it.image ? 0.3 : 0);
                    results.push({ it: r.it, score });
                });
            }
            const terms = buildTerms(q, ex);
            const groups = [];
            if (!ex.concept) {
                tokensOf(ex.english).forEach(t => {
                    if (t.length < 2 || STOP.has(t) || isCJK(t) || /[^\x00-\x7f]/.test(t)) return;
                    const g = new Set([t]);
                    const fix = correct(t);
                    if (fix) g.add(fix);
                    ALIASES.forEach(group => { if (group.includes(t)) group.forEach(x => { if (!x.includes(' ')) g.add(x); }); });
                    groups.push(g);
                });
            }
            if (!focusInfo) {
                const key = process.env.GNEWS_API_KEY;
                const from = cutoffHours ? new Date(Math.floor((now - cutoffHours * 3600000) / 3600000) * 3600000).toISOString() : null;
                const extra = await gnews(english, from, key);
                const pool = dedupe(corpus.concat(extra));
                const collect = need => {
                    const found = [];
                    pool.forEach(it => {
                        if (it.ts < cutoff) return;
                        if (!catOk(it)) return;
                        let score = 0;
                        terms.forEach((w, term) => { score += w * matchTerm(term, it, terms.exact.has(term)); });
                        if (score <= 0) return;
                        if (groups.length && it.lang === 'en') {
                            let covered = 0;
                            groups.forEach(g => { for (const t of g) { if (matchTerm(t, it) > 0) { covered++; break; } } });
                            if (need && covered < need) return;
                            score += covered * 2;
                        }
                        score += recency(it) + catBoost(it) + (it.lang === uiLang ? 1.5 : 0) + (it.image ? 0.3 : 0);
                        found.push({ it, score });
                    });
                    return found;
                };
                const strictNeed = groups.length >= 2 ? groups.length : 0;
                results = collect(strictNeed);
                if (strictNeed && results.length < 6) {
                    broadened = true;
                    results = collect(Math.max(1, Math.ceil(groups.length / 2)));
                }
            }
        }

        if (q) {
            const webQ = focusInfo ? focusInfo.name : english;
            if (webQ && results.length < 18) {
                const editions = [webQ];
                let web = await webNews(webQ, uiLang).catch(() => []);
                if (uiLang !== 'en' && !web.length) web = await webNews(webQ, 'en').catch(() => []);
                const seenTitles = new Set(results.map(r => r.it._tn.slice(0, 80)));
                const want = tokensOf(editions[0]).filter(t => t.length >= 3 && !STOP.has(t));
                let added = 0;
                web.forEach(it => {
                    if (it.ts < cutoff || !catOk(it)) return;
                    const key = it._tn.slice(0, 80);
                    if (seenTitles.has(key)) return;
                    const hay = it._tn + ' ' + it._dn;
                    const matched = want.filter(t => hay.includes(t)).length;
                    if (want.length && !matched) return;
                    seenTitles.add(key);
                    results.push({ it, score: 1.5 + matched * 1.5 + recency(it) + (it.image ? 0.3 : 0) });
                    added++;
                });
                if (focusInfo && added && results.length - added < 3) focusInfo = { ...focusInfo, tier: 'web' };
                if (!focusInfo && added && results.length === added) broadened = false;
            }
        }

        results.sort((a, b) => b.score - a.score || b.it.ts - a.it.ts);
        const total = results.length;
        const totalPages = Math.max(1, Math.ceil(total / size));
        const page = Math.min(Math.max(opts.page, 1), totalPages);
        const articles = results.slice((page - 1) * size, page * size).map(r => (allowImage(r.it.image), {
            title: r.it.title,
            description: r.it.description,
            url: r.it.url,
            image: r.it.image,
            publishedAt: r.it.publishedAt,
            source: r.it.source,
            lang: r.it.lang,
            cat: r.it._cat,
            web: !!r.it.web
        }));
        const exclude = q ? tokensOf(english).concat(tokensOf(q)).concat(focusInfo ? [focusInfo.name] : []) : [];
        const related = q ? relatedFor(results, exclude) : [];
        return { articles, page, totalPages, total, lang: uiLang, queryEnglish: english, needsExpansion, focus: focusInfo, broadened, related };
    }

    function pub(it) {
        allowImage(it.image);
        return { title: it.title, description: it.description, url: it.url, image: it.image, publishedAt: it.publishedAt, source: it.source, lang: it.lang, web: !!it.web };
    }

    let theaterCache = { at: 0, data: null };

    function theaters() {
        const now = Date.now();
        if (theaterCache.data && now - theaterCache.at < 45000) return theaterCache.data;
        const buckets = {};
        THEATER_ORDER.forEach(id => { buckets[id] = []; });
        for (const it of corpus) {
            if (now - it.ts > 72 * 3600000) continue;
            const id = THEATER_ORDER.find(k => hits(THEATER_DEFS[k], it.title) >= 1 || hits(THEATER_DEFS[k], it.description) >= 2);
            if (id) buckets[id].push(it);
        }
        const out = {};
        THEATER_ORDER.forEach(id => {
            const list = buckets[id].sort((a, b) => b.ts - a.ts);
            const day = list.filter(it => now - it.ts <= 24 * 3600000);
            const lead = list[0] || null;
            let tag = 'latest';
            if (lead) {
                const h = (now - lead.ts) / 3600000;
                tag = h < 1.5 ? 'breaking' : h < 8 ? 'new' : 'latest';
            }
            out[id] = {
                lead: lead ? pub(lead) : null,
                more: list.slice(1, 3).map(pub),
                tag,
                count24h: day.length,
                sources24h: new Set(day.map(it => it.source)).size
            };
        });
        theaterCache = { at: now, data: { theaters: out, developing: developing(now), updatedAt: lastRefresh ? new Date(lastRefresh).toISOString() : null } };
        return theaterCache.data;
    }

    function feedHealth() {
        const feeds = FEEDS.map(f => {
            const s = store.get(f.u);
            return { source: f.s, lang: f.l, url: f.u, ok: s ? s.ok : null, items: s ? s.items.length : 0, error: s ? s.error : 'not fetched yet' };
        });
        return { corpus: corpus.length, vocabulary: vocab.size, working: feeds.filter(f => f.ok).length, total: feeds.length, feeds };
    }

    function warm() {
        ensure().catch(() => { });
        setInterval(() => {
            if (!refreshing) refreshing = refresh().finally(() => { refreshing = null; });
        }, FEED_TTL).unref();
    }

    async function theatersLive() {
        await ensure();
        return theaters();
    }

    return { search, suggest: suggestAsync, og: ogImage, feedHealth, warm, theaters: theatersLive, imageAllowed: u => imageSet.has(u) };
};
module.exports.theaterOf = function theaterOf(title, description) {
    return THEATER_ORDER.find(k => hits(THEATER_DEFS[k], String(title || '')) >= 1 || hits(THEATER_DEFS[k], String(description || '')) >= 2) || null;
};
VERO_EOF_38
echo "yazildi: lib/news/search.cjs"

mkdir -p "lib/news"
cat > "lib/news/sources.cjs" <<'VERO_EOF_39'
const TRUSTED_SOURCES = [
    { name: 'Al Jazeera', domains: ['aljazeera.com', 'aljazeera.net'], region: 'Qatar' },
    { name: 'Al Arabiya', domains: ['alarabiya.net'], region: 'Saudi Arabia / UAE' },
    { name: 'Al-Monitor', domains: ['al-monitor.com'], region: 'United States' },
    { name: 'Anadolu Agency', domains: ['aa.com.tr'], region: 'Türkiye' },
    { name: 'Reuters', domains: ['reuters.com'], region: 'United Kingdom' },
    { name: 'Associated Press', domains: ['apnews.com'], region: 'United States' },
    { name: 'BBC News', domains: ['bbc.com', 'bbc.co.uk'], region: 'United Kingdom' },
    { name: 'The Guardian', domains: ['theguardian.com'], region: 'United Kingdom' },
    { name: 'France 24', domains: ['france24.com'], region: 'France' },
    { name: 'Le Monde', domains: ['lemonde.fr'], region: 'France' },
    { name: 'Deutsche Welle', domains: ['dw.com'], region: 'Germany' },
    { name: 'Euronews', domains: ['euronews.com'], region: 'European Union' },
    { name: 'El País', domains: ['elpais.com'], region: 'Spain' },
    { name: 'SWI swissinfo.ch', domains: ['swissinfo.ch'], region: 'Switzerland' },
    { name: 'UN News', domains: ['news.un.org', 'un.org'], region: 'United Nations' },
    { name: 'NPR', domains: ['npr.org'], region: 'United States' },
    { name: 'PBS NewsHour', domains: ['pbs.org'], region: 'United States' },
    { name: 'The Christian Science Monitor', domains: ['csmonitor.com'], region: 'United States' }
];

function matchSource(url) {
    let host = '';
    try { host = new URL(url).hostname.replace(/^www\./, '').toLowerCase(); } catch (e) { return null; }
    for (const s of TRUSTED_SOURCES) {
        if (s.domains.some(d => host === d || host.endsWith('.' + d))) return s;
    }
    return null;
}

module.exports = { TRUSTED_SOURCES, matchSource };
VERO_EOF_39
echo "yazildi: lib/news/sources.cjs"

mkdir -p "lib/news"
cat > "lib/news/translator.cjs" <<'VERO_EOF_40'
module.exports = {
    detectToEnglish: async q => ({ text: String(q || ''), detected: 'en' }),
    normalizeLang: () => 'en',
    translateTexts: async texts => (Array.isArray(texts) ? texts.map(() => null) : [])
};
VERO_EOF_40
echo "yazildi: lib/news/translator.cjs"

mkdir -p "lib"
cat > "lib/otp.mjs" <<'VERO_EOF_41'
import crypto from 'node:crypto';

export const OTP_TTL_MS = 10 * 60 * 1000;
export const OTP_MAX_ATTEMPTS = 5;
export const OTP_RESEND_COOLDOWN_MS = 60 * 1000;
export const OTP_MAX_SENDS_PER_HOUR = 5;

const HOUR_MS = 60 * 60 * 1000;
const PURPOSES = new Set(['login', 'email_change']);

function emptyRecord() {
    return { purpose: '', codeHash: null, expiresAt: 0, attempts: 0, sentAt: 0, sendTimes: [] };
}

export function createOtpService({ secret, now = () => Date.now() }) {
    if (typeof secret !== 'string' || secret.length < 32) throw new Error('otp secret must be at least 32 characters');

    function digest(email, purpose, code) {
        return crypto.createHmac('sha256', secret).update(email + '|' + purpose + '|' + code).digest();
    }

    function issue(record, email, purpose) {
        if (!PURPOSES.has(purpose)) return { ok: false, reason: 'purpose' };
        const t = now();
        const prev = record || emptyRecord();
        const sendTimes = prev.sendTimes.filter(x => t - x < HOUR_MS);
        if (prev.sentAt && t - prev.sentAt < OTP_RESEND_COOLDOWN_MS) {
            return { ok: false, reason: 'cooldown', retryAfterMs: OTP_RESEND_COOLDOWN_MS - (t - prev.sentAt) };
        }
        if (sendTimes.length >= OTP_MAX_SENDS_PER_HOUR) {
            return { ok: false, reason: 'hourly_limit', retryAfterMs: HOUR_MS - (t - sendTimes[0]) };
        }
        const code = String(crypto.randomInt(0, 1000000)).padStart(6, '0');
        return {
            ok: true,
            code,
            record: {
                purpose,
                codeHash: digest(email, purpose, code).toString('hex'),
                expiresAt: t + OTP_TTL_MS,
                attempts: 0,
                sentAt: t,
                sendTimes: sendTimes.concat(t)
            }
        };
    }

    function verify(record, email, purpose, input) {
        const t = now();
        if (!record || !record.codeHash || record.purpose !== purpose) return { ok: false, reason: 'none', record };
        if (t > record.expiresAt) return { ok: false, reason: 'expired', record: { ...record, codeHash: null } };
        const candidate = typeof input === 'string' ? input.trim() : '';
        const expected = Buffer.from(record.codeHash, 'hex');
        const actual = digest(email, purpose, /^\d{6}$/.test(candidate) ? candidate : 'invalid');
        const match = /^\d{6}$/.test(candidate) && expected.length === actual.length && crypto.timingSafeEqual(expected, actual);
        if (match) return { ok: true, record: { ...record, codeHash: null, attempts: 0 } };
        const attempts = record.attempts + 1;
        if (attempts >= OTP_MAX_ATTEMPTS) return { ok: false, reason: 'locked', record: { ...record, codeHash: null, attempts } };
        return { ok: false, reason: 'invalid', attemptsLeft: OTP_MAX_ATTEMPTS - attempts, record: { ...record, attempts } };
    }

    return { issue, verify };
}
VERO_EOF_41
echo "yazildi: lib/otp.mjs"

mkdir -p "lib/overview"
cat > "lib/overview/generate.js" <<'VERO_EOF_42'
import { SYSTEM_PROMPT, buildUserPrompt } from './prompt.js';
import { extractJson, validateOverview } from './validate.js';

export function overviewConfig(env = process.env) {
    const baseUrl = String(env.LLM_BASE_URL || '').replace(/\/+$/, '');
    const apiKey = String(env.LLM_API_KEY || '');
    const model = String(env.LLM_MODEL || '');
    if (!/^https:\/\//.test(baseUrl) || !apiKey || !model) return null;
    const daily = parseInt(env.OVERVIEW_DAILY_LIMIT || '150', 10);
    return { baseUrl, apiKey, model, dailyLimit: Number.isFinite(daily) && daily > 0 ? daily : 150 };
}

async function ask(config, messages, fetchImpl) {
    const response = await fetchImpl(config.baseUrl + '/chat/completions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + config.apiKey },
        body: JSON.stringify({ model: config.model, messages, temperature: 0.3, max_tokens: 700 }),
        signal: AbortSignal.timeout(25000)
    });
    if (!response.ok) throw new Error('provider_' + response.status);
    const data = await response.json();
    const text = data && data.choices && data.choices[0] && data.choices[0].message ? data.choices[0].message.content : '';
    return typeof text === 'string' ? text : '';
}

export async function generateOverview(material, config, fetchImpl = fetch) {
    if (!config) return { ok: false, reason: 'not_configured' };
    const messages = [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: buildUserPrompt(material) }
    ];
    let lastReason = 'unknown';
    for (let attempt = 0; attempt < 2; attempt++) {
        let text;
        try {
            text = await ask(config, messages, fetchImpl);
        } catch (e) {
            return { ok: false, reason: String(e && e.message ? e.message : 'request_failed').slice(0, 40) };
        }
        const checked = validateOverview(extractJson(text), material.sourceText);
        if (checked.ok) return { ok: true, overview: checked.value, model: config.model };
        lastReason = checked.reason;
        messages.push({ role: 'assistant', content: text.slice(0, 1500) });
        messages.push({ role: 'user', content: 'Your answer was rejected (' + checked.reason + '). Follow every rule and return only the JSON object.' });
    }
    return { ok: false, reason: lastReason };
}
VERO_EOF_42
echo "yazildi: lib/overview/generate.js"

mkdir -p "lib/overview"
cat > "lib/overview/prompt.js" <<'VERO_EOF_43'
export const SYSTEM_PROMPT = [
    'You are the analyst desk of VERO, an independent observatory for global affairs.',
    'You write short, original overviews of single news reports.',
    'Rules:',
    'Use only the material provided. Never add facts, names, numbers, dates, causes or quotations that are not in it.',
    'If the material is thin, write less instead of guessing.',
    'Do not reuse more than six consecutive words from the headline or snippet.',
    'Write plain, neutral, precise English.',
    'Attribute reported claims to the outlet, for example "BBC News reports" or "according to Reuters".',
    'No quotation marks, no markdown, no links, no emojis.',
    'The context field may use only the theater background supplied.',
    'Reply with one JSON object and nothing else.'
].join('\n');

export function buildMaterial({ report, theater, related }) {
    const lines = [];
    lines.push('Outlet: ' + report.source + (report.sourceRegion ? ' (' + report.sourceRegion + ')' : ''));
    if (report.publishedAt) lines.push('Published: ' + new Date(report.publishedAt).toISOString());
    lines.push('Headline: ' + report.title);
    if (report.description) lines.push('Snippet: ' + report.description);
    if (theater) lines.push('Theater background: ' + theater.title + '. ' + theater.desc);
    if (related && related.length) {
        lines.push('Other recent headlines from the same theater:');
        related.slice(0, 4).forEach(r => lines.push('- ' + r.title + ' (' + r.source + ')'));
    }
    const sourceText = [report.title, report.description, theater ? theater.title + ' ' + theater.desc : '', ...(related || []).slice(0, 4).map(r => r.title)].join(' ');
    return { prompt: lines.join('\n'), sourceText };
}

export function buildUserPrompt(material) {
    return [
        material.prompt,
        '',
        'Return a JSON object with exactly these keys:',
        'title: a clear English headline of at most 110 characters that restates the report in your own words',
        'summary: 2 or 3 sentences, at most 480 characters, saying what is reported and by whom',
        'context: 1 or 2 sentences, at most 560 characters, explaining why it matters using only the theater background',
        'keyPoints: an array of exactly 3 strings, each at most 150 characters: what is reported, who is involved, and what remains unconfirmed or open in the material'
    ].join('\n');
}
VERO_EOF_43
echo "yazildi: lib/overview/prompt.js"

mkdir -p "lib/overview"
cat > "lib/overview/validate.js" <<'VERO_EOF_44'
export const LIMITS = { title: 110, summary: 480, context: 560, point: 150, points: 3 };

export function extractJson(text) {
    const raw = String(text || '').replace(/```json|```/gi, '').trim();
    const start = raw.indexOf('{');
    const end = raw.lastIndexOf('}');
    if (start === -1 || end <= start) return null;
    try {
        return JSON.parse(raw.slice(start, end + 1));
    } catch {
        return null;
    }
}

function words(text) {
    return String(text || '').toLowerCase().replace(/[^\p{L}\p{N}\s]/gu, ' ').split(/\s+/).filter(Boolean);
}

function shingles(list, size) {
    const out = new Set();
    for (let i = 0; i + size <= list.length; i++) out.add(list.slice(i, i + size).join(' '));
    return out;
}

function clean(value) {
    return typeof value === 'string' ? value.replace(/\s+/g, ' ').trim() : '';
}

function hasForbidden(text) {
    return /https?:|www\.|<|>|\*\*|^#|["\u201c\u201d\u00ab\u00bb]/m.test(text);
}

function mostlyEnglish(text) {
    const letters = text.match(/\p{L}/gu) || [];
    if (!letters.length) return false;
    const ascii = letters.filter(ch => /[A-Za-z]/.test(ch)).length;
    return ascii / letters.length >= 0.95;
}

export function validateOverview(raw, sourceText) {
    if (!raw || typeof raw !== 'object') return { ok: false, reason: 'not_object' };
    const title = clean(raw.title);
    const summary = clean(raw.summary);
    const context = clean(raw.context);
    const points = Array.isArray(raw.keyPoints) ? raw.keyPoints.map(clean).filter(Boolean) : [];
    if (!title || !summary || !context) return { ok: false, reason: 'missing_field' };
    if (points.length !== LIMITS.points) return { ok: false, reason: 'key_points_count' };
    if (title.length > LIMITS.title || summary.length > LIMITS.summary || context.length > LIMITS.context || points.some(p => p.length > LIMITS.point)) {
        return { ok: false, reason: 'too_long' };
    }
    if (title.length < 20 || summary.length < 80 || context.length < 40 || points.some(p => p.length < 15)) return { ok: false, reason: 'too_short' };
    const all = [title, summary, context, ...points];
    if (all.some(hasForbidden)) return { ok: false, reason: 'forbidden_content' };
    if (!all.every(mostlyEnglish)) return { ok: false, reason: 'not_english' };
    const sourceLower = String(sourceText || '').toLowerCase();
    const numbers = all.join(' ').match(/\d[\d,.]*/g) || [];
    for (const n of numbers) {
        const bare = n.replace(/[.,]+$/g, '');
        if (bare && !sourceLower.includes(bare.toLowerCase())) return { ok: false, reason: 'unsupported_number' };
    }
    const src = shingles(words(sourceText), 8);
    const out = shingles(words([summary, context, ...points].join(' ')), 8);
    for (const s of out) if (src.has(s)) return { ok: false, reason: 'copied_text' };
    return { ok: true, value: { title, summary, context, keyPoints: points } };
}
VERO_EOF_44
echo "yazildi: lib/overview/validate.js"

mkdir -p "lib"
cat > "lib/rate-limit.js" <<'VERO_EOF_45'
export function createLimiter({ limit, windowMs, maxKeys = 5000 }) {
    const hits = new Map();

    function check(key, now = Date.now()) {
        const cutoff = now - windowMs;
        const list = (hits.get(key) || []).filter(t => t > cutoff);
        if (list.length >= limit) {
            hits.set(key, list);
            return { ok: false, retryAfter: Math.max(1, Math.ceil((list[0] + windowMs - now) / 1000)) };
        }
        list.push(now);
        hits.set(key, list);
        if (hits.size > maxKeys) {
            for (const [k, v] of hits) {
                if (!v.some(t => t > cutoff)) hits.delete(k);
                if (hits.size <= maxKeys) break;
            }
        }
        return { ok: true, retryAfter: 0 };
    }

    return { check };
}

export function clientIp(headers) {
    const forwarded = headers.get('x-forwarded-for');
    if (forwarded) {
        const first = forwarded.split(',')[0].trim();
        if (first) return first.slice(0, 64);
    }
    return (headers.get('x-real-ip') || 'unknown').slice(0, 64);
}
VERO_EOF_45
echo "yazildi: lib/rate-limit.js"

mkdir -p "lib"
cat > "lib/reports.js" <<'VERO_EOF_46'
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
VERO_EOF_46
echo "yazildi: lib/reports.js"

mkdir -p "lib"
cat > "lib/site.js" <<'VERO_EOF_47'
export const SITE_URL = (process.env.NEXT_PUBLIC_SITE_URL || 'https://veropol.onrender.com').replace(/\/+$/, '');
export const SITE_NAME = 'VERO';
export const SITE_TITLE = 'VERO | Global Intelligence & Strategic Analysis';
export const SITE_DESCRIPTION = 'VERO is an independent global intelligence and diplomatic monitoring observatory. Live conflict tracking, geopolitical reporting and signed analysis.';
export const CONTACT_EMAIL = 'veropol@proton.me';
export const DEV_EMAIL = 'legateau@proton.me';
export const DISCORD_URL = 'https://discord.gg/MGHqzQ3Umm';
export const GA_ID = 'G-PJW06HEYF5';
export const LEGAL_UPDATED = '2026-11-19';
VERO_EOF_47
echo "yazildi: lib/site.js"

mkdir -p "lib"
cat > "lib/slug.js" <<'VERO_EOF_48'
import crypto from 'node:crypto';

export function urlHash(url) {
    return crypto.createHash('sha256').update(String(url)).digest('hex').slice(0, 10);
}

export function slugify(text, max = 60) {
    const base = String(text || '')
        .normalize('NFKD')
        .replace(/[\u0300-\u036f]/g, '')
        .toLowerCase()
        .replace(/&/g, ' and ')
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');
    if (base.length <= max) return base;
    const cut = base.slice(0, max);
    const at = cut.lastIndexOf('-');
    return (at > 20 ? cut.slice(0, at) : cut).replace(/-+$/g, '');
}

export function reportSlug(title, url) {
    return (slugify(title) || 'report') + '-' + urlHash(url);
}

export function isReportSlug(value) {
    return typeof value === 'string' && value.length <= 100 && /^[a-z0-9]+(?:-[a-z0-9]+)*-[a-f0-9]{10}$/.test(value);
}
VERO_EOF_48
echo "yazildi: lib/slug.js"

mkdir -p "models"
cat > "models/Report.js" <<'VERO_EOF_49'
import mongoose from 'mongoose';

const schema = new mongoose.Schema({
    slug: { type: String, required: true, unique: true, maxlength: 100 },
    urlHash: { type: String, required: true, maxlength: 16 },
    url: { type: String, required: true, maxlength: 1500 },
    title: { type: String, required: true, maxlength: 300 },
    description: { type: String, default: '', maxlength: 400 },
    source: { type: String, required: true, maxlength: 80 },
    sourceRegion: { type: String, default: '', maxlength: 80 },
    image: { type: String, default: '', maxlength: 1000 },
    publishedAt: { type: Date, required: true },
    theater: { type: String, default: '', maxlength: 24 },
    category: { type: String, default: 'intel', maxlength: 24 },
    lang: { type: String, default: 'en', maxlength: 8 },
    overview: {
        title: String,
        summary: String,
        context: String,
        keyPoints: [String],
        model: String,
        generatedAt: Date
    },
    overviewFailures: { type: Number, default: 0 },
    lastTriedAt: Date,
    firstSeenAt: { type: Date, default: Date.now },
    lastSeenAt: { type: Date, default: Date.now }
});

schema.index({ 'overview.generatedAt': -1 });
schema.index({ theater: 1, publishedAt: -1 });
schema.index({ publishedAt: -1 });

export default mongoose.models.Report || mongoose.model('Report', schema);
VERO_EOF_49
echo "yazildi: models/Report.js"

cat > "next.config.mjs" <<'VERO_EOF_50'
const securityHeaders = [
    { key: 'X-Content-Type-Options', value: 'nosniff' },
    { key: 'X-Frame-Options', value: 'DENY' },
    { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
    { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=(), payment=()' },
    { key: 'Strict-Transport-Security', value: 'max-age=31536000' }
];

const nextConfig = {
    poweredByHeader: false,
    reactStrictMode: true,
    serverExternalPackages: ['mongoose'],
    async headers() {
        return [{ source: '/:path*', headers: securityHeaders }];
    }
};

export default nextConfig;
VERO_EOF_50
echo "yazildi: next.config.mjs"

cat > "package.json" <<'VERO_EOF_51'
{
  "name": "vero",
  "version": "2.0.0",
  "private": true,
  "description": "Verifiable Events & Research Observatory",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "test": "node --test tests/auth-core.test.mjs tests/news-core.test.mjs"
  },
  "engines": {
    "node": ">=20.9.0"
  },
  "dependencies": {
    "next": "^16.4.0",
    "react": "^19.2.0",
    "react-dom": "^19.2.0",
    "mongoose": "^9.10.2"
  }
}
VERO_EOF_51
echo "yazildi: package.json"

mkdir -p "tests"
cat > "tests/auth-core.test.mjs" <<'VERO_EOF_52'
import test from 'node:test';
import assert from 'node:assert/strict';
import { checkEmail } from '../lib/email-policy.mjs';
import { createOtpService, OTP_MAX_ATTEMPTS, OTP_RESEND_COOLDOWN_MS, OTP_TTL_MS, OTP_MAX_SENDS_PER_HOUR } from '../lib/otp.mjs';
import { createSession, createProofVerifier, sessionState, normalizeDeviceKey, SESSION_IDLE_MS, SESSION_ABSOLUTE_MS } from '../lib/device-session.mjs';
import { createDeviceKey } from '../lib/device-key-client.mjs';

const SECRET = 'x'.repeat(48);

function memoryStore() {
    const m = new Map();
    return { get: async k => m.get(k) || null, set: async (k, v) => { m.set(k, v); }, remove: async k => { m.delete(k); } };
}

test('email policy accepts allowed providers and canonicalizes aliases', () => {
    assert.equal(checkEmail('  Test.User+spam@Gmail.com ').canonical, 'testuser@gmail.com');
    assert.equal(checkEmail('a.b@googlemail.com').canonical, 'ab@gmail.com');
    assert.equal(checkEmail('name+tag@outlook.com').canonical, 'name@outlook.com');
    assert.equal(checkEmail('name@protonmail.com').canonical, 'name@proton.me');
    assert.equal(checkEmail('name@pm.me').canonical, 'name@proton.me');
    assert.equal(checkEmail('first.last@yahoo.com').canonical, 'first.last@yahoo.com');
    assert.equal(checkEmail('me@icloud.com').ok, true);
});

test('email policy rejects other domains and malformed input', () => {
    assert.deepEqual(checkEmail('x@mailinator.com'), { ok: false, reason: 'domain_not_allowed' });
    assert.deepEqual(checkEmail('someone@company.org'), { ok: false, reason: 'domain_not_allowed' });
    assert.equal(checkEmail('a@b@gmail.com').reason, 'format');
    assert.equal(checkEmail('"quoted"@gmail.com').reason, 'format');
    assert.equal(checkEmail('a..b@gmail.com').reason, 'format');
    assert.equal(checkEmail('+tag@gmail.com').reason, 'format');
    assert.equal(checkEmail('abc@gmail.com.evil.com').reason, 'domain_not_allowed');
    assert.equal(checkEmail(null).reason, 'format');
    assert.equal(checkEmail('a'.repeat(70) + '@gmail.com').reason, 'format');
});

test('otp issues, verifies once and cannot be reused', () => {
    let t = 1_000_000;
    const otp = createOtpService({ secret: SECRET, now: () => t });
    const issued = otp.issue(null, 'a@gmail.com', 'login');
    assert.equal(issued.ok, true);
    assert.match(issued.code, /^\d{6}$/);
    assert.ok(!JSON.stringify(issued.record).includes(issued.code));
    const good = otp.verify(issued.record, 'a@gmail.com', 'login', issued.code);
    assert.equal(good.ok, true);
    const again = otp.verify(good.record, 'a@gmail.com', 'login', issued.code);
    assert.equal(again.ok, false);
    assert.equal(again.reason, 'none');
});

test('otp is bound to email and purpose', () => {
    const otp = createOtpService({ secret: SECRET });
    const issued = otp.issue(null, 'a@gmail.com', 'login');
    assert.equal(otp.verify(issued.record, 'b@gmail.com', 'login', issued.code).ok, false);
    assert.equal(otp.verify(issued.record, 'a@gmail.com', 'email_change', issued.code).ok, false);
    assert.equal(otp.issue(null, 'a@gmail.com', 'other').reason, 'purpose');
});

test('otp locks after max wrong attempts even if the right code follows', () => {
    const otp = createOtpService({ secret: SECRET });
    const issued = otp.issue(null, 'a@gmail.com', 'login');
    let record = issued.record;
    const wrong = issued.code === '000000' ? '111111' : '000000';
    let last;
    for (let i = 0; i < OTP_MAX_ATTEMPTS; i++) {
        last = otp.verify(record, 'a@gmail.com', 'login', wrong);
        record = last.record;
    }
    assert.equal(last.reason, 'locked');
    assert.equal(otp.verify(record, 'a@gmail.com', 'login', issued.code).ok, false);
});

test('otp rejects non numeric input and counts it as an attempt', () => {
    const otp = createOtpService({ secret: SECRET });
    const issued = otp.issue(null, 'a@gmail.com', 'login');
    const r = otp.verify(issued.record, 'a@gmail.com', 'login', '12ab56');
    assert.equal(r.ok, false);
    assert.equal(r.reason, 'invalid');
    assert.equal(r.record.attempts, 1);
    assert.equal(otp.verify(issued.record, 'a@gmail.com', 'login', undefined).ok, false);
});

test('otp expires', () => {
    let t = 5_000_000;
    const otp = createOtpService({ secret: SECRET, now: () => t });
    const issued = otp.issue(null, 'a@gmail.com', 'login');
    t += OTP_TTL_MS + 1;
    const r = otp.verify(issued.record, 'a@gmail.com', 'login', issued.code);
    assert.equal(r.ok, false);
    assert.equal(r.reason, 'expired');
});

test('otp enforces resend cooldown and hourly cap', () => {
    let t = 9_000_000;
    const otp = createOtpService({ secret: SECRET, now: () => t });
    let record = null;
    for (let i = 0; i < OTP_MAX_SENDS_PER_HOUR; i++) {
        const r = otp.issue(record, 'a@gmail.com', 'login');
        assert.equal(r.ok, true);
        record = r.record;
        const blocked = otp.issue(record, 'a@gmail.com', 'login');
        assert.equal(blocked.reason, 'cooldown');
        t += OTP_RESEND_COOLDOWN_MS + 1;
    }
    const capped = otp.issue(record, 'a@gmail.com', 'login');
    assert.equal(capped.reason, 'hourly_limit');
    t += 60 * 60 * 1000;
    assert.equal(otp.issue(record, 'a@gmail.com', 'login').ok, true);
});

test('otp service refuses weak secrets', () => {
    assert.throws(() => createOtpService({ secret: 'short' }));
});

test('device key rejects malformed public keys', () => {
    assert.equal(normalizeDeviceKey(null), null);
    assert.equal(normalizeDeviceKey({ kty: 'RSA' }), null);
    assert.equal(normalizeDeviceKey({ kty: 'EC', crv: 'P-256', x: 'a', y: 'b' }), null);
    assert.equal(normalizeDeviceKey({ kty: 'EC', crv: 'P-256', x: '!'.repeat(43), y: '!'.repeat(43) }), null);
});

test('a session works only with the device that created it', async () => {
    const now = () => Date.now();
    const verify = createProofVerifier({ now });
    const victim = createDeviceKey({ store: memoryStore() });
    const attacker = createDeviceKey({ store: memoryStore() });
    const created = createSession({ userId: 'u1', deviceJwk: await victim.publicJwk() });
    assert.ok(created);
    const record = created.record;
    const path = '/api/me?x=1';

    const own = await victim.sign('GET', path);
    assert.deepEqual(verify({ method: 'GET', path, record, proof: own }), { ok: true });

    const stolen = await attacker.sign('GET', path);
    assert.equal(verify({ method: 'GET', path, record, proof: stolen }).reason, 'proof_invalid');

    assert.equal(verify({ method: 'GET', path, record, proof: undefined }).reason, 'proof_missing');
    assert.equal(verify({ method: 'GET', path, record, proof: 'a.b.c' }).reason, 'proof_missing');
});

test('proofs cannot be replayed, retargeted or reused late', async () => {
    let t = Date.now();
    const verify = createProofVerifier({ now: () => t });
    const device = createDeviceKey({ store: memoryStore(), now: () => t });
    const { record } = createSession({ userId: 'u1', deviceJwk: await device.publicJwk(), now: t });

    const proof = await device.sign('POST', '/api/articles');
    assert.equal(verify({ method: 'POST', path: '/api/articles', record, proof }).ok, true);
    assert.equal(verify({ method: 'POST', path: '/api/articles', record, proof }).reason, 'proof_replay');

    const second = await device.sign('POST', '/api/articles');
    assert.equal(verify({ method: 'POST', path: '/api/me', record, proof: second }).reason, 'proof_invalid');
    assert.equal(verify({ method: 'GET', path: '/api/articles', record, proof: second }).reason, 'proof_invalid');

    const third = await device.sign('POST', '/api/articles');
    t += 61000;
    assert.equal(verify({ method: 'POST', path: '/api/articles', record, proof: third }).reason, 'proof_stale');
});

test('proof from the same key still fails for another session record', async () => {
    const verify = createProofVerifier();
    const a = createDeviceKey({ store: memoryStore() });
    const b = createDeviceKey({ store: memoryStore() });
    const sessionB = createSession({ userId: 'u2', deviceJwk: await b.publicJwk() }).record;
    const proof = await a.sign('GET', '/api/me');
    assert.equal(verify({ method: 'GET', path: '/api/me', record: sessionB, proof }).reason, 'proof_invalid');
});

test('device key persists and reset creates a new identity', async () => {
    const store = memoryStore();
    const one = createDeviceKey({ store });
    const first = await one.publicJwk();
    const two = createDeviceKey({ store });
    assert.deepEqual(await two.publicJwk(), first);
    await two.reset();
    const three = createDeviceKey({ store });
    assert.notDeepEqual(await three.publicJwk(), first);
});

test('session expiry and idle timeout', () => {
    const base = 1_700_000_000_000;
    const record = { expiresAt: base + SESSION_ABSOLUTE_MS, lastSeenAt: base };
    assert.equal(sessionState(record, base + 1000), 'ok');
    assert.equal(sessionState(record, base + SESSION_IDLE_MS + 1), 'idle');
    assert.equal(sessionState({ ...record, lastSeenAt: base + SESSION_ABSOLUTE_MS }, base + SESSION_ABSOLUTE_MS + 1), 'expired');
    assert.equal(sessionState(null, base), 'missing');
});
VERO_EOF_52
echo "yazildi: tests/auth-core.test.mjs"

mkdir -p "tests"
cat > "tests/news-core.test.mjs" <<'VERO_EOF_53'
import test from 'node:test';
import assert from 'node:assert/strict';
import { slugify, reportSlug, isReportSlug } from '../lib/slug.js';
import { createLimiter, clientIp } from '../lib/rate-limit.js';
import { extractJson, validateOverview } from '../lib/overview/validate.js';
import { overviewConfig, generateOverview } from '../lib/overview/generate.js';
import { buildMaterial } from '../lib/overview/prompt.js';

const report = {
    source: 'BBC News',
    sourceRegion: 'United Kingdom',
    title: 'Ukrainian military hit the Crimean bridge during a Russian attack on the Dnieper',
    description: 'Ten people were injured when the bridge was struck, regional officials said.',
    publishedAt: '2026-11-19T10:00:00.000Z'
};
const theater = { title: 'Russo-Ukrainian Conflict', desc: 'Frontline monitoring, territory changes, and tactical air/artillery activity.' };
const material = buildMaterial({ report, theater, related: [{ title: 'Kyiv reports overnight drone attacks', source: 'Reuters' }] });

const good = {
    title: 'Crimean bridge struck as Ukraine and Russia trade attacks near the Dnieper',
    summary: 'BBC News reports that Ukrainian forces struck the Crimean bridge while Russia attacked positions along the Dnieper. Regional officials said ten people were injured in the incident.',
    context: 'The Russo-Ukrainian Conflict is tracked through frontline monitoring and territory changes, so strikes on key crossings matter for tactical conditions.',
    keyPoints: [
        'BBC News reports a strike on the Crimean bridge.',
        'Ukrainian and Russian forces are both named as acting.',
        'The cause and full extent of damage are not stated.'
    ]
};

test('slug helpers build stable, safe slugs', () => {
    assert.equal(slugify('Ukraine: Kyiv hit by drones & missiles!'), 'ukraine-kyiv-hit-by-drones-and-missiles');
    assert.equal(slugify('\u0623\u062e\u0628\u0627\u0631 \u0639\u0627\u062c\u0644\u0629'), '');
    const slug = reportSlug('Hello World', 'https://example.com/a');
    assert.match(slug, /^hello-world-[a-f0-9]{10}$/);
    assert.equal(slug, reportSlug('Hello World', 'https://example.com/a'));
    assert.notEqual(slug, reportSlug('Hello World', 'https://example.com/b'));
    assert.match(reportSlug('\u0623\u062e\u0628\u0627\u0631', 'https://example.com/a'), /^report-[a-f0-9]{10}$/);
    assert.ok(slugify('a'.repeat(200)).length <= 60);
    assert.equal(isReportSlug(slug), true);
    for (const bad of ['', '../etc', 'abc', 'Hello-World-aaaaaaaaaa', 'x-aaaaaaaaaaa', 'x-gggggggggg', 'a'.repeat(120) + '-aaaaaaaaaa', null, 5]) {
        assert.equal(isReportSlug(bad), false);
    }
});

test('limiter blocks after the limit and recovers', () => {
    const limiter = createLimiter({ limit: 3, windowMs: 1000 });
    assert.equal(limiter.check('a', 0).ok, true);
    assert.equal(limiter.check('a', 10).ok, true);
    assert.equal(limiter.check('a', 20).ok, true);
    const blocked = limiter.check('a', 30);
    assert.equal(blocked.ok, false);
    assert.ok(blocked.retryAfter >= 1);
    assert.equal(limiter.check('b', 30).ok, true);
    assert.equal(limiter.check('a', 1100).ok, true);
});

test('client ip takes the first forwarded address', () => {
    const headers = new Headers({ 'x-forwarded-for': '1.2.3.4, 5.6.7.8' });
    assert.equal(clientIp(headers), '1.2.3.4');
    assert.equal(clientIp(new Headers()), 'unknown');
});

test('overview validation accepts a grounded overview', () => {
    const result = validateOverview(good, material.sourceText);
    assert.equal(result.ok, true);
    assert.equal(result.value.keyPoints.length, 3);
});

test('overview validation rejects unsafe or ungrounded output', () => {
    const cases = [
        [{ ...good, summary: good.summary + ' See https://example.com' }, 'forbidden_content'],
        [{ ...good, summary: good.summary.replace('struck', '"struck"') }, 'forbidden_content'],
        [{ ...good, summary: good.summary + ' About 12 people were hurt.' }, 'unsupported_number'],
        [{ ...good, keyPoints: good.keyPoints.slice(0, 2) }, 'key_points_count'],
        [{ ...good, title: 'x'.repeat(200) }, 'too_long'],
        [{ ...good, title: 'Short' }, 'too_short'],
        [{ ...good, summary: ('\u0645\u0644\u062e\u0635 \u0639\u0631\u0628\u064a \u0637\u0648\u064a\u0644 \u062c\u062f\u0627 \u064a\u062d\u062a\u0648\u064a \u0639\u0644\u0649 \u0627\u0644\u0643\u062b\u064a\u0631 \u0645\u0646 \u0627\u0644\u0643\u0644\u0645\u0627\u062a \u0627\u0644\u0639\u0631\u0628\u064a\u0629 \u0647\u0646\u0627 \u0644\u0627\u062e\u062a\u0628\u0627\u0631 \u0627\u0644\u0644\u063a\u0629 ').repeat(3) }, 'not_english'],
        [{ ...good, summary: 'Ten people were injured when the bridge was struck, regional officials said, according to the report.' }, 'copied_text'],
        [null, 'not_object'],
        [{ ...good, context: '' }, 'missing_field']
    ];
    for (const [input, reason] of cases) {
        const result = validateOverview(input, material.sourceText);
        assert.equal(result.ok, false, reason);
        assert.equal(result.reason, reason);
    }
});

test('extractJson tolerates fences and surrounding text', () => {
    assert.deepEqual(extractJson('```json\n{"a":1}\n```'), { a: 1 });
    assert.deepEqual(extractJson('Here you go: {"a":2} thanks'), { a: 2 });
    assert.equal(extractJson('no json'), null);
    assert.equal(extractJson('{broken'), null);
});

test('overview config requires https and all variables', () => {
    assert.equal(overviewConfig({}), null);
    assert.equal(overviewConfig({ LLM_BASE_URL: 'http://x.test', LLM_API_KEY: 'k', LLM_MODEL: 'm' }), null);
    const config = overviewConfig({ LLM_BASE_URL: 'https://x.test/v1/', LLM_API_KEY: 'k', LLM_MODEL: 'm', OVERVIEW_DAILY_LIMIT: '40' });
    assert.equal(config.baseUrl, 'https://x.test/v1');
    assert.equal(config.dailyLimit, 40);
    assert.equal(overviewConfig({ LLM_BASE_URL: 'https://x.test', LLM_API_KEY: 'k', LLM_MODEL: 'm', OVERVIEW_DAILY_LIMIT: 'abc' }).dailyLimit, 150);
});

function fakeFetch(replies) {
    const calls = [];
    const impl = async (url, init) => {
        calls.push({ url, body: JSON.parse(init.body) });
        const next = replies.shift();
        if (next.status && next.status !== 200) return { ok: false, status: next.status, json: async () => ({}) };
        return { ok: true, status: 200, json: async () => ({ choices: [{ message: { content: next.content } }] }) };
    };
    impl.calls = calls;
    return impl;
}

const config = { baseUrl: 'https://x.test/v1', apiKey: 'k', model: 'm', dailyLimit: 10 };

test('generation returns a validated overview', async () => {
    const f = fakeFetch([{ content: JSON.stringify(good) }]);
    const result = await generateOverview(material, config, f);
    assert.equal(result.ok, true);
    assert.equal(f.calls.length, 1);
    assert.equal(f.calls[0].url, 'https://x.test/v1/chat/completions');
    assert.equal(f.calls[0].body.messages[0].role, 'system');
});

test('generation retries once after a rejected answer', async () => {
    const f = fakeFetch([{ content: JSON.stringify({ ...good, summary: good.summary + ' See https://example.com' }) }, { content: JSON.stringify(good) }]);
    const result = await generateOverview(material, config, f);
    assert.equal(result.ok, true);
    assert.equal(f.calls.length, 2);
    assert.match(f.calls[1].body.messages.at(-1).content, /rejected \(forbidden_content\)/);
});

test('generation gives up cleanly', async () => {
    const bad = JSON.stringify({ ...good, keyPoints: [] });
    const twice = await generateOverview(material, config, fakeFetch([{ content: bad }, { content: bad }]));
    assert.deepEqual([twice.ok, twice.reason], [false, 'key_points_count']);
    const limited = await generateOverview(material, config, fakeFetch([{ status: 429 }]));
    assert.deepEqual([limited.ok, limited.reason], [false, 'provider_429']);
    const none = await generateOverview(material, null, fakeFetch([]));
    assert.equal(none.reason, 'not_configured');
});
VERO_EOF_53
echo "yazildi: tests/news-core.test.mjs"

echo ""
echo "Tamam. Simdi: npm install"
