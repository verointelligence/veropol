'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { apiFetch, hasSessionMarker } from '@/lib/client/api';
import { messageFor } from '@/lib/client/messages';

export default function ArticleActions({ slug, authorUsername }) {
    const [mine, setMine] = useState(false);
    const [error, setError] = useState('');
    const [busy, setBusy] = useState(false);

    useEffect(() => {
        let cancelled = false;
        if (!hasSessionMarker()) return undefined;
        apiFetch('/api/me')
            .then(result => {
                if (cancelled || !result.ok || !result.data || !result.data.ok) return;
                setMine(result.data.user.username === authorUsername || result.data.user.isAdmin === true);
            })
            .catch(() => {});
        return () => {
            cancelled = true;
        };
    }, [authorUsername]);

    async function remove() {
        if (!window.confirm('Delete this article permanently?')) return;
        setBusy(true);
        const result = await apiFetch('/api/articles/' + slug, { method: 'DELETE' });
        if (result.ok) {
            window.location.assign('/articles');
            return;
        }
        setBusy(false);
        setError(messageFor(result.data));
    }

    if (!mine) return null;
    return (
        <div className="article-actions">
            <Link href={'/articles/' + slug + '/edit'} className="btn-ghost"><i className="ph ph-pencil-simple" /> <span>Edit</span></Link>
            <button type="button" className="btn-ghost danger" onClick={remove} disabled={busy}><i className="ph ph-trash" /> <span>Delete</span></button>
            {error ? <p className="auth-error" role="alert">{error}</p> : null}
        </div>
    );
}
