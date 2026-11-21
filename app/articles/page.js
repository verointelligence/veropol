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
