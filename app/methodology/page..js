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
