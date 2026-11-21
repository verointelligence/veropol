#!/usr/bin/env bash
set -e

if [ ! -d old-site/css ] || [ ! -f app/layout.js ]; then echo "HATA: Bu komutu veropol klasorunun icinde calistir (once setup-vero-next-2.sh calismis olmali)."; exit 1; fi

cat > ".env.example" <<'VERO_EOF_0'
NEXT_PUBLIC_SITE_URL=http://localhost:3000
MONGODB_URI=
GNEWS_API_KEY=
LLM_BASE_URL=
LLM_API_KEY=
LLM_MODEL=
OVERVIEW_DAILY_LIMIT=150
AUTH_SECRET=
MAIL_FROM=
BREVO_API_KEY=
RESEND_API_KEY=
ADMIN_EMAILS=
VERO_EOF_0
echo "yazildi: .env.example"

mkdir -p "app/account"
cat > "app/account/page.js" <<'VERO_EOF_1'
import AccountPanel from '@/components/AccountPanel';

export const metadata = {
    title: 'Account',
    alternates: { canonical: '/account' },
    robots: { index: false, follow: false }
};

export default function AccountPage() {
    return <AccountPanel />;
}
VERO_EOF_1
echo "yazildi: app/account/page.js"

mkdir -p "app/api/articles/[slug]"
cat > "app/api/articles/[slug]/route.js" <<'VERO_EOF_2'
import { adminSet, failure, guard, json, limits, requireUser } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';
import { deleteArticle, updateArticle } from '@/lib/articles';

export const dynamic = 'force-dynamic';

export async function PATCH(request, { params }) {
    const { slug } = await params;
    const blocked = await guard(request, limits.mutate);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    const body = await readJson(request, 40000);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await updateArticle(slug, session.user, body, adminSet().has(session.user.email));
    return result.ok ? json({ ok: true, slug: result.slug }) : failure(result);
}

export async function DELETE(request, { params }) {
    const { slug } = await params;
    const blocked = await guard(request, limits.mutate);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    const result = await deleteArticle(slug, session.user, adminSet().has(session.user.email));
    return result.ok ? json({ ok: true }) : failure(result);
}
VERO_EOF_2
echo "yazildi: app/api/articles/[slug]/route.js"

mkdir -p "app/api/articles"
cat > "app/api/articles/route.js" <<'VERO_EOF_3'
import { failure, guard, json, limits, requireUser, shapeSelf } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';
import { createArticle } from '@/lib/articles';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.mutate);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    if (!shapeSelf(session.user).isAdult) return json({ ok: false, reason: 'adult_only' }, 403);
    const body = await readJson(request, 40000);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await createArticle(session.user, body);
    return result.ok ? json({ ok: true, slug: result.slug }, 201) : failure(result);
}
VERO_EOF_3
echo "yazildi: app/api/articles/route.js"

mkdir -p "app/api/auth/code"
cat > "app/api/auth/code/route.js" <<'VERO_EOF_4'
import { failure, getAuth, guard, json, limits } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.code);
    if (blocked) return blocked;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await getAuth().requestCode({ email: body.email });
    return result.ok ? json({ ok: true }) : failure(result);
}
VERO_EOF_4
echo "yazildi: app/api/auth/code/route.js"

mkdir -p "app/api/auth/complete"
cat > "app/api/auth/complete/route.js" <<'VERO_EOF_5'
import { failure, getAuth, guard, json, limits, sessionCookies, shapeSelf } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.complete);
    if (blocked) return blocked;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await getAuth().completeSignup({ ticket: body.ticket, username: body.username, birthDate: body.birthDate, deviceJwk: body.deviceJwk });
    if (!result.ok) return failure(result);
    return json({ ok: true, status: 'signed_in', user: shapeSelf(result.user) }, 201, sessionCookies(result.token));
}
VERO_EOF_5
echo "yazildi: app/api/auth/complete/route.js"

mkdir -p "app/api/auth/logout"
cat > "app/api/auth/logout/route.js" <<'VERO_EOF_6'
import { clearCookies, guard, json, limits, requireUser } from '@/lib/auth/instance';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.mutate);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    await session.auth.logout({ session: session.session });
    return json({ ok: true }, 200, clearCookies());
}
VERO_EOF_6
echo "yazildi: app/api/auth/logout/route.js"

mkdir -p "app/api/auth/verify"
cat > "app/api/auth/verify/route.js" <<'VERO_EOF_7'
import { failure, getAuth, guard, json, limits, sessionCookies, shapeSelf } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.verify);
    if (blocked) return blocked;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await getAuth().verifyCode({ email: body.email, code: body.code, deviceJwk: body.deviceJwk });
    if (!result.ok) return failure(result);
    if (result.status === 'profile_required') return json({ ok: true, status: 'profile_required', ticket: result.ticket });
    return json({ ok: true, status: 'signed_in', user: shapeSelf(result.user) }, 200, sessionCookies(result.token));
}
VERO_EOF_7
echo "yazildi: app/api/auth/verify/route.js"

mkdir -p "app/api/live/preview"
cat > "app/api/live/preview/route.js" <<'VERO_EOF_8'
import { previewRows } from '@/lib/preview';
import { clientIp, createLimiter } from '@/lib/rate-limit';

export const dynamic = 'force-dynamic';

const limiter = createLimiter({ limit: 120, windowMs: 60 * 1000 });

function reply(body, status = 200, extra = {}) {
    return new Response(JSON.stringify(body), {
        status,
        headers: { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store', ...extra }
    });
}

export async function GET(request) {
    const verdict = limiter.check(clientIp(request.headers));
    if (!verdict.ok) return reply({ rows: [] }, 429, { 'Retry-After': String(verdict.retryAfter) });
    try {
        return reply({ rows: await previewRows(4) });
    } catch {
        return reply({ rows: [] }, 200);
    }
}
VERO_EOF_8
echo "yazildi: app/api/live/preview/route.js"

mkdir -p "app/api/me/email/confirm"
cat > "app/api/me/email/confirm/route.js" <<'VERO_EOF_9'
import { failure, guard, json, limits, requireUser, shapeSelf } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.verify);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await session.auth.confirmEmailChange({ user: session.user, newEmail: body.email, code: body.code });
    return result.ok ? json({ ok: true, user: shapeSelf(result.user) }) : failure(result);
}
VERO_EOF_9
echo "yazildi: app/api/me/email/confirm/route.js"

mkdir -p "app/api/me/email"
cat > "app/api/me/email/route.js" <<'VERO_EOF_10'
import { failure, guard, json, limits, requireUser } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.emailChange);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await session.auth.requestEmailChange({ user: session.user, newEmail: body.email });
    return result.ok ? json({ ok: true }) : failure(result);
}
VERO_EOF_10
echo "yazildi: app/api/me/email/route.js"

mkdir -p "app/api/me"
cat > "app/api/me/route.js" <<'VERO_EOF_11'
import { failure, guard, json, limits, requireUser, shapeSelf } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function GET(request) {
    const session = await requireUser(request);
    if (session.response) return session.response;
    return json({ ok: true, user: shapeSelf(session.user) });
}

export async function PATCH(request) {
    const blocked = await guard(request, limits.mutate);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await session.auth.updateProfile({ user: session.user, displayName: body.displayName, bio: body.bio });
    return result.ok ? json({ ok: true, user: shapeSelf(result.user) }) : failure(result);
}
VERO_EOF_11
echo "yazildi: app/api/me/route.js"

mkdir -p "app/api/me/username"
cat > "app/api/me/username/route.js" <<'VERO_EOF_12'
import { failure, guard, json, limits, requireUser, shapeSelf } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.mutate);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await session.auth.changeUsername({ user: session.user, username: body.username });
    if (result.ok) return json({ ok: true, user: shapeSelf(result.user) });
    if (result.reason === 'cooldown') return json({ ok: false, reason: 'cooldown', retryAt: result.retryAt }, 429);
    return failure(result);
}
VERO_EOF_12
echo "yazildi: app/api/me/username/route.js"

mkdir -p "app/articles/[slug]/edit"
cat > "app/articles/[slug]/edit/page.js" <<'VERO_EOF_13'
import { notFound } from 'next/navigation';
import ArticleEditor from '@/components/ArticleEditor';
import { getArticle } from '@/lib/articles';
import { isArticleSlug } from '@/lib/articles-core';

export const dynamic = 'force-dynamic';

export const metadata = {
    title: 'Edit article',
    robots: { index: false, follow: false }
};

export default async function EditArticlePage({ params }) {
    const { slug } = await params;
    if (!isArticleSlug(slug)) notFound();
    const article = await getArticle(slug);
    if (!article) notFound();
    return (
        <ArticleEditor
            mode="edit"
            slug={slug}
            authorUsername={article.author ? article.author.username : ''}
            initial={{ title: article.title, category: article.category, summary: article.summary, body: article.body }}
        />
    );
}
VERO_EOF_13
echo "yazildi: app/articles/[slug]/edit/page.js"

mkdir -p "app/articles/[slug]"
cat > "app/articles/[slug]/page.js" <<'VERO_EOF_14'
import Link from 'next/link';
import { notFound } from 'next/navigation';
import ArticleActions from '@/components/ArticleActions';
import { getArticle } from '@/lib/articles';
import { isArticleSlug, parseBody, readingMinutes } from '@/lib/articles-core';
import { CATEGORIES, formatDate, jsonLd } from '@/lib/format';
import { SITE_URL } from '@/lib/site';
import { BADGES } from '@/content/badges';

export const dynamic = 'force-dynamic';

export async function generateMetadata({ params }) {
    const { slug } = await params;
    const article = await getArticle(slug);
    if (!article) return { title: 'Article not found', robots: { index: false, follow: false } };
    return {
        title: article.title,
        description: article.summary,
        alternates: { canonical: '/articles/' + slug },
        robots: { index: true, follow: true },
        openGraph: { type: 'article', title: article.title, description: article.summary, url: '/articles/' + slug, publishedTime: new Date(article.createdAt).toISOString() }
    };
}

export default async function ArticlePage({ params }) {
    const { slug } = await params;
    if (!isArticleSlug(slug)) notFound();
    const article = await getArticle(slug);
    if (!article) notFound();
    const cat = CATEGORIES[article.category] || CATEGORIES.intel;
    const blocks = parseBody(article.body);
    const author = article.author;

    const graph = {
        '@context': 'https://schema.org',
        '@type': 'Article',
        headline: article.title,
        description: article.summary,
        datePublished: new Date(article.createdAt).toISOString(),
        dateModified: new Date(article.updatedAt || article.createdAt).toISOString(),
        author: author ? { '@type': 'Person', name: author.displayName, url: SITE_URL + '/u/' + author.username } : { '@type': 'Organization', name: 'VERO' },
        publisher: { '@type': 'Organization', name: 'VERO', logo: { '@type': 'ImageObject', url: SITE_URL + '/assets/icon-512.png' } },
        mainEntityOfPage: SITE_URL + '/articles/' + slug
    };

    return (
        <div className="page-report">
            <main className="report-page">
                <nav className="crumbs" aria-label="Breadcrumb">
                    <Link href="/">Home</Link><span>/</span><Link href="/articles">Articles</Link><span>/</span><span aria-current="page">{cat.label}</span>
                </nav>
                <article>
                    <header className="report-head">
                        <div className="report-chips">
                            <span className="card-tag static"><i className={'ph ' + cat.icon} /> {cat.label}</span>
                        </div>
                        <h1 className="report-title" dir="auto">{article.title}</h1>
                        <p className="report-meta">
                            {author ? <Link href={'/u/' + author.username}>{author.displayName}</Link> : <span>VERO member</span>}
                            <span>{formatDate(article.createdAt)}</span>
                            <span>{readingMinutes(article.body)} min read</span>
                            {article.updatedAt ? <span>Updated {formatDate(article.updatedAt)}</span> : null}
                        </p>
                        {author && author.badges.some(b => b === 'verified' || b === 'expert' || b === 'editor') ? (
                            <div className="badge-row">
                                {author.badges.filter(b => BADGES[b] && b !== 'email_verified').map(b => (
                                    <span className="badge-chip" key={b}><i className={'ph ' + BADGES[b].icon} /> {BADGES[b].label}</span>
                                ))}
                            </div>
                        ) : null}
                    </header>
                    <p className="report-lead" dir="auto">{article.summary}</p>
                    <div className="article-body" dir="auto">
                        {blocks.map((block, i) => {
                            if (block.type === 'h2') return <h2 key={i}>{block.text}</h2>;
                            if (block.type === 'ul') return <ul key={i}>{block.items.map((item, j) => <li key={j}>{item}</li>)}</ul>;
                            return <p key={i}>{block.text}</p>;
                        })}
                    </div>
                    <ArticleActions slug={slug} authorUsername={author ? author.username : ''} />
                    <p className="report-note">This article reflects the views of its author, not of VERO. <Link href="/terms">Terms</Link></p>
                </article>
            </main>
            <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: jsonLd(graph) }} />
        </div>
    );
}
VERO_EOF_14
echo "yazildi: app/articles/[slug]/page.js"

mkdir -p "app/articles/new"
cat > "app/articles/new/page.js" <<'VERO_EOF_15'
import ArticleEditor from '@/components/ArticleEditor';

export const metadata = {
    title: 'Write an article',
    alternates: { canonical: '/articles/new' },
    robots: { index: false, follow: false }
};

export default function NewArticlePage() {
    return <ArticleEditor mode="new" />;
}
VERO_EOF_15
echo "yazildi: app/articles/new/page.js"

mkdir -p "app/articles"
cat > "app/articles/page.js" <<'VERO_EOF_16'
import Link from 'next/link';
import ArticleCard from '@/components/ArticleCard';
import Pagination from '@/components/Pagination';
import { ARTICLE_CATEGORIES } from '@/lib/articles-core';
import { listArticles } from '@/lib/articles';
import { CATEGORIES } from '@/lib/format';

export const dynamic = 'force-dynamic';

const PAGE_SIZE = 9;

function read(sp) {
    const one = v => (Array.isArray(v) ? v[0] : v);
    const cat = ARTICLE_CATEGORIES.includes(String(one(sp.cat))) ? String(one(sp.cat)) : '';
    const page = Math.min(Math.max(parseInt(one(sp.page), 10) || 1, 1), 500);
    return { cat, page };
}

function href(cat, page = 1) {
    const p = new URLSearchParams();
    if (cat) p.set('cat', cat);
    if (page > 1) p.set('page', String(page));
    const s = p.toString();
    return '/articles' + (s ? '?' + s : '');
}

export async function generateMetadata({ searchParams }) {
    const state = read(await searchParams);
    return {
        title: 'Articles',
        description: 'Signed analysis and opinion on diplomacy, security and the global economy from independent authors.',
        alternates: { canonical: '/articles' },
        robots: state.cat || state.page > 1 ? { index: false, follow: true } : { index: true, follow: true }
    };
}

export default async function ArticlesPage({ searchParams }) {
    const state = read(await searchParams);
    const result = await listArticles({ category: state.cat, page: state.page, size: PAGE_SIZE });
    return (
        <div className="page-explore">
            <main className="container explore-main">
                <header className="page-head">
                    <h1>Articles</h1>
                    <p>Signed analysis and opinion from independent authors.</p>
                    <div className="head-actions">
                        <Link href="/articles/new" className="btn-primary"><i className="ph ph-pen-nib" /> <span>Write for VERO</span></Link>
                    </div>
                </header>
                <nav className="pill-row" aria-label="Categories">
                    <Link className={'suggestion-pill' + (!state.cat ? ' active' : '')} href="/articles" prefetch={false}>All</Link>
                    {ARTICLE_CATEGORIES.map(key => (
                        <Link key={key} className={'suggestion-pill' + (state.cat === key ? ' active' : '')} href={href(key)} prefetch={false}>{CATEGORIES[key].label}</Link>
                    ))}
                </nav>
                {result.items.length ? (
                    <section className="flex-grid news-grid" id="newsGrid">
                        {result.items.map(item => <ArticleCard key={item.slug} article={item} />)}
                    </section>
                ) : (
                    <section className="flex-grid news-grid" id="newsGrid">
                        <p className="grid-msg">{result.available ? 'No articles here yet. Be the first to publish.' : 'Articles are temporarily unavailable. Please try again in a minute.'}</p>
                    </section>
                )}
                <Pagination page={result.page} totalPages={result.totalPages} hrefFor={p => href(state.cat, p)} />
            </main>
        </div>
    );
}
VERO_EOF_16
echo "yazildi: app/articles/page.js"

mkdir -p "app/css"
cat > "app/css/forms.css" <<'VERO_EOF_17'
.auth-page {
    min-height: 100vh;
    display: grid;
    place-items: center;
    padding: 130px 20px 60px;
}

.auth-card {
    width: min(460px, 100%);
    padding: 32px;
    border-radius: var(--r-lg);
    border: 1px solid var(--line);
    background: var(--surface);
    box-shadow: var(--shadow-md);
}

.auth-card h1,
.editor-page h1,
.account-head h1 {
    margin: 0 0 10px;
    font-size: clamp(1.5rem, 4vw, 2rem);
    letter-spacing: -0.02em;
}

.auth-lead {
    margin: 0 0 20px;
    color: var(--muted);
    line-height: 1.6;
}

.auth-hint {
    margin: 6px 0 14px;
    font-size: 0.8rem;
    line-height: 1.5;
    color: var(--muted);
}

.auth-hint a {
    color: var(--accent);
    font-weight: 700;
}

.auth-error,
.auth-ok {
    margin: 0 0 14px;
    padding: 10px 14px;
    border-radius: var(--r-sm);
    font-size: 0.86rem;
    font-weight: 700;
}

.auth-error {
    color: var(--danger);
    border: 1px solid var(--danger);
}

.auth-ok {
    color: var(--success);
    border: 1px solid var(--success);
}

.field {
    display: grid;
    gap: 8px;
    margin-bottom: 14px;
}

.field span {
    font-size: 0.74rem;
    font-weight: 800;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--muted);
}

.field input,
.field textarea,
.field select {
    width: 100%;
    padding: 13px 16px;
    border-radius: var(--r-sm);
    border: 1px solid var(--line);
    background: var(--bg);
    color: var(--text);
    font-family: inherit;
    font-size: 1rem;
    transition: border-color 0.2s;
}

.field textarea {
    resize: vertical;
    line-height: 1.6;
}

.field input:focus,
.field textarea:focus,
.field select:focus {
    outline: none;
    border-color: var(--accent);
}

.field input:disabled {
    opacity: 0.55;
    cursor: not-allowed;
}

.code-input {
    font-family: ui-monospace, Menlo, Consolas, monospace;
    font-size: 1.6rem;
    letter-spacing: 0.5em;
    text-align: center;
}

.auth-submit {
    width: 100%;
    justify-content: center;
}

.btn-primary:disabled,
.btn-ghost:disabled {
    opacity: 0.55;
    cursor: not-allowed;
}

.auth-links {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    margin-top: 14px;
}

.link-btn {
    padding: 6px 2px;
    border: 0;
    background: transparent;
    color: var(--accent);
    font-size: 0.86rem;
    font-weight: 700;
    cursor: pointer;
}

.link-btn:disabled {
    color: var(--muted);
    cursor: not-allowed;
}

.account-page,
.editor-page {
    max-width: 980px;
    margin: 0 auto;
    padding: 130px 20px 80px;
}

.editor-page {
    max-width: 780px;
}

.account-head {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 20px;
    margin-bottom: 32px;
}

.account-head>div:nth-child(2) {
    flex: 1 1 260px;
    min-width: 0;
}

.avatar-circle {
    width: 76px;
    height: 76px;
    flex: none;
    display: grid;
    place-items: center;
    border-radius: 50%;
    background: var(--grad);
    color: #fff;
    font-family: var(--font-head);
    font-size: 1.9rem;
    font-weight: 800;
}

.account-handle {
    margin: 0 0 8px;
    font-weight: 700;
    color: var(--muted);
}

.account-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

.badge-row {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 8px;
}

.badge-chip {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 5px 12px;
    border-radius: 999px;
    border: 1px solid var(--line);
    background: var(--accent-soft);
    color: var(--accent);
    font-size: 0.74rem;
    font-weight: 800;
}

.account-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 20px;
}

.account-card {
    padding: 24px;
    border-radius: var(--r-lg);
    border: 1px solid var(--line);
    background: var(--surface);
}

.account-card h2 {
    margin: 0 0 16px;
    font-size: 1.1rem;
}

.editor-form {
    margin-top: 8px;
}

.editor-body {
    min-height: 320px;
}

.pill-row {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 10px;
    margin: 0 0 32px;
}

.suggestion-pill.active {
    border-color: var(--accent);
    color: var(--accent);
}

.article-body {
    max-width: 68ch;
    margin-bottom: 30px;
}

.article-body h2 {
    margin: 34px 0 12px;
    font-size: 1.35rem;
}

.article-body p,
.article-body li {
    color: var(--text);
    font-size: 1.04rem;
    line-height: 1.8;
}

.article-body p {
    margin: 0 0 18px;
}

.article-body ul {
    margin: 0 0 18px;
    padding-inline-start: 22px;
}

.article-actions {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 10px;
    margin-bottom: 26px;
}

.btn-ghost.danger {
    color: var(--danger);
    border-color: var(--danger);
}

.pv-empty {
    padding: 22px 4px;
    font-size: 0.9rem;
    font-weight: 600;
    line-height: 1.5;
    color: var(--muted);
}

@media (max-width: 760px) {
    .account-grid {
        grid-template-columns: minmax(0, 1fr);
    }

    .auth-card {
        padding: 24px 20px;
    }

    .account-page,
    .editor-page {
        padding-top: 110px;
    }
}
VERO_EOF_17
echo "yazildi: app/css/forms.css"

mkdir -p "app/css"
cat > "app/css/report.css" <<'VERO_EOF_18'
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

.page-head .head-actions {
    margin-top: 18px;
}
VERO_EOF_18
echo "yazildi: app/css/report.css"

mkdir -p "app/explore"
cat > "app/explore/page.js" <<'VERO_EOF_19'
import Link from 'next/link';
import { headers } from 'next/headers';
import AutoRefresh from '@/components/AutoRefresh';
import FilterDrawer from '@/components/FilterDrawer';
import Pagination from '@/components/Pagination';
import ReportCard from '@/components/ReportCard';
import { CATEGORIES, RANGES, REGION_KEYS, TOPIC_KEYS } from '@/lib/format';
import { dbReady } from '@/lib/db';
import sources from '@/lib/news/sources.cjs';
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
    const linkable = await dbReady();
    const overviews = articles.length && linkable ? await ingest(articles, { warm: 0 }).catch(() => new Map()) : new Map();
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
            <AutoRefresh seconds={300} />
            <main className="container explore-main">
                <header className="page-head">
                    <h1>Explore</h1>
                    <p>{'Search any region, leader or crisis across ' + sources.TRUSTED_SOURCES.length + ' vetted sources.'}</p>
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
                                    <ReportCard key={item.url} item={item} overview={overviews.get(reportSlug(item.title, item.url))} eager={i < 3} linkable={linkable} />
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
VERO_EOF_19
echo "yazildi: app/explore/page.js"

mkdir -p "app"
cat > "app/layout.js" <<'VERO_EOF_20'
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
import './css/forms.css';
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
VERO_EOF_20
echo "yazildi: app/layout.js"

mkdir -p "app/live/[theater]"
cat > "app/live/[theater]/page.js" <<'VERO_EOF_21'
import Link from 'next/link';
import { notFound } from 'next/navigation';
import AutoRefresh from '@/components/AutoRefresh';
import ReportCard from '@/components/ReportCard';
import { THEATERS, isTheater } from '@/content/theaters';
import { dbReady } from '@/lib/db';
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
    let total = 0;
    const linkable = await dbReady();
    try {
        const result = await getEngine().search({ q: t.query, category: 'all', range: '7d', page: 1, size: 12, uiLang: 'en', detect: false, client: null });
        articles = result.articles || [];
        total = result.total || 0;
    } catch {
        articles = [];
    }
    const overviews = linkable ? await ingest(articles, { theater, warm: 3 }).catch(() => new Map()) : new Map();
    const archive = linkable ? await theaterReports(theater, 9) : [];
    const stats = [
        { label: 'Reports (7d)', value: String(total), tone: total >= 60 ? 'alert' : total >= 20 ? 'warning' : '' },
        { label: 'Sources', value: String(new Set(articles.map(a => a.source)).size), tone: '' }
    ];
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
            <AutoRefresh seconds={300} />
            <main className="container live-main">
                <nav className="crumbs" aria-label="Breadcrumb">
                    <Link href="/">Home</Link><span>/</span><Link href="/live">Live</Link><span>/</span><span aria-current="page">{t.title}</span>
                </nav>
                <header className="page-head theater-head">
                    <div className={'theater-badge static ' + t.tone}><i className={'ph ' + t.icon} /> {t.badge}</div>
                    <h1>{t.title}</h1>
                    <p>{t.desc}</p>
                    <div className="theater-stats head-stats">
                        {stats.map(stat => (
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
                                <ReportCard key={item.url} item={item} overview={overviews.get(reportSlug(item.title, item.url))} eager={i < 3} linkable={linkable} />
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
VERO_EOF_21
echo "yazildi: app/live/[theater]/page.js"

mkdir -p "app/live"
cat > "app/live/page.js" <<'VERO_EOF_22'
import AutoRefresh from '@/components/AutoRefresh';
import { DevelopingCard, TheaterCard } from '@/components/TheaterCard';
import { THEATERS, THEATER_SECTIONS } from '@/content/theaters';
import { dbReady } from '@/lib/db';
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
    const linkable = await dbReady();
    const overviews = new Map();
    if (linkable) await Promise.all(Object.keys(data.theaters).map(async id => {
        const t = data.theaters[id];
        if (!t || !t.lead) return;
        const map = await ingest([t.lead, ...(t.more || [])], { theater: id, warm: 1 }).catch(() => new Map());
        map.forEach((v, k) => overviews.set(k, v));
    }));
    const devMap = linkable ? await ingest((data.developing || []).map(d => d.lead).filter(Boolean), { warm: 0 }).catch(() => new Map()) : new Map();
    devMap.forEach((v, k) => overviews.set(k, v));
    const overviewOf = lead => (lead ? overviews.get(reportSlug(lead.title, lead.url)) : undefined);

    return (
        <div className="page-live">
            <AutoRefresh seconds={300} />
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
                                <TheaterCard key={id} id={id} data={data.theaters[id]} overview={overviewOf(data.theaters[id] && data.theaters[id].lead)} linkable={linkable} />
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
                                <DevelopingCard key={card.id} card={card} overview={overviewOf(card.lead)} linkable={linkable} />
                            ))}
                        </div>
                    </section>
                ) : null}
            </main>
        </div>
    );
}
VERO_EOF_22
echo "yazildi: app/live/page.js"

mkdir -p "app/login"
cat > "app/login/page.js" <<'VERO_EOF_23'
import LoginForm from '@/components/LoginForm';

export const metadata = {
    title: 'Sign in',
    description: 'Sign in to VERO with a one-time email code.',
    alternates: { canonical: '/login' },
    robots: { index: false, follow: true }
};

export default async function LoginPage({ searchParams }) {
    const sp = await searchParams;
    const next = Array.isArray(sp.next) ? sp.next[0] : sp.next;
    return <LoginForm next={typeof next === 'string' ? next : ''} />;
}
VERO_EOF_23
echo "yazildi: app/login/page.js"

mkdir -p "app"
cat > "app/page.js" <<'VERO_EOF_24'
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
VERO_EOF_24
echo "yazildi: app/page.js"

mkdir -p "app/report/[slug]"
cat > "app/report/[slug]/page.js" <<'VERO_EOF_25'
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
VERO_EOF_25
echo "yazildi: app/report/[slug]/page.js"

mkdir -p "app"
cat > "app/sitemap.js" <<'VERO_EOF_26'
import { THEATER_IDS } from '@/content/theaters';
import { articleSlugs } from '@/lib/articles';
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
        { url: SITE_URL + '/articles', lastModified: now, changeFrequency: 'daily', priority: 0.8 },
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
    const articles = (await articleSlugs(2000)).map(d => ({
        url: SITE_URL + '/articles/' + d.slug,
        lastModified: new Date(d.updatedAt || d.createdAt),
        changeFrequency: 'weekly',
        priority: 0.7
    }));
    return [...base, ...theaters, ...reports, ...articles];
}
VERO_EOF_26
echo "yazildi: app/sitemap.js"

mkdir -p "app/u/[username]"
cat > "app/u/[username]/page.js" <<'VERO_EOF_27'
import Link from 'next/link';
import { notFound } from 'next/navigation';
import ArticleCard from '@/components/ArticleCard';
import { listArticles } from '@/lib/articles';
import { getPublicProfile } from '@/lib/auth/public';
import { formatDate } from '@/lib/format';
import { BADGES } from '@/content/badges';

export const dynamic = 'force-dynamic';

export async function generateMetadata({ params }) {
    const { username } = await params;
    const profile = await getPublicProfile(username);
    if (!profile) return { title: 'Profile not found', robots: { index: false, follow: false } };
    const result = await listArticles({ authorId: profile.id, size: 1 });
    return {
        title: profile.displayName + ' (@' + profile.username + ')',
        description: profile.bio || 'Articles and analysis by ' + profile.displayName + ' on VERO.',
        alternates: { canonical: '/u/' + profile.username },
        robots: result.total > 0 ? { index: true, follow: true } : { index: false, follow: true }
    };
}

export default async function ProfilePage({ params }) {
    const { username } = await params;
    const profile = await getPublicProfile(username);
    if (!profile) notFound();
    const result = await listArticles({ authorId: profile.id, page: 1, size: 12 });
    const items = result.items.map(item => ({ ...item, author: { displayName: profile.displayName, username: profile.username, badges: profile.badges } }));
    return (
        <div className="page-explore">
            <main className="container explore-main">
                <nav className="crumbs" aria-label="Breadcrumb">
                    <Link href="/">Home</Link><span>/</span><span aria-current="page">@{profile.username}</span>
                </nav>
                <header className="account-head">
                    <div className="avatar-circle" aria-hidden="true">{profile.displayName.slice(0, 1).toUpperCase()}</div>
                    <div>
                        <h1 dir="auto">{profile.displayName}</h1>
                        <p className="account-handle">@{profile.username} &middot; Joined {formatDate(profile.createdAt)}</p>
                        {profile.bio ? <p className="auth-lead" dir="auto">{profile.bio}</p> : null}
                        <div className="badge-row">
                            {profile.badges.filter(b => BADGES[b]).map(b => (
                                <span className="badge-chip" key={b}><i className={'ph ' + BADGES[b].icon} /> {BADGES[b].label}</span>
                            ))}
                        </div>
                    </div>
                </header>
                <section className="live-section">
                    <div className="live-section-head"><h2><i className="ph ph-newspaper" /> Articles</h2><p>{result.total} published</p></div>
                    {items.length ? (
                        <div className="flex-grid news-grid">{items.map(item => <ArticleCard key={item.slug} article={item} />)}</div>
                    ) : (
                        <p className="grid-msg">No articles yet.</p>
                    )}
                </section>
            </main>
        </div>
    );
}
VERO_EOF_27
echo "yazildi: app/u/[username]/page.js"

mkdir -p "components"
cat > "components/AccountPanel.js" <<'VERO_EOF_28'
'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { apiFetch, hasSessionMarker } from '@/lib/client/api';
import { messageFor } from '@/lib/client/messages';
import { BADGES } from '@/content/badges';

function Notice({ state }) {
    if (!state || !state.text) return null;
    return <p className={state.ok ? 'auth-ok' : 'auth-error'} role={state.ok ? 'status' : 'alert'}>{state.text}</p>;
}

export default function AccountPanel() {
    const [me, setMe] = useState(null);
    const [loading, setLoading] = useState(true);
    const [displayName, setDisplayName] = useState('');
    const [bio, setBio] = useState('');
    const [username, setUsername] = useState('');
    const [newEmail, setNewEmail] = useState('');
    const [emailCode, setEmailCode] = useState('');
    const [emailStep, setEmailStep] = useState('idle');
    const [profileNote, setProfileNote] = useState(null);
    const [nameNote, setNameNote] = useState(null);
    const [emailNote, setEmailNote] = useState(null);
    const [busy, setBusy] = useState('');

    const adopt = useCallback(user => {
        setMe(user);
        setDisplayName(user.displayName);
        setBio(user.bio || '');
        setUsername(user.username);
    }, []);

    useEffect(() => {
        let cancelled = false;
        if (!hasSessionMarker()) {
            window.location.replace('/login?next=/account');
            return undefined;
        }
        apiFetch('/api/me')
            .then(result => {
                if (cancelled) return;
                if (result.ok && result.data && result.data.ok) {
                    adopt(result.data.user);
                    setLoading(false);
                } else {
                    window.location.replace('/login?next=/account');
                }
            })
            .catch(() => {
                if (!cancelled) window.location.replace('/login?next=/account');
            });
        return () => {
            cancelled = true;
        };
    }, [adopt]);

    async function saveProfile(event) {
        event.preventDefault();
        setBusy('profile');
        const result = await apiFetch('/api/me', { method: 'PATCH', body: { displayName, bio } });
        setBusy('');
        if (result.ok) {
            adopt(result.data.user);
            setProfileNote({ ok: true, text: 'Profile saved.' });
        } else {
            setProfileNote({ ok: false, text: messageFor(result.data) });
        }
    }

    async function saveUsername(event) {
        event.preventDefault();
        setBusy('username');
        const result = await apiFetch('/api/me/username', { method: 'POST', body: { username } });
        setBusy('');
        if (result.ok) {
            adopt(result.data.user);
            setNameNote({ ok: true, text: 'Username updated.' });
        } else {
            setNameNote({ ok: false, text: messageFor(result.data) });
        }
    }

    async function requestEmail(event) {
        event.preventDefault();
        setBusy('email');
        const result = await apiFetch('/api/me/email', { method: 'POST', body: { email: newEmail } });
        setBusy('');
        if (result.ok) {
            setEmailStep('code');
            setEmailNote({ ok: true, text: 'We sent a code to the new address.' });
        } else {
            setEmailNote({ ok: false, text: messageFor(result.data) });
        }
    }

    async function confirmEmail(event) {
        event.preventDefault();
        setBusy('email');
        const result = await apiFetch('/api/me/email/confirm', { method: 'POST', body: { email: newEmail, code: emailCode } });
        setBusy('');
        if (result.ok) {
            adopt(result.data.user);
            setEmailStep('idle');
            setNewEmail('');
            setEmailCode('');
            setEmailNote({ ok: true, text: 'Email updated.' });
        } else {
            setEmailNote({ ok: false, text: messageFor(result.data) });
        }
    }

    async function logout() {
        setBusy('logout');
        await apiFetch('/api/auth/logout', { method: 'POST', body: {} });
        window.location.assign('/');
    }

    if (loading || !me) {
        return <main className="account-page"><p className="auth-lead">Loading your account...</p></main>;
    }

    const lockedUntil = me.canChangeUsernameAt ? new Date(me.canChangeUsernameAt) : null;

    return (
        <main className="account-page">
            <header className="account-head">
                <div className="avatar-circle" aria-hidden="true">{me.displayName.slice(0, 1).toUpperCase()}</div>
                <div>
                    <h1>{me.displayName}</h1>
                    <p className="account-handle">@{me.username}</p>
                    <div className="badge-row">
                        {me.badges.filter(b => BADGES[b]).map(b => (
                            <span className="badge-chip" key={b}><i className={'ph ' + BADGES[b].icon} /> {BADGES[b].label}</span>
                        ))}
                    </div>
                </div>
                <div className="account-actions">
                    <Link href={'/u/' + me.username} className="btn-ghost"><i className="ph ph-user" /> <span>Public profile</span></Link>
                    <Link href="/articles/new" className="btn-primary"><i className="ph ph-pen-nib" /> <span>Write an article</span></Link>
                </div>
            </header>
            <div className="account-grid">
                <form className="account-card" onSubmit={saveProfile}>
                    <h2>Profile</h2>
                    <label className="field"><span>Display name</span><input type="text" value={displayName} onChange={e => setDisplayName(e.target.value)} maxLength={40} required /></label>
                    <label className="field"><span>Bio</span><textarea value={bio} onChange={e => setBio(e.target.value)} maxLength={280} rows={4} /></label>
                    <p className="auth-hint">{bio.length}/280</p>
                    <Notice state={profileNote} />
                    <button className="btn-primary" type="submit" disabled={busy === 'profile'}>{busy === 'profile' ? 'Saving...' : 'Save profile'}</button>
                </form>
                <form className="account-card" onSubmit={saveUsername}>
                    <h2>Username</h2>
                    <label className="field"><span>Username</span><input type="text" value={username} onChange={e => setUsername(e.target.value.toLowerCase())} maxLength={20} autoCapitalize="none" spellCheck={false} disabled={Boolean(lockedUntil)} required /></label>
                    <p className="auth-hint">{lockedUntil ? 'You can change it again on ' + lockedUntil.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }) + '.' : 'You can change your username once every 30 days.'}</p>
                    <Notice state={nameNote} />
                    <button className="btn-primary" type="submit" disabled={busy === 'username' || Boolean(lockedUntil) || username === me.username}>{busy === 'username' ? 'Saving...' : 'Change username'}</button>
                </form>
                <div className="account-card">
                    <h2>Email</h2>
                    <p className="auth-lead">Current email: <b>{me.email}</b></p>
                    {emailStep === 'idle' ? (
                        <form onSubmit={requestEmail}>
                            <label className="field"><span>New email</span><input type="email" value={newEmail} onChange={e => setNewEmail(e.target.value)} maxLength={254} autoComplete="email" placeholder="new@gmail.com" required /></label>
                            <Notice state={emailNote} />
                            <button className="btn-primary" type="submit" disabled={busy === 'email'}>{busy === 'email' ? 'Sending...' : 'Send confirmation code'}</button>
                        </form>
                    ) : (
                        <form onSubmit={confirmEmail}>
                            <label className="field"><span>Code sent to {newEmail}</span><input className="code-input" type="text" value={emailCode} onChange={e => setEmailCode(e.target.value.replace(/\D/g, '').slice(0, 6))} inputMode="numeric" maxLength={6} placeholder="000000" required /></label>
                            <Notice state={emailNote} />
                            <div className="auth-links">
                                <button className="btn-primary" type="submit" disabled={busy === 'email' || emailCode.length !== 6}>Confirm email</button>
                                <button type="button" className="link-btn" onClick={() => { setEmailStep('idle'); setEmailNote(null); }}>Cancel</button>
                            </div>
                        </form>
                    )}
                </div>
                <div className="account-card">
                    <h2>Session</h2>
                    <p className="auth-lead">This device is signed in. Signing out ends the session on this browser.</p>
                    <button className="btn-ghost" type="button" onClick={logout} disabled={busy === 'logout'}><i className="ph ph-sign-out" /> <span>Sign out</span></button>
                </div>
            </div>
        </main>
    );
}
VERO_EOF_28
echo "yazildi: components/AccountPanel.js"

mkdir -p "components"
cat > "components/ArticleActions.js" <<'VERO_EOF_29'
'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { apiFetch, hasSessionMarker } from '@/lib/client/api';
import { messageFor } from '@/lib/client/messages';

export default function ArticleActions({ slug, authorUsername }) {
    const [mine, setMine] = useState(false);
    const [error, setError] = useState('');
    const [busy, setBusy] = useState(false);

    useEffect(() => {
        let cancelled = false;
        if (!hasSessionMarker()) return undefined;
        apiFetch('/api/me')
            .then(result => {
                if (cancelled || !result.ok || !result.data || !result.data.ok) return;
                setMine(result.data.user.username === authorUsername || result.data.user.isAdmin === true);
            })
            .catch(() => {});
        return () => {
            cancelled = true;
        };
    }, [authorUsername]);

    async function remove() {
        if (!window.confirm('Delete this article permanently?')) return;
        setBusy(true);
        const result = await apiFetch('/api/articles/' + slug, { method: 'DELETE' });
        if (result.ok) {
            window.location.assign('/articles');
            return;
        }
        setBusy(false);
        setError(messageFor(result.data));
    }

    if (!mine) return null;
    return (
        <div className="article-actions">
            <Link href={'/articles/' + slug + '/edit'} className="btn-ghost"><i className="ph ph-pencil-simple" /> <span>Edit</span></Link>
            <button type="button" className="btn-ghost danger" onClick={remove} disabled={busy}><i className="ph ph-trash" /> <span>Delete</span></button>
            {error ? <p className="auth-error" role="alert">{error}</p> : null}
        </div>
    );
}
VERO_EOF_29
echo "yazildi: components/ArticleActions.js"

mkdir -p "components"
cat > "components/ArticleCard.js" <<'VERO_EOF_30'
import Link from 'next/link';
import { CATEGORIES, formatDate } from '@/lib/format';
import { clip } from '@/lib/format';

export default function ArticleCard({ article }) {
    const cat = CATEGORIES[article.category] || CATEGORIES.intel;
    const author = article.author;
    return (
        <Link href={'/articles/' + article.slug} className="card" prefetch={false}>
            <div className="card-banner noimg">
                <div className="card-tag"><i className={'ph ' + cat.icon} /> {cat.label}</div>
                <i className={'ph ' + cat.icon + ' cover-fallback'} aria-hidden="true" />
            </div>
            <div className="card-content">
                <span className="card-date">{formatDate(article.createdAt)}</span>
                <h3 className="card-title" dir="auto">{article.title}</h3>
                <p className="card-desc" dir="auto">{clip(article.summary, 150)}</p>
                <div className="card-footer">
                    <div className="source-info">
                        <i className="ph ph-user" />
                        <span>{author ? author.displayName : 'VERO member'}</span>
                    </div>
                    <div className="read-more">Read <i className="ph ph-arrow-up-right" /></div>
                </div>
            </div>
        </Link>
    );
}
VERO_EOF_30
echo "yazildi: components/ArticleCard.js"

mkdir -p "components"
cat > "components/ArticleEditor.js" <<'VERO_EOF_31'
'use client';

import { useEffect, useState } from 'react';
import { apiFetch, hasSessionMarker } from '@/lib/client/api';
import { messageFor } from '@/lib/client/messages';
import { ARTICLE_CATEGORIES } from '@/lib/articles-core';
import { CATEGORIES } from '@/lib/format';

export default function ArticleEditor({ mode = 'new', slug = '', authorUsername = '', initial }) {
    const [title, setTitle] = useState(initial ? initial.title : '');
    const [category, setCategory] = useState(initial ? initial.category : 'opinion');
    const [summary, setSummary] = useState(initial ? initial.summary : '');
    const [body, setBody] = useState(initial ? initial.body : '');
    const [error, setError] = useState('');
    const [busy, setBusy] = useState(false);
    const [allowed, setAllowed] = useState(null);

    const nextPath = mode === 'edit' ? '/articles/' + slug + '/edit' : '/articles/new';

    useEffect(() => {
        let cancelled = false;
        if (!hasSessionMarker()) {
            window.location.replace('/login?next=' + encodeURIComponent(nextPath));
            return undefined;
        }
        apiFetch('/api/me')
            .then(result => {
                if (cancelled) return;
                if (!result.ok || !result.data || !result.data.ok) {
                    window.location.replace('/login?next=' + encodeURIComponent(nextPath));
                    return;
                }
                const user = result.data.user;
                if (!user.isAdult) setAllowed('adult');
                else if (mode === 'edit' && user.username !== authorUsername && !user.isAdmin) setAllowed('owner');
                else setAllowed('yes');
            })
            .catch(() => {
                if (!cancelled) window.location.replace('/login?next=' + encodeURIComponent(nextPath));
            });
        return () => {
            cancelled = true;
        };
    }, [mode, authorUsername, nextPath]);

    async function submit(event) {
        event.preventDefault();
        if (busy) return;
        setBusy(true);
        setError('');
        const payload = { title, category, summary, body };
        const result = mode === 'edit'
            ? await apiFetch('/api/articles/' + slug, { method: 'PATCH', body: payload })
            : await apiFetch('/api/articles', { method: 'POST', body: payload });
        if (result.ok && result.data && result.data.slug) {
            window.location.assign('/articles/' + result.data.slug);
            return;
        }
        setBusy(false);
        setError(messageFor(result.data));
    }

    if (allowed === null) return <main className="editor-page"><p className="auth-lead">Loading...</p></main>;
    if (allowed === 'adult') return <main className="editor-page"><p className="auth-error">Publishing is limited to users aged 18 or older.</p></main>;
    if (allowed === 'owner') return <main className="editor-page"><p className="auth-error">You can only edit your own articles.</p></main>;

    return (
        <main className="editor-page">
            <h1>{mode === 'edit' ? 'Edit article' : 'Write an article'}</h1>
            <p className="auth-lead">Articles are published immediately under your name. Keep them accurate and respectful.</p>
            <form className="editor-form" onSubmit={submit} noValidate>
                <label className="field"><span>Title</span><input type="text" value={title} onChange={e => setTitle(e.target.value)} maxLength={140} required /></label>
                <label className="field">
                    <span>Category</span>
                    <select value={category} onChange={e => setCategory(e.target.value)}>
                        {ARTICLE_CATEGORIES.map(key => <option key={key} value={key}>{CATEGORIES[key].label}</option>)}
                    </select>
                </label>
                <label className="field"><span>Summary</span><textarea value={summary} onChange={e => setSummary(e.target.value)} maxLength={300} rows={3} required /></label>
                <p className="auth-hint">{summary.length}/300</p>
                <label className="field"><span>Article</span><textarea className="editor-body" value={body} onChange={e => setBody(e.target.value)} maxLength={30000} rows={18} required /></label>
                <p className="auth-hint">{body.length}/30,000. Use a blank line between paragraphs, a line starting with ## for a heading and lines starting with - for a list. At most 3 links.</p>
                {error ? <p className="auth-error" role="alert">{error}</p> : null}
                <div className="auth-links">
                    <button className="btn-primary" type="submit" disabled={busy}>{busy ? 'Publishing...' : mode === 'edit' ? 'Save changes' : 'Publish'}</button>
                    <a className="link-btn" href={mode === 'edit' ? '/articles/' + slug : '/articles'}>Cancel</a>
                </div>
            </form>
        </main>
    );
}
VERO_EOF_31
echo "yazildi: components/ArticleEditor.js"

mkdir -p "components"
cat > "components/AutoRefresh.js" <<'VERO_EOF_32'
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function AutoRefresh({ seconds = 300 }) {
    const router = useRouter();

    useEffect(() => {
        const id = setInterval(() => {
            if (document.visibilityState === 'visible') router.refresh();
        }, seconds * 1000);
        return () => clearInterval(id);
    }, [router, seconds]);

    return null;
}
VERO_EOF_32
echo "yazildi: components/AutoRefresh.js"

mkdir -p "components"
cat > "components/Footer.js" <<'VERO_EOF_33'
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
                        <img src="/assets/logo-192.webp" width="44" height="44" alt="VERO" className="brand-logo" data-vl="1" />
                        <span>VERO</span>
                    </div>
                    <p>Independent global intelligence and diplomatic monitoring observatory.</p>
                </div>
                <div className="footer-col">
                    <h4>Explore</h4>
                    <Link href="/live"><i className="ph ph-broadcast" /> <span>Live</span></Link>
                    <Link href="/explore"><i className="ph ph-compass" /> <span>Explore</span></Link>
                    <Link href="/articles"><i className="ph ph-newspaper" /> <span>Articles</span></Link>
                    <Link href="/articles/new"><i className="ph ph-pen-nib" /> <span>Write for VERO</span></Link>
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
VERO_EOF_33
echo "yazildi: components/Footer.js"

mkdir -p "components"
cat > "components/LivePreview.js" <<'VERO_EOF_34'
'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { timeAgo } from '@/lib/format';

function Row({ row }) {
    const body = (
        <>
            <span className="pv-tag">{row.theater}</span>
            <span className="pv-title" dir="auto">{row.title}</span>
            <span className="pv-meta" suppressHydrationWarning>{row.source} &middot; {timeAgo(row.publishedAt)}</span>
        </>
    );
    if (row.external) {
        return <a className="pv-item" href={row.href} target="_blank" rel="noopener noreferrer">{body}</a>;
    }
    return <Link className="pv-item" href={row.href} prefetch={false}>{body}</Link>;
}

export default function LivePreview({ initial = [] }) {
    const [rows, setRows] = useState(initial);
    const [state, setState] = useState(initial.length ? 'ready' : 'loading');

    const load = useCallback(async () => {
        try {
            const response = await fetch('/api/live/preview', { cache: 'no-store' });
            if (!response.ok) throw new Error('bad status');
            const data = await response.json();
            if (Array.isArray(data.rows) && data.rows.length) {
                setRows(data.rows);
                setState('ready');
                return true;
            }
        } catch {
            setState(previous => (previous === 'ready' ? previous : 'empty'));
            return false;
        }
        setState(previous => (previous === 'ready' ? previous : 'empty'));
        return false;
    }, []);

    useEffect(() => {
        let cancelled = false;
        let timer = null;
        const tick = async () => {
            if (document.visibilityState === 'hidden') {
                timer = setTimeout(tick, 60000);
                return;
            }
            const ok = await load();
            if (!cancelled) timer = setTimeout(tick, ok ? 60000 : 15000);
        };
        timer = setTimeout(tick, initial.length ? 60000 : 0);
        return () => {
            cancelled = true;
            clearTimeout(timer);
        };
    }, [load, initial.length]);

    return (
        <ul className="pv-list" id="previewList">
            {state === 'ready'
                ? rows.map(row => <li key={row.id}><Row row={row} /></li>)
                : state === 'loading'
                    ? [0, 1, 2, 3].map(i => <li key={i} className="pv-skel" />)
                    : <li className="pv-empty">Connecting to the live feed. This list refreshes automatically.</li>}
        </ul>
    );
}
VERO_EOF_34
echo "yazildi: components/LivePreview.js"

mkdir -p "components"
cat > "components/LoginForm.js" <<'VERO_EOF_35'
'use client';

import { useEffect, useRef, useState } from 'react';
import { getDeviceKey, hasSessionMarker, publicPost } from '@/lib/client/api';
import { messageFor } from '@/lib/client/messages';

function safeNext(next) {
    return typeof next === 'string' && /^\/(?!\/)[\w\-./?=&%]{0,200}$/.test(next) ? next : '/account';
}

export default function LoginForm({ next }) {
    const [step, setStep] = useState('email');
    const [email, setEmail] = useState('');
    const [code, setCode] = useState('');
    const [username, setUsername] = useState('');
    const [birth, setBirth] = useState('');
    const [ticket, setTicket] = useState('');
    const [error, setError] = useState('');
    const [busy, setBusy] = useState(false);
    const [wait, setWait] = useState(0);
    const codeRef = useRef(null);

    useEffect(() => {
        if (hasSessionMarker()) window.location.replace(safeNext(next));
    }, [next]);

    useEffect(() => {
        if (wait <= 0) return undefined;
        const id = setTimeout(() => setWait(value => value - 1), 1000);
        return () => clearTimeout(id);
    }, [wait]);

    useEffect(() => {
        if (step === 'code' && codeRef.current) codeRef.current.focus();
    }, [step]);

    function go() {
        window.location.assign(safeNext(next));
    }

    async function sendCode(event) {
        if (event) event.preventDefault();
        if (busy) return;
        setBusy(true);
        setError('');
        const result = await publicPost('/api/auth/code', { email });
        setBusy(false);
        if (result.ok) {
            setStep('code');
            setCode('');
            setWait(60);
            return;
        }
        if (result.data && result.data.retryAfterSeconds) setWait(result.data.retryAfterSeconds);
        setError(messageFor(result.data));
    }

    async function verify(event) {
        event.preventDefault();
        if (busy) return;
        setBusy(true);
        setError('');
        try {
            const deviceJwk = await getDeviceKey().publicJwk();
            const result = await publicPost('/api/auth/verify', { email, code: code.trim(), deviceJwk });
            if (result.ok && result.data.status === 'signed_in') return go();
            if (result.ok && result.data.status === 'profile_required') {
                setTicket(result.data.ticket);
                setStep('profile');
            } else {
                setError(messageFor(result.data));
            }
        } catch {
            setError(messageFor({ reason: 'device_key' }));
        }
        setBusy(false);
    }

    async function complete(event) {
        event.preventDefault();
        if (busy) return;
        setBusy(true);
        setError('');
        try {
            const deviceJwk = await getDeviceKey().publicJwk();
            const result = await publicPost('/api/auth/complete', { ticket, username, birthDate: birth, deviceJwk });
            if (result.ok) return go();
            if (result.data && result.data.reason === 'ticket') setStep('email');
            setError(messageFor(result.data));
        } catch {
            setError(messageFor({ reason: 'device_key' }));
        }
        setBusy(false);
    }

    const today = new Date().toISOString().slice(0, 10);

    return (
        <div className="auth-page">
            <div className="auth-card">
                {step === 'email' ? (
                    <form onSubmit={sendCode} noValidate>
                        <h1>Sign in or create an account</h1>
                        <p className="auth-lead">Enter your email. We send a one-time code. No password needed.</p>
                        <label className="field">
                            <span>Email</span>
                            <input type="email" value={email} onChange={e => setEmail(e.target.value)} maxLength={254} autoComplete="email" inputMode="email" placeholder="you@gmail.com" required />
                        </label>
                        <p className="auth-hint">Supported: Gmail, Outlook, Proton, iCloud and Yahoo.</p>
                        {error ? <p className="auth-error" role="alert">{error}</p> : null}
                        <button className="btn-primary auth-submit" type="submit" disabled={busy || wait > 0}>{busy ? 'Sending...' : wait > 0 ? 'Wait ' + wait + 's' : 'Send code'}</button>
                    </form>
                ) : null}
                {step === 'code' ? (
                    <form onSubmit={verify} noValidate>
                        <h1>Enter your code</h1>
                        <p className="auth-lead">We sent a 6-digit code to <b>{email}</b>. It expires in 10 minutes.</p>
                        <label className="field">
                            <span>Code</span>
                            <input ref={codeRef} className="code-input" type="text" value={code} onChange={e => setCode(e.target.value.replace(/\D/g, '').slice(0, 6))} inputMode="numeric" autoComplete="one-time-code" maxLength={6} placeholder="000000" required />
                        </label>
                        {error ? <p className="auth-error" role="alert">{error}</p> : null}
                        <button className="btn-primary auth-submit" type="submit" disabled={busy || code.length !== 6}>{busy ? 'Checking...' : 'Continue'}</button>
                        <div className="auth-links">
                            <button type="button" className="link-btn" onClick={() => { setStep('email'); setError(''); }}>Change email</button>
                            <button type="button" className="link-btn" onClick={sendCode} disabled={busy || wait > 0}>{wait > 0 ? 'Resend in ' + wait + 's' : 'Resend code'}</button>
                        </div>
                    </form>
                ) : null}
                {step === 'profile' ? (
                    <form onSubmit={complete} noValidate>
                        <h1>Create your profile</h1>
                        <p className="auth-lead">Your email is verified. Choose a username to finish.</p>
                        <label className="field">
                            <span>Username</span>
                            <input type="text" value={username} onChange={e => setUsername(e.target.value.toLowerCase())} maxLength={20} autoComplete="username" autoCapitalize="none" spellCheck={false} placeholder="your_name" required />
                        </label>
                        <label className="field">
                            <span>Date of birth</span>
                            <input type="date" value={birth} onChange={e => setBirth(e.target.value)} max={today} min="1900-01-01" required />
                        </label>
                        <p className="auth-hint">By continuing you accept the <a href="/terms">Terms</a> and the <a href="/privacy">Privacy Policy</a>. You must be 13 or older. Your date of birth is never shown.</p>
                        {error ? <p className="auth-error" role="alert">{error}</p> : null}
                        <button className="btn-primary auth-submit" type="submit" disabled={busy || username.length < 3 || !birth}>{busy ? 'Creating...' : 'Create account'}</button>
                    </form>
                ) : null}
            </div>
        </div>
    );
}
VERO_EOF_35
echo "yazildi: components/LoginForm.js"

mkdir -p "components"
cat > "components/Nav.js" <<'VERO_EOF_36'
'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { apiFetch, hasSessionMarker } from '@/lib/client/api';

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
    const [signedIn, setSignedIn] = useState(false);

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

    useEffect(() => {
        let cancelled = false;
        if (!hasSessionMarker()) {
            setSignedIn(false);
            return undefined;
        }
        apiFetch('/api/me')
            .then(result => {
                if (!cancelled) setSignedIn(Boolean(result.ok && result.data && result.data.ok));
            })
            .catch(() => {
                if (!cancelled) setSignedIn(false);
            });
        return () => {
            cancelled = true;
        };
    }, [pathname]);

    function toggleTheme() {
        const current = document.documentElement.getAttribute('data-theme');
        applyTheme(current === 'dark' ? 'light' : 'dark', true);
    }

    return (
        <nav className={'nav-container' + (scrolled ? ' scrolled' : '')} id="navbar">
            <Link href="/" className="brand" aria-label="VERO">
                <img src="/assets/logo-96.webp" srcSet="/assets/logo-96.webp 1x, /assets/logo-192.webp 2x" width="36" height="36" alt="VERO" className="brand-logo" data-vl="1" />
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
                    <Link href={signedIn ? '/account' : '/login'} className={'icon-btn' + (signedIn ? ' signed' : '')} id="accountBtn" aria-label={signedIn ? 'Account' : 'Sign in'} onClick={() => setOpen(false)}>
                        <svg className="user-svg" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                            <circle cx="12" cy="8.2" r="3.7" />
                            <path d="M5 20c.9-4 3.6-6.2 7-6.2s6.1 2.2 7 6.2" />
                        </svg>
                    </Link>
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
VERO_EOF_36
echo "yazildi: components/Nav.js"

mkdir -p "components"
cat > "components/ReportCard.js" <<'VERO_EOF_37'
import Link from 'next/link';
import CoverImage from '@/components/CoverImage';
import { CATEGORIES, clip, formatDate, proxied, validCover } from '@/lib/format';
import { reportSlug } from '@/lib/slug';

export default function ReportCard({ item, overview, eager = false, linkable = true }) {
    const cat = CATEGORIES[item.cat] || CATEGORIES.intel;
    const image = validCover(item.image) ? proxied(item.image) : null;
    const stored = !item.web && linkable;
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
VERO_EOF_37
echo "yazildi: components/ReportCard.js"

mkdir -p "components"
cat > "components/TheaterCard.js" <<'VERO_EOF_38'
import Link from 'next/link';
import { THEATERS } from '@/content/theaters';
import { timeAgo } from '@/lib/format';
import { reportSlug } from '@/lib/slug';

const TAGS = { breaking: 'Breaking news', new: 'New', latest: 'Latest' };

function liveStats(data) {
    const count = data ? data.count24h || 0 : 0;
    const sources = data ? data.sources24h || 0 : 0;
    return [
        { label: 'Reports (24h)', value: String(count), tone: count >= 30 ? 'alert' : count >= 10 ? 'warning' : '' },
        { label: 'Sources (24h)', value: String(sources), tone: '' }
    ];
}

function LiveBox({ data, overview, linkable }) {
    if (!data || !data.lead) return null;
    const lead = data.lead;
    const title = overview ? overview.title : lead.title;
    const inner = (
        <>
            <div className="live-head">
                <span className={'live-tag ' + data.tag}>{TAGS[data.tag] || 'Latest'}</span>
                <span className="live-time">{timeAgo(lead.publishedAt)}</span>
            </div>
            <span className="live-title" dir="auto">{title}</span>
            <div className="live-foot">
                <span>{lead.source || ''}</span>
                <span className="go">{linkable ? 'Read overview' : 'Read source'} <i className="ph ph-arrow-up-right" /></span>
            </div>
        </>
    );
    if (!linkable) {
        return <a className="theater-live" href={lead.url} target="_blank" rel="noopener noreferrer">{inner}</a>;
    }
    return (
        <Link className="theater-live" href={'/report/' + reportSlug(lead.title, lead.url)} prefetch={false}>
            {inner}
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

export function TheaterCard({ id, data, overview, linkable = true }) {
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
                    {liveStats(data).map(stat => (
                        <div className="stat-box" key={stat.label}>
                            <span className="stat-label">{stat.label}</span>
                            <span className={'stat-val' + (stat.tone ? ' ' + stat.tone : '')}>{stat.value}</span>
                        </div>
                    ))}
                </div>
                <LiveBox data={data} overview={overview} linkable={linkable} />
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

export function DevelopingCard({ card, overview, linkable = true }) {
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
                <LiveBox data={data} overview={overview} linkable={linkable} />
                <div className="theater-actions">
                    <Link href={'/explore?q=' + encodeURIComponent(card.query || card.title)} className="btn-theater-action" prefetch={false}>
                        <i className="ph ph-arrows-clockwise" /> Explore reports
                    </Link>
                </div>
            </div>
        </article>
    );
}
VERO_EOF_38
echo "yazildi: components/TheaterCard.js"

mkdir -p "content"
cat > "content/badges.js" <<'VERO_EOF_39'
export const BADGES = {
    verified: { label: 'Verified', icon: 'ph-seal-check' },
    expert: { label: 'Expert', icon: 'ph-graduation-cap' },
    editor: { label: 'Editor', icon: 'ph-pencil-line' },
    email_verified: { label: 'Email verified', icon: 'ph-envelope-simple' }
};
VERO_EOF_39
echo "yazildi: content/badges.js"

mkdir -p "lib"
cat > "lib/articles-core.js" <<'VERO_EOF_40'
import { slugify } from './slugify.js';

export const ARTICLE_CATEGORIES = ['opinion', 'diplomacy', 'military', 'economy', 'energy', 'humanitarian', 'security', 'cyber'];
export const LIMITS = { title: [12, 140], summary: [40, 300], body: [400, 30000], links: 3 };
export const DAILY_LIMIT = 5;

function clean(value) {
    return typeof value === 'string' ? value.replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f\u200b-\u200f\u202a-\u202e\u2066-\u2069]/g, '') : '';
}

export function countLinks(text) {
    return (String(text || '').match(/https?:\/\/|www\./gi) || []).length;
}

function repetitive(text) {
    if (/(.)\1{14,}/.test(text)) return true;
    const words = text.toLowerCase().split(/\s+/).filter(Boolean);
    const seen = new Map();
    for (let i = 0; i + 3 <= words.length; i++) {
        const key = words[i] + ' ' + words[i + 1] + ' ' + words[i + 2];
        const n = (seen.get(key) || 0) + 1;
        if (n >= 12) return true;
        seen.set(key, n);
    }
    return false;
}

export function validateArticle(input) {
    const data = input && typeof input === 'object' ? input : {};
    const title = clean(data.title).replace(/\s+/g, ' ').trim();
    const summary = clean(data.summary).replace(/\s+/g, ' ').trim();
    const body = clean(data.body).replace(/\r\n?/g, '\n').replace(/[ \t]+/g, ' ').replace(/\n{3,}/g, '\n\n').trim();
    const category = typeof data.category === 'string' ? data.category : '';
    if (title.length < LIMITS.title[0] || title.length > LIMITS.title[1]) return { ok: false, reason: 'title' };
    if (summary.length < LIMITS.summary[0] || summary.length > LIMITS.summary[1]) return { ok: false, reason: 'summary' };
    if (body.length < LIMITS.body[0] || body.length > LIMITS.body[1]) return { ok: false, reason: 'body' };
    if (!ARTICLE_CATEGORIES.includes(category)) return { ok: false, reason: 'category' };
    if (countLinks(title) || countLinks(summary)) return { ok: false, reason: 'links' };
    if (countLinks(body) > LIMITS.links) return { ok: false, reason: 'links' };
    if (repetitive(title + ' ' + summary + ' ' + body)) return { ok: false, reason: 'spam' };
    return { ok: true, value: { title, summary, body, category } };
}

export function articleSlug(title, suffix) {
    return (slugify(title, 70) || 'article') + '-' + suffix;
}

export function isArticleSlug(value) {
    return typeof value === 'string' && value.length <= 90 && /^[a-z0-9]+(?:-[a-z0-9]+)*-[a-f0-9]{6}$/.test(value);
}

export function parseBody(text) {
    const blocks = [];
    String(text || '').split(/\n{2,}/).forEach(chunk => {
        const lines = chunk.split('\n').map(l => l.trim()).filter(Boolean);
        if (!lines.length) return;
        if (lines.length === 1 && /^##\s+/.test(lines[0])) {
            blocks.push({ type: 'h2', text: lines[0].replace(/^##\s+/, '').slice(0, 140) });
        } else if (lines.every(l => /^[-*]\s+/.test(l))) {
            blocks.push({ type: 'ul', items: lines.map(l => l.replace(/^[-*]\s+/, '')) });
        } else {
            blocks.push({ type: 'p', text: lines.join(' ') });
        }
    });
    return blocks;
}

export function readingMinutes(text) {
    const words = String(text || '').trim().split(/\s+/).filter(Boolean).length;
    return Math.max(1, Math.round(words / 220));
}
VERO_EOF_40
echo "yazildi: lib/articles-core.js"

mkdir -p "lib"
cat > "lib/articles.js" <<'VERO_EOF_41'
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
VERO_EOF_41
echo "yazildi: lib/articles.js"

mkdir -p "lib/auth"
cat > "lib/auth/http.js" <<'VERO_EOF_42'
export const MARKER_COOKIE = 'vero_in';

const STATUS = {
    domain_not_allowed: 422, email_format: 422, cooldown: 429, hourly_limit: 429, mail_failed: 502, invalid: 400, expired: 400,
    locked: 429, none: 400, device_key: 400, banned: 403, ticket: 400, username_format: 422, username_reserved: 422,
    username_taken: 409, birth_format: 422, too_young: 403, display_name: 422, bio: 422, same_email: 422, email_taken: 409,
    update_failed: 500, purpose: 400, title: 422, summary: 422, body: 422, category: 422, links: 422, spam: 422, daily_limit: 429,
    duplicate: 409, adult_only: 403, not_found: 404, forbidden: 403, unavailable: 503
};

export function json(data, status = 200, cookies = [], extra = {}) {
    const headers = new Headers({ 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store', ...extra });
    cookies.forEach(cookie => headers.append('Set-Cookie', cookie));
    return new Response(JSON.stringify(data), { status, headers });
}

export function failure(result) {
    const body = { ok: false, reason: result.reason };
    if (result.attemptsLeft !== undefined) body.attemptsLeft = result.attemptsLeft;
    if (result.retryAt) body.retryAt = result.retryAt;
    if (result.retryAfterMs) body.retryAfterSeconds = Math.ceil(result.retryAfterMs / 1000);
    const extra = result.retryAfterMs ? { 'Retry-After': String(Math.ceil(result.retryAfterMs / 1000)) } : {};
    return json(body, STATUS[result.reason] || 400, [], extra);
}

export async function readJson(request, max = 8192) {
    const declared = parseInt(request.headers.get('content-length') || '0', 10);
    if (declared > max) return null;
    let text;
    try {
        text = await request.text();
    } catch {
        return null;
    }
    if (text.length > max) return null;
    try {
        const value = JSON.parse(text);
        return value && typeof value === 'object' && !Array.isArray(value) ? value : null;
    } catch {
        return null;
    }
}

export function sameOrigin(request) {
    const origin = request.headers.get('origin');
    if (!origin) return false;
    const host = request.headers.get('x-forwarded-host') || request.headers.get('host');
    try {
        return new URL(origin).host === host;
    } catch {
        return false;
    }
}

export function readCookie(request, name) {
    const header = request.headers.get('cookie') || '';
    for (const part of header.split(';')) {
        const index = part.indexOf('=');
        if (index === -1) continue;
        if (part.slice(0, index).trim() === name) return part.slice(index + 1).trim();
    }
    return '';
}

export function markerCookie(on, maxAgeSeconds = 2592000) {
    return MARKER_COOKIE + '=' + (on ? '1' : '') + '; Path=/; Secure; SameSite=Lax; Max-Age=' + (on ? maxAgeSeconds : 0);
}
VERO_EOF_42
echo "yazildi: lib/auth/http.js"

mkdir -p "lib/auth"
cat > "lib/auth/instance.js" <<'VERO_EOF_43'
import connect from '@/lib/db';
import { checkEmail } from '@/lib/email-policy.mjs';
import { SESSION_COOKIE, clearedSessionCookie } from '@/lib/device-session.mjs';
import { createMailer } from '@/lib/mail';
import { clientIp, createLimiter } from '@/lib/rate-limit';
import { createAuthService, selfUser } from '@/lib/auth/service';
import { createMongoStore } from '@/lib/auth/store-mongo';
import { failure, json, markerCookie, readCookie, sameOrigin } from '@/lib/auth/http';

const KEY = Symbol.for('vero.auth');
const HOUR = 60 * 60 * 1000;

export const limits = {
    code: createLimiter({ limit: 8, windowMs: HOUR }),
    verify: createLimiter({ limit: 40, windowMs: 10 * 60 * 1000 }),
    complete: createLimiter({ limit: 10, windowMs: HOUR }),
    mutate: createLimiter({ limit: 60, windowMs: 10 * 60 * 1000 }),
    emailChange: createLimiter({ limit: 6, windowMs: HOUR })
};

export function getAuth() {
    if (!globalThis[KEY]) {
        const secret = process.env.AUTH_SECRET || '';
        if (secret.length < 32) return null;
        globalThis[KEY] = createAuthService({ store: createMongoStore(), mailer: createMailer(), secret });
    }
    return globalThis[KEY];
}

export function adminSet() {
    const set = new Set();
    String(process.env.ADMIN_EMAILS || '').split(',').forEach(raw => {
        const checked = checkEmail(raw);
        if (checked.ok) set.add(checked.canonical);
    });
    return set;
}

export function shapeSelf(user) {
    return selfUser(user, { admins: adminSet() });
}

export function sessionCookies(token) {
    return [sessionCookieValue(token), markerCookie(true)];
}

function sessionCookieValue(token) {
    return SESSION_COOKIE + '=' + token + '; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=2592000';
}

export function clearCookies() {
    return [clearedSessionCookie(), markerCookie(false)];
}

export async function guard(request, limiter) {
    if (!sameOrigin(request)) return json({ ok: false, reason: 'forbidden' }, 403);
    if (limiter) {
        const verdict = limiter.check(clientIp(request.headers));
        if (!verdict.ok) return json({ ok: false, reason: 'rate_limited', retryAfterSeconds: verdict.retryAfter }, 429, [], { 'Retry-After': String(verdict.retryAfter) });
    }
    if (!getAuth() || !(await connect())) return json({ ok: false, reason: 'unavailable' }, 503);
    return null;
}

export async function requireUser(request) {
    const auth = getAuth();
    if (!auth || !(await connect())) return { response: json({ ok: false, reason: 'unavailable' }, 503) };
    const url = new URL(request.url);
    const result = await auth.authenticate({
        token: readCookie(request, SESSION_COOKIE),
        method: request.method,
        path: url.pathname + url.search,
        proof: request.headers.get('x-vero-proof') || ''
    });
    if (!result.ok) return { response: json({ ok: false, reason: 'unauthorized' }, 401, clearCookies()) };
    return { auth, user: result.user, session: result.session };
}

export { failure, json };
VERO_EOF_43
echo "yazildi: lib/auth/instance.js"

mkdir -p "lib/auth"
cat > "lib/auth/public.js" <<'VERO_EOF_44'
import connect from '@/lib/db';
import User from '@/models/User';

export async function getPublicProfile(username) {
    const name = String(username || '').toLowerCase();
    if (!/^[a-z0-9_]{3,20}$/.test(name) || !(await connect())) return null;
    const doc = await User.findOne({ username: name, banned: { $ne: true } }).select('username displayName bio badges createdAt').lean().catch(() => null);
    if (!doc) return null;
    return { id: String(doc._id), username: doc.username, displayName: doc.displayName, bio: doc.bio || '', badges: doc.badges || [], createdAt: doc.createdAt };
}

export async function authorsById(ids) {
    const list = [...new Set((ids || []).map(String))].filter(id => /^[a-f0-9]{24}$/.test(id)).slice(0, 60);
    if (!list.length || !(await connect())) return new Map();
    const docs = await User.find({ _id: { $in: list } }).select('username displayName badges').lean().catch(() => []);
    return new Map(docs.map(d => [String(d._id), { username: d.username, displayName: d.displayName, badges: d.badges || [] }]));
}
VERO_EOF_44
echo "yazildi: lib/auth/public.js"

mkdir -p "lib/auth"
cat > "lib/auth/service.js" <<'VERO_EOF_45'
import { checkEmail } from '../email-policy.mjs';
import { createOtpService } from '../otp.mjs';
import { createProofVerifier, createSession, hashToken, normalizeDeviceKey, sessionState } from '../device-session.mjs';
import { ADULT_AGE, USERNAME_COOLDOWN_MS, ageOn, cleanBio, cleanDisplayName, validateBirthDate, validateUsername } from './validators.js';
import { signTicket, verifyTicket } from './ticket.js';

const TOUCH_INTERVAL_MS = 5 * 60 * 1000;

export function publicUser(user) {
    return {
        username: user.username,
        displayName: user.displayName,
        bio: user.bio || '',
        badges: Array.isArray(user.badges) ? user.badges : [],
        createdAt: new Date(user.createdAt).toISOString()
    };
}

export function selfUser(user, { admins = new Set(), now = Date.now() } = {}) {
    const changedAt = user.usernameChangedAt ? new Date(user.usernameChangedAt).getTime() : 0;
    const next = changedAt ? changedAt + USERNAME_COOLDOWN_MS : 0;
    return {
        ...publicUser(user),
        email: user.emailDisplay,
        isAdmin: admins.has(user.email),
        isAdult: user.birthDate ? ageOn(new Date(user.birthDate), now) >= ADULT_AGE : false,
        canChangeUsernameAt: next > now ? new Date(next).toISOString() : null
    };
}

export function createAuthService({ store, mailer, secret, now = () => Date.now(), verifyProof }) {
    if (typeof secret !== 'string' || secret.length < 32) throw new Error('auth secret must be at least 32 characters');
    const otp = createOtpService({ secret, now });
    const proofCheck = verifyProof || createProofVerifier({ now });

    async function startSession(user, deviceJwk) {
        const created = createSession({ userId: user.id, deviceJwk, now: now() });
        if (!created) return null;
        await store.createSession(created.record);
        return created.token;
    }

    async function sendCode(address, canonical, purpose) {
        const key = purpose + ':' + canonical;
        const previous = await store.getCode(key);
        const issued = otp.issue(previous, canonical, purpose);
        if (!issued.ok) return { ok: false, reason: issued.reason, retryAfterMs: issued.retryAfterMs };
        await store.setCode(key, issued.record);
        const sent = await mailer.sendCode(address, issued.code, purpose);
        if (!sent.ok) {
            await store.setCode(key, previous);
            return { ok: false, reason: 'mail_failed' };
        }
        return { ok: true };
    }

    async function checkCode(canonical, purpose, code) {
        const key = purpose + ':' + canonical;
        const record = await store.getCode(key);
        const result = otp.verify(record, canonical, purpose, code);
        if (result.record && result.record !== record) await store.setCode(key, result.record);
        return result;
    }

    async function requestCode({ email }) {
        const checked = checkEmail(email);
        if (!checked.ok) return { ok: false, reason: checked.reason === 'domain_not_allowed' ? 'domain_not_allowed' : 'email_format' };
        return sendCode(checked.address, checked.canonical, 'login');
    }

    async function verifyCode({ email, code, deviceJwk }) {
        const checked = checkEmail(email);
        if (!checked.ok) return { ok: false, reason: 'email_format' };
        if (!normalizeDeviceKey(deviceJwk)) return { ok: false, reason: 'device_key' };
        const result = await checkCode(checked.canonical, 'login', code);
        if (!result.ok) return { ok: false, reason: result.reason, attemptsLeft: result.attemptsLeft };
        const user = await store.findUserByEmail(checked.canonical);
        if (!user) return { ok: true, status: 'profile_required', ticket: signTicket(secret, checked, now()) };
        if (user.banned) return { ok: false, reason: 'banned' };
        const token = await startSession(user, deviceJwk);
        if (!token) return { ok: false, reason: 'device_key' };
        return { ok: true, status: 'signed_in', token, user };
    }

    async function completeSignup({ ticket, username, birthDate, deviceJwk }) {
        const data = verifyTicket(secret, ticket, now());
        if (!data) return { ok: false, reason: 'ticket' };
        if (!normalizeDeviceKey(deviceJwk)) return { ok: false, reason: 'device_key' };
        const name = validateUsername(username);
        if (!name.ok) return { ok: false, reason: name.reason };
        const birth = validateBirthDate(birthDate, now());
        if (!birth.ok) return { ok: false, reason: birth.reason };
        if (await store.findUserByEmail(data.canonical)) return { ok: false, reason: 'ticket' };
        const created = await store.createUser({
            email: data.canonical,
            emailDisplay: data.address,
            username: name.value,
            displayName: name.value,
            bio: '',
            birthDate: birth.value,
            badges: ['email_verified'],
            createdAt: new Date(now())
        });
        if (!created.ok) return { ok: false, reason: created.reason === 'duplicate_username' ? 'username_taken' : 'ticket' };
        const token = await startSession(created.user, deviceJwk);
        if (!token) return { ok: false, reason: 'device_key' };
        return { ok: true, status: 'signed_in', token, user: created.user };
    }

    async function authenticate({ token, method, path, proof }) {
        if (typeof token !== 'string' || token.length < 20 || token.length > 100) return { ok: false, reason: 'no_session' };
        const idHash = hashToken(token);
        const session = await store.findSession(idHash);
        const state = sessionState(session, now());
        if (state !== 'ok') {
            if (session) await store.deleteSession(idHash);
            return { ok: false, reason: 'no_session' };
        }
        const checked = proofCheck({ method, path, record: session, proof });
        if (!checked.ok) return { ok: false, reason: checked.reason };
        const user = await store.findUserById(session.userId);
        if (!user || user.banned) {
            await store.deleteSession(idHash);
            return { ok: false, reason: 'no_session' };
        }
        if (now() - session.lastSeenAt > TOUCH_INTERVAL_MS) await store.touchSession(idHash, now());
        return { ok: true, user, session };
    }

    async function logout({ session }) {
        if (session) await store.deleteSession(session.idHash);
        return { ok: true };
    }

    async function updateProfile({ user, displayName, bio }) {
        const patch = {};
        if (displayName !== undefined) {
            const name = cleanDisplayName(displayName);
            if (!name.ok) return { ok: false, reason: name.reason };
            patch.displayName = name.value;
        }
        if (bio !== undefined) {
            const text = cleanBio(bio);
            if (!text.ok) return { ok: false, reason: text.reason };
            patch.bio = text.value;
        }
        if (!Object.keys(patch).length) return { ok: true, user };
        const updated = await store.updateUser(user.id, patch);
        return updated.ok ? { ok: true, user: updated.user } : { ok: false, reason: 'update_failed' };
    }

    async function changeUsername({ user, username }) {
        const name = validateUsername(username);
        if (!name.ok) return { ok: false, reason: name.reason };
        if (name.value === user.username) return { ok: true, user };
        const last = user.usernameChangedAt ? new Date(user.usernameChangedAt).getTime() : 0;
        if (last && now() - last < USERNAME_COOLDOWN_MS) {
            return { ok: false, reason: 'cooldown', retryAt: new Date(last + USERNAME_COOLDOWN_MS).toISOString() };
        }
        const updated = await store.updateUser(user.id, { username: name.value, usernameChangedAt: new Date(now()) });
        if (!updated.ok) return { ok: false, reason: updated.reason === 'duplicate_username' ? 'username_taken' : 'update_failed' };
        return { ok: true, user: updated.user };
    }

    async function requestEmailChange({ user, newEmail }) {
        const checked = checkEmail(newEmail);
        if (!checked.ok) return { ok: false, reason: checked.reason === 'domain_not_allowed' ? 'domain_not_allowed' : 'email_format' };
        if (checked.canonical === user.email) return { ok: false, reason: 'same_email' };
        if (await store.findUserByEmail(checked.canonical)) return { ok: false, reason: 'email_taken' };
        return sendCode(checked.address, checked.canonical, 'email_change');
    }

    async function confirmEmailChange({ user, newEmail, code }) {
        const checked = checkEmail(newEmail);
        if (!checked.ok) return { ok: false, reason: 'email_format' };
        const result = await checkCode(checked.canonical, 'email_change', code);
        if (!result.ok) return { ok: false, reason: result.reason, attemptsLeft: result.attemptsLeft };
        const taken = await store.findUserByEmail(checked.canonical);
        if (taken && taken.id !== user.id) return { ok: false, reason: 'email_taken' };
        const updated = await store.updateUser(user.id, { email: checked.canonical, emailDisplay: checked.address });
        if (!updated.ok) return { ok: false, reason: updated.reason === 'duplicate_email' ? 'email_taken' : 'update_failed' };
        return { ok: true, user: updated.user };
    }

    return { requestCode, verifyCode, completeSignup, authenticate, logout, updateProfile, changeUsername, requestEmailChange, confirmEmailChange };
}
VERO_EOF_45
echo "yazildi: lib/auth/service.js"

mkdir -p "lib/auth"
cat > "lib/auth/store-mongo.js" <<'VERO_EOF_46'
import connect from '@/lib/db';
import User from '@/models/User';
import Session from '@/models/Session';
import AuthCode from '@/models/AuthCode';

function toUser(doc) {
    if (!doc) return null;
    return {
        id: String(doc._id),
        email: doc.email,
        emailDisplay: doc.emailDisplay,
        username: doc.username,
        displayName: doc.displayName,
        bio: doc.bio || '',
        birthDate: doc.birthDate,
        badges: doc.badges || [],
        banned: Boolean(doc.banned),
        createdAt: doc.createdAt,
        usernameChangedAt: doc.usernameChangedAt || null
    };
}

function duplicateReason(error) {
    if (!error || error.code !== 11000) return null;
    const keys = Object.keys(error.keyPattern || error.keyValue || {});
    return keys.includes('username') ? 'duplicate_username' : 'duplicate_email';
}

async function ready() {
    if (!(await connect())) throw new Error('database unavailable');
}

export function createMongoStore() {
    return {
        async findUserByEmail(email) {
            await ready();
            return toUser(await User.findOne({ email: String(email) }).lean());
        },
        async findUserByUsername(username) {
            await ready();
            return toUser(await User.findOne({ username: String(username) }).lean());
        },
        async findUserById(id) {
            await ready();
            if (!/^[a-f0-9]{24}$/.test(String(id))) return null;
            return toUser(await User.findById(String(id)).lean());
        },
        async createUser(data) {
            await ready();
            try {
                const doc = await User.create(data);
                return { ok: true, user: toUser(doc.toObject()) };
            } catch (error) {
                const reason = duplicateReason(error);
                if (reason) return { ok: false, reason };
                throw error;
            }
        },
        async updateUser(id, patch) {
            await ready();
            try {
                const doc = await User.findByIdAndUpdate(String(id), { $set: patch }, { new: true, runValidators: true }).lean();
                return doc ? { ok: true, user: toUser(doc) } : { ok: false, reason: 'missing' };
            } catch (error) {
                const reason = duplicateReason(error);
                if (reason) return { ok: false, reason };
                throw error;
            }
        },
        async getCode(key) {
            await ready();
            const doc = await AuthCode.findOne({ key: String(key) }).lean();
            if (!doc) return null;
            return { purpose: doc.purpose, codeHash: doc.codeHash || null, expiresAt: doc.expiresAt, attempts: doc.attempts, sentAt: doc.sentAt, sendTimes: doc.sendTimes || [] };
        },
        async setCode(key, record) {
            await ready();
            if (!record) {
                await AuthCode.deleteOne({ key: String(key) });
                return;
            }
            await AuthCode.updateOne({ key: String(key) }, { $set: { ...record, updatedAt: new Date() } }, { upsert: true });
        },
        async createSession(record) {
            await ready();
            await Session.create({ ...record, expireAt: new Date(record.expiresAt) });
        },
        async findSession(idHash) {
            await ready();
            const doc = await Session.findOne({ idHash: String(idHash) }).lean();
            if (!doc) return null;
            return {
                idHash: doc.idHash,
                userId: doc.userId,
                device: { jwk: { kty: doc.device.jwk.kty, crv: doc.device.jwk.crv, x: doc.device.jwk.x, y: doc.device.jwk.y }, thumbprint: doc.device.thumbprint },
                createdAt: doc.createdAt,
                lastSeenAt: doc.lastSeenAt,
                expiresAt: doc.expiresAt
            };
        },
        async touchSession(idHash, time) {
            await ready();
            await Session.updateOne({ idHash: String(idHash) }, { $set: { lastSeenAt: time } });
        },
        async deleteSession(idHash) {
            await ready();
            await Session.deleteOne({ idHash: String(idHash) });
        }
    };
}
VERO_EOF_46
echo "yazildi: lib/auth/store-mongo.js"

mkdir -p "lib/auth"
cat > "lib/auth/ticket.js" <<'VERO_EOF_47'
import crypto from 'node:crypto';

export const TICKET_TTL_MS = 15 * 60 * 1000;

function mac(secret, payload) {
    return crypto.createHmac('sha256', secret).update('vero-signup|' + payload).digest('base64url');
}

export function signTicket(secret, { canonical, address }, now = Date.now()) {
    const payload = Buffer.from(JSON.stringify({ c: canonical, a: address, x: now + TICKET_TTL_MS })).toString('base64url');
    return payload + '.' + mac(secret, payload);
}

export function verifyTicket(secret, ticket, now = Date.now()) {
    if (typeof ticket !== 'string' || ticket.length > 600) return null;
    const parts = ticket.split('.');
    if (parts.length !== 2) return null;
    const expected = Buffer.from(mac(secret, parts[0]));
    const actual = Buffer.from(parts[1]);
    if (expected.length !== actual.length || !crypto.timingSafeEqual(expected, actual)) return null;
    let data;
    try {
        data = JSON.parse(Buffer.from(parts[0], 'base64url').toString('utf8'));
    } catch {
        return null;
    }
    if (!data || typeof data.c !== 'string' || typeof data.a !== 'string' || typeof data.x !== 'number' || now > data.x) return null;
    return { canonical: data.c, address: data.a };
}
VERO_EOF_47
echo "yazildi: lib/auth/ticket.js"

mkdir -p "lib/auth"
cat > "lib/auth/validators.js" <<'VERO_EOF_48'
const RESERVED = new Set([
    'admin', 'administrator', 'root', 'system', 'support', 'help', 'security', 'staff', 'team', 'moderator', 'mod',
    'vero', 'verointels', 'veropol', 'official', 'editor', 'news', 'api', 'login', 'logout', 'signup', 'register',
    'account', 'settings', 'live', 'explore', 'articles', 'article', 'report', 'privacy', 'terms', 'methodology',
    'null', 'undefined', 'anonymous', 'everyone', 'here', 'me', 'u'
]);

export const USERNAME_COOLDOWN_MS = 30 * 24 * 60 * 60 * 1000;
export const MIN_AGE = 13;
export const ADULT_AGE = 18;

export function validateUsername(input) {
    const value = typeof input === 'string' ? input.trim().toLowerCase() : '';
    if (!/^[a-z0-9_]{3,20}$/.test(value)) return { ok: false, reason: 'username_format' };
    if (!/[a-z]/.test(value)) return { ok: false, reason: 'username_format' };
    if (RESERVED.has(value)) return { ok: false, reason: 'username_reserved' };
    return { ok: true, value };
}

export function ageOn(birth, now) {
    const today = new Date(now);
    let age = today.getUTCFullYear() - birth.getUTCFullYear();
    const before = today.getUTCMonth() < birth.getUTCMonth() || (today.getUTCMonth() === birth.getUTCMonth() && today.getUTCDate() < birth.getUTCDate());
    if (before) age -= 1;
    return age;
}

export function validateBirthDate(input, now = Date.now()) {
    if (typeof input !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(input)) return { ok: false, reason: 'birth_format' };
    const birth = new Date(input + 'T00:00:00Z');
    if (Number.isNaN(birth.getTime()) || birth.toISOString().slice(0, 10) !== input) return { ok: false, reason: 'birth_format' };
    const age = ageOn(birth, now);
    if (age < 0 || age > 120) return { ok: false, reason: 'birth_format' };
    if (age < MIN_AGE) return { ok: false, reason: 'too_young' };
    return { ok: true, value: birth, age };
}

export function cleanDisplayName(input) {
    const value = typeof input === 'string' ? input.replace(/[\u0000-\u001f\u007f\u200b-\u200f\u202a-\u202e\u2066-\u2069]/g, ' ').replace(/\s+/g, ' ').trim() : '';
    if (value.length < 1 || value.length > 40) return { ok: false, reason: 'display_name' };
    return { ok: true, value };
}

export function cleanBio(input) {
    if (input === undefined || input === null || input === '') return { ok: true, value: '' };
    if (typeof input !== 'string') return { ok: false, reason: 'bio' };
    const value = input
        .replace(/[\u0000-\u0009\u000b-\u001f\u007f\u200b-\u200f\u202a-\u202e\u2066-\u2069]/g, '')
        .replace(/\r\n?/g, '\n')
        .replace(/[ \t]+/g, ' ')
        .replace(/\n{3,}/g, '\n\n')
        .trim();
    if (value.length > 280) return { ok: false, reason: 'bio' };
    return { ok: true, value };
}
VERO_EOF_48
echo "yazildi: lib/auth/validators.js"

mkdir -p "lib/client"
cat > "lib/client/api.js" <<'VERO_EOF_49'
import { createDeviceKey } from '@/lib/device-key-client.mjs';

let deviceKey = null;

export function getDeviceKey() {
    if (!deviceKey) deviceKey = createDeviceKey();
    return deviceKey;
}

async function parse(response) {
    let data = null;
    try {
        data = await response.json();
    } catch {
        data = null;
    }
    return { ok: response.ok, status: response.status, data };
}

export async function apiFetch(path, { method = 'GET', body } = {}) {
    const proof = await getDeviceKey().sign(method, path);
    const response = await fetch(path, {
        method,
        credentials: 'same-origin',
        cache: 'no-store',
        headers: { 'Content-Type': 'application/json', 'X-Vero-Proof': proof },
        body: body === undefined ? undefined : JSON.stringify(body)
    });
    return parse(response);
}

export async function publicPost(path, body) {
    const response = await fetch(path, {
        method: 'POST',
        credentials: 'same-origin',
        cache: 'no-store',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
    });
    return parse(response);
}

export function hasSessionMarker() {
    return typeof document !== 'undefined' && /(?:^|;\s*)vero_in=1(?:;|$)/.test(document.cookie);
}
VERO_EOF_49
echo "yazildi: lib/client/api.js"

mkdir -p "lib/client"
cat > "lib/client/messages.js" <<'VERO_EOF_50'
const TEXT = {
    domain_not_allowed: 'Use a Gmail, Outlook, Proton, iCloud or Yahoo address.',
    email_format: 'Enter a valid email address.',
    cooldown: 'Please wait a moment before trying again.',
    hourly_limit: 'Too many codes requested. Try again later.',
    mail_failed: 'We could not send the email. Try again shortly.',
    invalid: 'That code is not correct.',
    expired: 'That code has expired. Request a new one.',
    locked: 'Too many attempts. Request a new code.',
    none: 'Request a new code first.',
    device_key: 'This browser could not create a secure key. Update it and try again.',
    banned: 'This account is suspended.',
    ticket: 'Your sign-up session expired. Start again.',
    username_format: 'Use 3 to 20 letters, numbers or underscores, with at least one letter.',
    username_reserved: 'That username is not available.',
    username_taken: 'That username is taken.',
    birth_format: 'Enter a valid date of birth.',
    too_young: 'You must be at least 13 to use VERO.',
    display_name: 'Name must be 1 to 40 characters.',
    bio: 'Bio must be 280 characters or fewer.',
    same_email: 'That is already your email.',
    email_taken: 'That email belongs to another account.',
    rate_limited: 'Too many requests. Slow down and try again.',
    unavailable: 'The service is temporarily unavailable.',
    forbidden: 'Request blocked. Reload the page and try again.',
    unauthorized: 'Your session ended. Sign in again.',
    title: 'The title must be 12 to 140 characters.',
    summary: 'The summary must be 40 to 300 characters.',
    body: 'The article must be 400 to 30,000 characters.',
    category: 'Choose a category.',
    links: 'Remove links from the title and summary, and keep at most 3 in the text.',
    spam: 'The text looks repetitive. Please rewrite it.',
    daily_limit: 'You reached the limit of 5 articles in 24 hours.',
    duplicate: 'You already published an article with this title today.',
    adult_only: 'Publishing is limited to users aged 18 or older.',
    not_found: 'That article no longer exists.',
    bad_request: 'The request was not understood.'
};

export function messageFor(data) {
    if (!data || !data.reason) return 'Something went wrong. Try again.';
    if (data.reason === 'cooldown' && data.retryAt) return 'You can change your username again on ' + new Date(data.retryAt).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }) + '.';
    if (data.reason === 'invalid' && typeof data.attemptsLeft === 'number') return 'That code is not correct. ' + data.attemptsLeft + ' attempts left.';
    return TEXT[data.reason] || 'Something went wrong. Try again.';
}
VERO_EOF_50
echo "yazildi: lib/client/messages.js"

mkdir -p "lib"
cat > "lib/db.js" <<'VERO_EOF_51'
import mongoose from 'mongoose';

const KEY = Symbol.for('vero.mongo');
const FAIL_TTL_MS = 30000;

function state() {
    if (!globalThis[KEY]) globalThis[KEY] = { promise: null, failedAt: 0 };
    return globalThis[KEY];
}

export default async function connect() {
    const uri = process.env.MONGODB_URI;
    if (!uri) return false;
    const s = state();
    if (s.promise) return s.promise;
    if (s.failedAt && Date.now() - s.failedAt < FAIL_TTL_MS) return false;
    mongoose.set('strictQuery', true);
    s.promise = mongoose
        .connect(uri, { serverSelectionTimeoutMS: 6000, maxPoolSize: 5 })
        .then(() => true)
        .catch(() => {
            s.promise = null;
            s.failedAt = Date.now();
            return false;
        });
    return s.promise;
}

export async function dbReady() {
    return connect();
}
VERO_EOF_51
echo "yazildi: lib/db.js"

mkdir -p "lib"
cat > "lib/format.js" <<'VERO_EOF_52'
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
    opinion: { label: 'Opinion', icon: 'ph-chat-centered-text' },
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
VERO_EOF_52
echo "yazildi: lib/format.js"

mkdir -p "lib"
cat > "lib/mail.js" <<'VERO_EOF_53'
const SUBJECTS = {
    login: code => 'Your VERO code: ' + code,
    email_change: code => 'Confirm your new VERO email: ' + code
};

const INTROS = {
    login: 'Use this code to sign in to VERO.',
    email_change: 'Use this code to confirm this email address for your VERO account.'
};

function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, ch => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[ch]));
}

export function buildMessage(code, purpose) {
    const intro = INTROS[purpose] || INTROS.login;
    const subject = (SUBJECTS[purpose] || SUBJECTS.login)(code);
    const text = intro + '\n\n' + code + '\n\nThe code expires in 10 minutes. If you did not request it, ignore this email. VERO will never ask you for this code.';
    const html = '<div style="font-family:Arial,Helvetica,sans-serif;max-width:420px;margin:0 auto;padding:24px;color:#121214">'
        + '<p style="font-size:15px;margin:0 0 16px">' + escapeHtml(intro) + '</p>'
        + '<p style="font-size:34px;font-weight:700;letter-spacing:8px;margin:0 0 16px">' + escapeHtml(code) + '</p>'
        + '<p style="font-size:13px;color:#5E5A57;margin:0">The code expires in 10 minutes. If you did not request it, ignore this email. VERO will never ask you for this code.</p>'
        + '</div>';
    return { subject, text, html };
}

export function createMailer({ env = process.env, fetchImpl = fetch } = {}) {
    const from = String(env.MAIL_FROM || '').trim();
    const match = from.match(/^(?:(.*?)\s*)?<([^<>@\s]+@[^<>@\s]+)>$/) || from.match(/^()([^<>@\s]+@[^<>@\s]+)$/);
    const sender = match ? { name: (match[1] || 'VERO').replace(/^"|"$/g, '') || 'VERO', email: match[2] } : null;

    async function sendCode(to, code, purpose) {
        if (!sender) return { ok: false, reason: 'not_configured' };
        const message = buildMessage(code, purpose);
        try {
            let response;
            if (env.BREVO_API_KEY) {
                response = await fetchImpl('https://api.brevo.com/v3/smtp/email', {
                    method: 'POST',
                    headers: { 'api-key': env.BREVO_API_KEY, 'Content-Type': 'application/json', Accept: 'application/json' },
                    body: JSON.stringify({ sender, to: [{ email: to }], subject: message.subject, htmlContent: message.html, textContent: message.text }),
                    signal: AbortSignal.timeout(12000)
                });
            } else if (env.RESEND_API_KEY) {
                response = await fetchImpl('https://api.resend.com/emails', {
                    method: 'POST',
                    headers: { Authorization: 'Bearer ' + env.RESEND_API_KEY, 'Content-Type': 'application/json' },
                    body: JSON.stringify({ from: sender.name + ' <' + sender.email + '>', to: [to], subject: message.subject, html: message.html, text: message.text }),
                    signal: AbortSignal.timeout(12000)
                });
            } else {
                return { ok: false, reason: 'not_configured' };
            }
            return response.ok ? { ok: true } : { ok: false, reason: 'provider_' + response.status };
        } catch {
            return { ok: false, reason: 'request_failed' };
        }
    }

    return { sendCode };
}
VERO_EOF_53
echo "yazildi: lib/mail.js"

mkdir -p "lib"
cat > "lib/preview.js" <<'VERO_EOF_54'
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
VERO_EOF_54
echo "yazildi: lib/preview.js"

mkdir -p "lib"
cat > "lib/slug.js" <<'VERO_EOF_55'
import crypto from 'node:crypto';
import { slugify } from './slugify.js';

export { slugify };

export function urlHash(url) {
    return crypto.createHash('sha256').update(String(url)).digest('hex').slice(0, 10);
}

export function reportSlug(title, url) {
    return (slugify(title) || 'report') + '-' + urlHash(url);
}

export function isReportSlug(value) {
    return typeof value === 'string' && value.length <= 100 && /^[a-z0-9]+(?:-[a-z0-9]+)*-[a-f0-9]{10}$/.test(value);
}
VERO_EOF_55
echo "yazildi: lib/slug.js"

mkdir -p "lib"
cat > "lib/slugify.js" <<'VERO_EOF_56'
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
VERO_EOF_56
echo "yazildi: lib/slugify.js"

mkdir -p "models"
cat > "models/Article.js" <<'VERO_EOF_57'
import mongoose from 'mongoose';

const schema = new mongoose.Schema({
    slug: { type: String, required: true, unique: true, maxlength: 90 },
    title: { type: String, required: true, maxlength: 140 },
    summary: { type: String, required: true, maxlength: 300 },
    body: { type: String, required: true, maxlength: 30000 },
    category: { type: String, required: true, maxlength: 24 },
    authorId: { type: String, required: true, index: true, maxlength: 40 },
    status: { type: String, default: 'published', maxlength: 12 },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date }
});

schema.index({ createdAt: -1 });
schema.index({ category: 1, createdAt: -1 });

export default mongoose.models.Article || mongoose.model('Article', schema);
VERO_EOF_57
echo "yazildi: models/Article.js"

mkdir -p "models"
cat > "models/AuthCode.js" <<'VERO_EOF_58'
import mongoose from 'mongoose';

const schema = new mongoose.Schema({
    key: { type: String, required: true, unique: true, maxlength: 300 },
    purpose: { type: String, default: '', maxlength: 24 },
    codeHash: { type: String, default: null, maxlength: 128 },
    expiresAt: { type: Number, default: 0 },
    attempts: { type: Number, default: 0 },
    sentAt: { type: Number, default: 0 },
    sendTimes: { type: [Number], default: [] },
    updatedAt: { type: Date, default: Date.now, index: { expireAfterSeconds: 172800 } }
});

export default mongoose.models.AuthCode || mongoose.model('AuthCode', schema);
VERO_EOF_58
echo "yazildi: models/AuthCode.js"

mkdir -p "models"
cat > "models/Session.js" <<'VERO_EOF_59'
import mongoose from 'mongoose';

const schema = new mongoose.Schema({
    idHash: { type: String, required: true, unique: true, maxlength: 64 },
    userId: { type: String, required: true, index: true, maxlength: 40 },
    device: {
        jwk: { kty: String, crv: String, x: String, y: String },
        thumbprint: String
    },
    createdAt: { type: Number, required: true },
    lastSeenAt: { type: Number, required: true },
    expiresAt: { type: Number, required: true },
    expireAt: { type: Date, required: true, index: { expireAfterSeconds: 0 } }
});

export default mongoose.models.Session || mongoose.model('Session', schema);
VERO_EOF_59
echo "yazildi: models/Session.js"

mkdir -p "models"
cat > "models/User.js" <<'VERO_EOF_60'
import mongoose from 'mongoose';

const schema = new mongoose.Schema({
    email: { type: String, required: true, unique: true, maxlength: 254 },
    emailDisplay: { type: String, required: true, maxlength: 254 },
    username: { type: String, required: true, unique: true, maxlength: 20 },
    displayName: { type: String, required: true, maxlength: 40 },
    bio: { type: String, default: '', maxlength: 280 },
    birthDate: { type: Date, required: true },
    badges: { type: [String], default: [] },
    banned: { type: Boolean, default: false },
    createdAt: { type: Date, default: Date.now },
    usernameChangedAt: { type: Date }
});

export default mongoose.models.User || mongoose.model('User', schema);
VERO_EOF_60
echo "yazildi: models/User.js"

cat > "package.json" <<'VERO_EOF_61'
{
  "name": "vero",
  "version": "2.0.0",
  "private": true,
  "description": "Verifiable Events & Research Observatory",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "test": "node --test tests/auth-core.test.mjs tests/news-core.test.mjs tests/auth-service.test.mjs tests/articles-core.test.mjs"
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
VERO_EOF_61
echo "yazildi: package.json"

mkdir -p "tests"
cat > "tests/articles-core.test.mjs" <<'VERO_EOF_62'
import test from 'node:test';
import assert from 'node:assert/strict';
import { ARTICLE_CATEGORIES, articleSlug, countLinks, isArticleSlug, parseBody, readingMinutes, validateArticle } from '../lib/articles-core.js';

const body = ('This is a paragraph with enough words to make the body long enough for validation. ').repeat(8);
const ok = { title: 'Why the Black Sea matters for grain', summary: 'A short explanation of why shipping lanes in the Black Sea shape global grain prices and diplomacy.', body, category: 'economy' };

test('valid article is cleaned and accepted', () => {
    const r = validateArticle({ ...ok, title: '  Why   the Black Sea matters for grain \u0007' });
    assert.equal(r.ok, true);
    assert.equal(r.value.title, 'Why the Black Sea matters for grain');
});

test('articles are rejected for bad fields', () => {
    const cases = [
        [{ ...ok, title: 'Short' }, 'title'],
        [{ ...ok, summary: 'Too short.' }, 'summary'],
        [{ ...ok, body: 'tiny' }, 'body'],
        [{ ...ok, body: 'x '.repeat(20000) }, 'body'],
        [{ ...ok, category: 'sports' }, 'category'],
        [{ ...ok, title: 'Read more at https://spam.example now' }, 'links'],
        [{ ...ok, body: body + ' http://a.test http://b.test http://c.test http://d.test' }, 'links'],
        [{ ...ok, body: ('buy now buy now buy now buy now buy now buy now buy now buy now buy now ').repeat(8) }, 'spam'],
        [null, 'title']
    ];
    for (const [input, reason] of cases) {
        const r = validateArticle(input);
        assert.equal(r.ok, false);
        assert.equal(r.reason, reason);
    }
    assert.ok(ARTICLE_CATEGORIES.includes('opinion'));
});

test('slugs have a stable shape', () => {
    const slug = articleSlug('Why the Black Sea matters', 'a1b2c3');
    assert.equal(slug, 'why-the-black-sea-matters-a1b2c3');
    assert.equal(isArticleSlug(slug), true);
    assert.equal(articleSlug('\u0623\u062e\u0628\u0627\u0631', 'a1b2c3'), 'article-a1b2c3');
    for (const bad of ['', '../x', 'abc', 'x-ZZZZZZ', 'x-a1b2c', null]) assert.equal(isArticleSlug(bad), false);
});

test('body parser builds safe blocks', () => {
    const blocks = parseBody('## Heading here\n\nFirst line\nsecond line\n\n- one\n- two\n\n<script>alert(1)</script>');
    assert.deepEqual(blocks.map(b => b.type), ['h2', 'p', 'ul', 'p']);
    assert.equal(blocks[1].text, 'First line second line');
    assert.deepEqual(blocks[2].items, ['one', 'two']);
    assert.equal(blocks[3].text, '<script>alert(1)</script>');
    assert.equal(countLinks('see https://a.test and www.b.test'), 2);
    assert.equal(readingMinutes('word '.repeat(660)), 3);
});
VERO_EOF_62
echo "yazildi: tests/articles-core.test.mjs"

mkdir -p "tests"
cat > "tests/auth-service.test.mjs" <<'VERO_EOF_63'
import test from 'node:test';
import assert from 'node:assert/strict';
import { createAuthService, selfUser, publicUser } from '../lib/auth/service.js';
import { createDeviceKey } from '../lib/device-key-client.mjs';
import { createMailer, buildMessage } from '../lib/mail.js';
import { signTicket, verifyTicket } from '../lib/auth/ticket.js';
import { USERNAME_COOLDOWN_MS } from '../lib/auth/validators.js';

const SECRET = 's'.repeat(48);

function memoryStore() {
    const users = new Map();
    const sessions = new Map();
    const codes = new Map();
    let seq = 0;
    const dupe = (data, skipId) => {
        for (const u of users.values()) {
            if (u.id === skipId) continue;
            if (data.email && u.email === data.email) return 'duplicate_email';
            if (data.username && u.username === data.username) return 'duplicate_username';
        }
        return null;
    };
    return {
        users, sessions, codes,
        findUserByEmail: async e => [...users.values()].find(u => u.email === e) || null,
        findUserByUsername: async n => [...users.values()].find(u => u.username === n) || null,
        findUserById: async id => users.get(id) || null,
        createUser: async data => {
            const reason = dupe(data);
            if (reason) return { ok: false, reason };
            const user = { id: 'u' + ++seq, banned: false, ...data };
            users.set(user.id, user);
            return { ok: true, user };
        },
        updateUser: async (id, patch) => {
            const reason = dupe(patch, id);
            if (reason) return { ok: false, reason };
            const user = { ...users.get(id), ...patch };
            users.set(id, user);
            return { ok: true, user };
        },
        getCode: async k => codes.get(k) || null,
        setCode: async (k, r) => { if (r) codes.set(k, r); else codes.delete(k); },
        createSession: async r => { sessions.set(r.idHash, r); },
        findSession: async h => sessions.get(h) || null,
        touchSession: async (h, t) => { sessions.get(h).lastSeenAt = t; },
        deleteSession: async h => { sessions.delete(h); }
    };
}

function setup(options = {}) {
    const store = memoryStore();
    const sent = [];
    const mailer = { sendCode: async (to, code, purpose) => { if (options.failMail) return { ok: false }; sent.push({ to, code, purpose }); return { ok: true }; } };
    const clock = { t: Date.UTC(2026, 10, 21, 12, 0, 0) };
    const auth = createAuthService({ store, mailer, secret: SECRET, now: () => clock.t });
    return { store, sent, auth, clock };
}

function memKeyStore() {
    const m = new Map();
    return { get: async k => m.get(k) || null, set: async (k, v) => { m.set(k, v); }, remove: async k => { m.delete(k); } };
}

async function newDevice(clock) {
    return createDeviceKey({ store: memKeyStore(), now: () => clock.t });
}

async function signUp(env, email = 'Test.User+a@gmail.com', username = 'tester') {
    const device = await newDevice(env.clock);
    const jwk = await device.publicJwk();
    assert.equal((await env.auth.requestCode({ email })).ok, true);
    const code = env.sent.at(-1).code;
    const verified = await env.auth.verifyCode({ email, code, deviceJwk: jwk });
    assert.equal(verified.status, 'profile_required');
    const done = await env.auth.completeSignup({ ticket: verified.ticket, username, birthDate: '2000-05-05', deviceJwk: jwk });
    assert.equal(done.ok, true);
    return { device, jwk, token: done.token, user: done.user };
}

async function authed(env, session, method, path) {
    const proof = await session.device.sign(method, path);
    return env.auth.authenticate({ token: session.token, method, path, proof });
}

test('service refuses a weak secret', () => {
    assert.throws(() => createAuthService({ store: memoryStore(), mailer: {}, secret: 'short' }));
});

test('request code rejects unsupported domains and bad emails', async () => {
    const env = setup();
    assert.deepEqual(await env.auth.requestCode({ email: 'a@mailinator.com' }), { ok: false, reason: 'domain_not_allowed' });
    assert.deepEqual(await env.auth.requestCode({ email: 'nope' }), { ok: false, reason: 'email_format' });
    assert.equal(env.sent.length, 0);
});

test('request code applies cooldown and restores state when mail fails', async () => {
    const env = setup();
    assert.equal((await env.auth.requestCode({ email: 'a@gmail.com' })).ok, true);
    const again = await env.auth.requestCode({ email: 'a@gmail.com' });
    assert.equal(again.reason, 'cooldown');
    const failing = setup({ failMail: true });
    const r = await failing.auth.requestCode({ email: 'b@gmail.com' });
    assert.equal(r.reason, 'mail_failed');
    assert.equal(failing.store.codes.size, 0);
});

test('new users get a profile ticket, then an account and session', async () => {
    const env = setup();
    const session = await signUp(env);
    assert.equal(session.user.email, 'testuser@gmail.com');
    assert.equal(session.user.emailDisplay, 'test.user+a@gmail.com');
    assert.deepEqual(session.user.badges, ['email_verified']);
    const me = await authed(env, session, 'GET', '/api/me');
    assert.equal(me.ok, true);
    assert.equal(me.user.username, 'tester');
});

test('returning users sign in directly and aliases map to one account', async () => {
    const env = setup();
    await signUp(env);
    env.clock.t += 120000;
    const device = await newDevice(env.clock);
    await env.auth.requestCode({ email: 'testuser@gmail.com' });
    const code = env.sent.at(-1).code;
    const result = await env.auth.verifyCode({ email: 'T.e.s.t.u.s.e.r+other@gmail.com', code, deviceJwk: await device.publicJwk() });
    assert.equal(result.status, 'signed_in');
    assert.equal(env.store.users.size, 1);
});

test('wrong and reused codes fail, and lockout follows five misses', async () => {
    const env = setup();
    const device = await newDevice(env.clock);
    const jwk = await device.publicJwk();
    await env.auth.requestCode({ email: 'a@gmail.com' });
    const code = env.sent.at(-1).code;
    const wrong = code === '000000' ? '111111' : '000000';
    const miss = await env.auth.verifyCode({ email: 'a@gmail.com', code: wrong, deviceJwk: jwk });
    assert.deepEqual([miss.ok, miss.reason, miss.attemptsLeft], [false, 'invalid', 4]);
    for (let i = 0; i < 4; i++) await env.auth.verifyCode({ email: 'a@gmail.com', code: wrong, deviceJwk: jwk });
    assert.equal((await env.auth.verifyCode({ email: 'a@gmail.com', code, deviceJwk: jwk })).ok, false);
    const env2 = setup();
    await env2.auth.requestCode({ email: 'a@gmail.com' });
    const c2 = env2.sent.at(-1).code;
    assert.equal((await env2.auth.verifyCode({ email: 'a@gmail.com', code: c2, deviceJwk: jwk })).ok, true);
    assert.equal((await env2.auth.verifyCode({ email: 'a@gmail.com', code: c2, deviceJwk: jwk })).ok, false);
});

test('verify requires a valid device key before touching the code', async () => {
    const env = setup();
    await env.auth.requestCode({ email: 'a@gmail.com' });
    const code = env.sent.at(-1).code;
    assert.equal((await env.auth.verifyCode({ email: 'a@gmail.com', code, deviceJwk: { kty: 'EC' } })).reason, 'device_key');
    const device = await newDevice(env.clock);
    assert.equal((await env.auth.verifyCode({ email: 'a@gmail.com', code, deviceJwk: await device.publicJwk() })).ok, true);
});

test('signup validates ticket, username and age', async () => {
    const env = setup();
    const device = await newDevice(env.clock);
    const jwk = await device.publicJwk();
    await env.auth.requestCode({ email: 'a@gmail.com' });
    const verified = await env.auth.verifyCode({ email: 'a@gmail.com', code: env.sent.at(-1).code, deviceJwk: jwk });
    const base = { ticket: verified.ticket, username: 'valid_name', birthDate: '2000-01-01', deviceJwk: jwk };
    assert.equal((await env.auth.completeSignup({ ...base, ticket: 'x.y' })).reason, 'ticket');
    assert.equal((await env.auth.completeSignup({ ...base, ticket: verified.ticket.slice(0, -2) + 'aa' })).reason, 'ticket');
    assert.equal((await env.auth.completeSignup({ ...base, username: 'ab' })).reason, 'username_format');
    assert.equal((await env.auth.completeSignup({ ...base, username: 'admin' })).reason, 'username_reserved');
    assert.equal((await env.auth.completeSignup({ ...base, birthDate: '2020-01-01' })).reason, 'too_young');
    assert.equal((await env.auth.completeSignup({ ...base, birthDate: 'soon' })).reason, 'birth_format');
    assert.equal((await env.auth.completeSignup({ ...base, deviceJwk: {} })).reason, 'device_key');
    assert.equal((await env.auth.completeSignup(base)).ok, true);
    assert.equal((await env.auth.completeSignup(base)).reason, 'ticket');
});

test('usernames are unique and tickets expire', async () => {
    const env = setup();
    await signUp(env, 'a@gmail.com', 'taken_name');
    const device = await newDevice(env.clock);
    const jwk = await device.publicJwk();
    env.clock.t += 120000;
    await env.auth.requestCode({ email: 'b@gmail.com' });
    const verified = await env.auth.verifyCode({ email: 'b@gmail.com', code: env.sent.at(-1).code, deviceJwk: jwk });
    const clash = await env.auth.completeSignup({ ticket: verified.ticket, username: 'Taken_Name', birthDate: '2000-01-01', deviceJwk: jwk });
    assert.equal(clash.reason, 'username_taken');
    env.clock.t += 16 * 60 * 1000;
    const late = await env.auth.completeSignup({ ticket: verified.ticket, username: 'late_name', birthDate: '2000-01-01', deviceJwk: jwk });
    assert.equal(late.reason, 'ticket');
});

test('a stolen session token without the device key is useless', async () => {
    const env = setup();
    const session = await signUp(env);
    const attacker = await newDevice(env.clock);
    const proof = await attacker.sign('GET', '/api/me');
    const stolen = await env.auth.authenticate({ token: session.token, method: 'GET', path: '/api/me', proof });
    assert.deepEqual([stolen.ok, stolen.reason], [false, 'proof_invalid']);
    const noProof = await env.auth.authenticate({ token: session.token, method: 'GET', path: '/api/me', proof: undefined });
    assert.equal(noProof.reason, 'proof_missing');
    assert.equal((await env.auth.authenticate({ token: 'bogus', method: 'GET', path: '/api/me', proof })).reason, 'no_session');
});

test('sessions expire when idle and are removed on logout', async () => {
    const env = setup();
    const session = await signUp(env);
    const ok = await authed(env, session, 'GET', '/api/me');
    assert.equal(ok.ok, true);
    await env.auth.logout({ session: ok.session });
    assert.equal((await authed(env, session, 'GET', '/api/me')).reason, 'no_session');
    const env2 = setup();
    const s2 = await signUp(env2, 'z@gmail.com', 'zed_user');
    env2.clock.t += 8 * 24 * 60 * 60 * 1000;
    assert.equal((await authed(env2, s2, 'GET', '/api/me')).reason, 'no_session');
});

test('banned users cannot sign in or use sessions', async () => {
    const env = setup();
    const session = await signUp(env);
    env.store.users.set(session.user.id, { ...env.store.users.get(session.user.id), banned: true });
    assert.equal((await authed(env, session, 'GET', '/api/me')).reason, 'no_session');
    env.clock.t += 120000;
    const device = await newDevice(env.clock);
    await env.auth.requestCode({ email: 'testuser@gmail.com' });
    const r = await env.auth.verifyCode({ email: 'testuser@gmail.com', code: env.sent.at(-1).code, deviceJwk: await device.publicJwk() });
    assert.equal(r.reason, 'banned');
});

test('profile edits are cleaned and validated', async () => {
    const env = setup();
    const session = await signUp(env);
    const ok = await env.auth.updateProfile({ user: session.user, displayName: '  Le   Gateau \u0007 ', bio: 'Line one\r\n\r\n\r\n\r\nLine two' });
    assert.equal(ok.user.displayName, 'Le Gateau');
    assert.equal(ok.user.bio, 'Line one\n\nLine two');
    assert.equal((await env.auth.updateProfile({ user: session.user, displayName: '' })).reason, 'display_name');
    assert.equal((await env.auth.updateProfile({ user: session.user, bio: 'x'.repeat(281) })).reason, 'bio');
});

test('username changes enforce rules, uniqueness and a cooldown', async () => {
    const env = setup();
    const a = await signUp(env, 'a@gmail.com', 'first_user');
    env.clock.t += 120000;
    await signUp(env, 'b@gmail.com', 'second_user');
    const user = env.store.users.get(a.user.id);
    assert.equal((await env.auth.changeUsername({ user, username: 'second_user' })).reason, 'username_taken');
    assert.equal((await env.auth.changeUsername({ user, username: 'x' })).reason, 'username_format');
    const changed = await env.auth.changeUsername({ user, username: 'Renamed_One' });
    assert.equal(changed.user.username, 'renamed_one');
    const again = await env.auth.changeUsername({ user: changed.user, username: 'another_one' });
    assert.equal(again.reason, 'cooldown');
    assert.ok(again.retryAt);
    env.clock.t += USERNAME_COOLDOWN_MS + 1000;
    assert.equal((await env.auth.changeUsername({ user: changed.user, username: 'another_one' })).ok, true);
});

test('email change needs a code sent to the new address', async () => {
    const env = setup();
    const a = await signUp(env, 'a@gmail.com', 'first_user');
    env.clock.t += 120000;
    await signUp(env, 'b@gmail.com', 'second_user');
    const user = env.store.users.get(a.user.id);
    assert.equal((await env.auth.requestEmailChange({ user, newEmail: 'a@gmail.com' })).reason, 'same_email');
    assert.equal((await env.auth.requestEmailChange({ user, newEmail: 'b@gmail.com' })).reason, 'email_taken');
    assert.equal((await env.auth.requestEmailChange({ user, newEmail: 'x@example.org' })).reason, 'domain_not_allowed');
    env.clock.t += 120000;
    const req = await env.auth.requestEmailChange({ user, newEmail: 'New.Mail@outlook.com' });
    assert.equal(req.ok, true);
    const last = env.sent.at(-1);
    assert.deepEqual([last.to, last.purpose], ['new.mail@outlook.com', 'email_change']);
    const wrong = last.code === '000000' ? '111111' : '000000';
    assert.equal((await env.auth.confirmEmailChange({ user, newEmail: 'new.mail@outlook.com', code: wrong })).reason, 'invalid');
    const done = await env.auth.confirmEmailChange({ user, newEmail: 'new.mail@outlook.com', code: last.code });
    assert.equal(done.ok, true);
    assert.equal(done.user.email, 'new.mail@outlook.com');
});

test('a login code cannot confirm an email change', async () => {
    const env = setup();
    const a = await signUp(env, 'a@gmail.com', 'first_user');
    env.clock.t += 120000;
    await env.auth.requestCode({ email: 'c@gmail.com' });
    const loginCode = env.sent.at(-1).code;
    const result = await env.auth.confirmEmailChange({ user: env.store.users.get(a.user.id), newEmail: 'c@gmail.com', code: loginCode });
    assert.equal(result.ok, false);
});

test('user shapes hide private fields', () => {
    const user = { id: 'u1', email: 'a@gmail.com', emailDisplay: 'A@gmail.com', username: 'a_user', displayName: 'A', bio: '', badges: ['verified'], createdAt: new Date(0), birthDate: new Date('2000-01-01') };
    const pub = publicUser(user);
    assert.equal(pub.email, undefined);
    assert.equal(pub.birthDate, undefined);
    const me = selfUser(user, { admins: new Set(['a@gmail.com']), now: Date.UTC(2026, 10, 21) });
    assert.equal(me.isAdmin, true);
    assert.equal(me.isAdult, true);
    assert.equal(me.email, 'A@gmail.com');
});

test('ticket signing detects tampering and expiry', () => {
    const t = signTicket(SECRET, { canonical: 'a@gmail.com', address: 'a@gmail.com' }, 1000);
    assert.deepEqual(verifyTicket(SECRET, t, 2000), { canonical: 'a@gmail.com', address: 'a@gmail.com' });
    assert.equal(verifyTicket('other'.repeat(10), t, 2000), null);
    assert.equal(verifyTicket(SECRET, t, 1000 + 16 * 60 * 1000), null);
    assert.equal(verifyTicket(SECRET, 'a.b.c', 2000), null);
    assert.equal(verifyTicket(SECRET, undefined, 2000), null);
});

test('mailer picks Brevo or Resend and never throws', async () => {
    const calls = [];
    const ok = async (url, init) => { calls.push({ url, init }); return { ok: true, status: 200 }; };
    const brevo = createMailer({ env: { MAIL_FROM: 'VERO <veropol@proton.me>', BREVO_API_KEY: 'bk' }, fetchImpl: ok });
    assert.deepEqual(await brevo.sendCode('a@gmail.com', '123456', 'login'), { ok: true });
    assert.match(calls[0].url, /brevo/);
    assert.equal(JSON.parse(calls[0].init.body).sender.email, 'veropol@proton.me');
    const resend = createMailer({ env: { MAIL_FROM: 'veropol@proton.me', RESEND_API_KEY: 'rk' }, fetchImpl: ok });
    assert.equal((await resend.sendCode('a@gmail.com', '123456', 'login')).ok, true);
    assert.match(calls[1].url, /resend/);
    assert.equal((await createMailer({ env: {}, fetchImpl: ok }).sendCode('a@gmail.com', '1', 'login')).reason, 'not_configured');
    assert.equal((await createMailer({ env: { MAIL_FROM: 'bad' , RESEND_API_KEY: 'k' }, fetchImpl: ok }).sendCode('a@gmail.com', '1', 'login')).reason, 'not_configured');
    const failing = createMailer({ env: { MAIL_FROM: 'a@proton.me', RESEND_API_KEY: 'k' }, fetchImpl: async () => ({ ok: false, status: 403 }) });
    assert.equal((await failing.sendCode('a@gmail.com', '1', 'login')).reason, 'provider_403');
    const boom = createMailer({ env: { MAIL_FROM: 'a@proton.me', RESEND_API_KEY: 'k' }, fetchImpl: async () => { throw new Error('x'); } });
    assert.equal((await boom.sendCode('a@gmail.com', '1', 'login')).reason, 'request_failed');
    const msg = buildMessage('<b>1</b>', 'login');
    assert.ok(!msg.html.includes('<b>1</b>'));
});
VERO_EOF_63
echo "yazildi: tests/auth-service.test.mjs"

echo ""
echo "Tamam. Simdi: npm install  (sonra git add -A, commit, push)"
