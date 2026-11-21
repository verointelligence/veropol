import ArticleEditor from '@/components/ArticleEditor';

export const metadata = {
    title: 'Write an article',
    alternates: { canonical: '/articles/new' },
    robots: { index: false, follow: false }
};

export default function NewArticlePage() {
    return <ArticleEditor mode="new" />;
}
