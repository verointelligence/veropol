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
