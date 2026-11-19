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
