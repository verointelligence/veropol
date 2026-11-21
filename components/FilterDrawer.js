'use client';

import { useEffect, useRef, useState } from 'react';

export default function FilterDrawer({ count = 0, children }) {
    const [open, setOpen] = useState(false);
    const [wide, setWide] = useState(false);
    const panelRef = useRef(null);
    const openerRef = useRef(null);

    useEffect(() => {
        const mq = window.matchMedia('(min-width: 1100px)');
        const sync = () => {
            setWide(mq.matches);
            if (mq.matches) setOpen(false);
        };
        sync();
        mq.addEventListener('change', sync);
        return () => mq.removeEventListener('change', sync);
    }, []);

    useEffect(() => {
        document.documentElement.classList.toggle('filters-open', open);
        return () => document.documentElement.classList.remove('filters-open');
    }, [open]);

    useEffect(() => {
        if (!open) return undefined;
        const onKey = event => {
            if (event.key === 'Escape') setOpen(false);
        };
        document.addEventListener('keydown', onKey);
        return () => document.removeEventListener('keydown', onKey);
    }, [open]);

    useEffect(() => {
        if (open && panelRef.current) {
            const first = panelRef.current.querySelector('.filter-btn.active') || panelRef.current.querySelector('a, button');
            if (first) first.focus({ preventScroll: true });
        } else if (!open && openerRef.current && typeof openerRef.current.focus === 'function') {
            openerRef.current.focus({ preventScroll: true });
            openerRef.current = null;
        }
    }, [open]);

    function toggle() {
        if (!open) openerRef.current = document.activeElement;
        setOpen(value => !value);
    }

    return (
        <>
            <div className="filter-bar">
                <button type="button" className="filter-toggle" aria-expanded={open} aria-controls="filterPanel" onClick={toggle}>
                    <i className="ph ph-funnel-simple" />
                    <span>Filters</span>
                    {count > 0 ? <span className="filter-count">{count}</span> : null}
                </button>
            </div>
            <aside
                className={'filter-panel' + (open ? ' open' : '')}
                id="filterPanel"
                aria-label="Filters"
                ref={panelRef}
                inert={!wide && !open}
                onClick={event => {
                    if (event.target.closest('a')) setOpen(false);
                }}
            >
                <div className="filter-head">
                    <h2>Filters</h2>
                    <button type="button" className="filter-close" aria-label="Close filters" onClick={() => setOpen(false)}>
                        <i className="ph ph-x" />
                    </button>
                </div>
                {children}
                <button type="button" className="filter-apply" onClick={() => setOpen(false)}>Show results</button>
            </aside>
            <div className={'filter-scrim' + (open ? ' show' : '')} onClick={() => setOpen(false)} />
        </>
    );
}
