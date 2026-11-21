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
