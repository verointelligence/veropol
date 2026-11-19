'use client';

import { usePathname } from 'next/navigation';

export default function NotFoundPath() {
    const pathname = usePathname();
    return <span className="nf-path" dir="ltr">{String(pathname || '').slice(0, 120)}</span>;
}
