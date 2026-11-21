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
