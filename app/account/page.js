import AccountPanel from '@/components/AccountPanel';

export const metadata = {
    title: 'Account',
    alternates: { canonical: '/account' },
    robots: { index: false, follow: false }
};

export default function AccountPage() {
    return <AccountPanel />;
}
