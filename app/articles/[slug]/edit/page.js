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
