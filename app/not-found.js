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
