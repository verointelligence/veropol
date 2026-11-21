'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { timeAgo } from '@/lib/format';

function Row({ row }) {
    const body = (
        <>
            <span className="pv-tag">{row.theater}</span>
            <span className="pv-title" dir="auto">{row.title}</span>
            <span className="pv-meta" suppressHydrationWarning>{row.source} &middot; {timeAgo(row.publishedAt)}</span>
        </>
    );
    if (row.external) {
        return <a className="pv-item" href={row.href} target="_blank" rel="noopener noreferrer">{body}</a>;
    }
    return <Link className="pv-item" href={row.href} prefetch={false}>{body}</Link>;
}

export default function LivePreview({ initial = [] }) {
    const [rows, setRows] = useState(initial);
    const [state, setState] = useState(initial.length ? 'ready' : 'loading');

    const load = useCallback(async () => {
        try {
            const response = await fetch('/api/live/preview', { cache: 'no-store' });
            if (!response.ok) throw new Error('bad status');
            const data = await response.json();
            if (Array.isArray(data.rows) && data.rows.length) {
                setRows(data.rows);
                setState('ready');
                return true;
            }
        } catch {
            setState(previous => (previous === 'ready' ? previous : 'empty'));
            return false;
        }
        setState(previous => (previous === 'ready' ? previous : 'empty'));
        return false;
    }, []);

    useEffect(() => {
        let cancelled = false;
        let timer = null;
        const tick = async () => {
            if (document.visibilityState === 'hidden') {
                timer = setTimeout(tick, 60000);
                return;
            }
            const ok = await load();
            if (!cancelled) timer = setTimeout(tick, ok ? 60000 : 15000);
        };
        timer = setTimeout(tick, initial.length ? 60000 : 0);
        return () => {
            cancelled = true;
            clearTimeout(timer);
        };
    }, [load, initial.length]);

    return (
        <ul className="pv-list" id="previewList">
            {state === 'ready'
                ? rows.map(row => <li key={row.id}><Row row={row} /></li>)
                : state === 'loading'
                    ? [0, 1, 2, 3].map(i => <li key={i} className="pv-skel" />)
                    : <li className="pv-empty">Connecting to the live feed. This list refreshes automatically.</li>}
        </ul>
    );
}
