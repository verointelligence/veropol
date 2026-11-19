'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { DISCORD_URL } from '@/lib/site';

const LINKS = [
    { href: '/live', label: 'Live' },
    { href: '/explore', label: 'Explore' },
    { href: '/articles', label: 'Articles' }
];

function systemTheme() {
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark';
}

function storedTheme() {
    try {
        return localStorage.getItem('vero_theme');
    } catch {
        return null;
    }
}

export default function Nav() {
    const pathname = usePathname();
    const [open, setOpen] = useState(false);
    const [scrolled, setScrolled] = useState(false);
    const [theme, setTheme] = useState(null);

    const applyTheme = useCallback((next, persist) => {
        document.documentElement.setAttribute('data-theme', next);
        if (persist) {
            try {
                localStorage.setItem('vero_theme', next);
            } catch {
                setTheme(next);
            }
        }
        setTheme(next);
    }, []);

    useEffect(() => {
        setTheme(document.documentElement.getAttribute('data-theme') === 'light' ? 'light' : 'dark');
        if (!window.matchMedia) return undefined;
        const mq = window.matchMedia('(prefers-color-scheme: light)');
        const follow = () => {
            const saved = storedTheme();
            if (saved !== 'light' && saved !== 'dark') applyTheme(systemTheme(), false);
        };
        mq.addEventListener('change', follow);
        return () => mq.removeEventListener('change', follow);
    }, [applyTheme]);

    useEffect(() => {
        let ticking = false;
        const onScroll = () => {
            if (ticking) return;
            ticking = true;
            requestAnimationFrame(() => {
                setScrolled(window.scrollY > 40);
                ticking = false;
            });
        };
        window.addEventListener('scroll', onScroll, { passive: true });
        onScroll();
        return () => window.removeEventListener('scroll', onScroll);
    }, []);

    useEffect(() => {
        setOpen(false);
    }, [pathname]);

    function toggleTheme() {
        const current = document.documentElement.getAttribute('data-theme');
        applyTheme(current === 'dark' ? 'light' : 'dark', true);
    }

    return (
        <nav className={'nav-container' + (scrolled ? ' scrolled' : '')} id="navbar">
            <Link href="/" className="brand" aria-label="VERO">
                <img src="/assets/logo-96.webp" srcSet="/assets/logo-96.webp 1x, /assets/logo-192.webp 2x" width="36" height="36" alt="VERO" className="brand-logo" />
                <span>VERO</span>
            </Link>
            <div className={'nav-menu' + (open ? ' open' : '')} id="navMenu">
                <div className="nav-center" id="navLinks">
                    {LINKS.map(link => {
                        const active = pathname === link.href || pathname.startsWith(link.href + '/');
                        return (
                            <Link key={link.href} href={link.href} className={'nav-link' + (active ? ' active' : '')} aria-current={active ? 'page' : undefined} onClick={() => setOpen(false)}>
                                <span>{link.label}</span>
                            </Link>
                        );
                    })}
                </div>
                <div className="nav-tools" id="navTools">
                    <a href={DISCORD_URL} className="btn-nav" target="_blank" rel="noopener noreferrer">Discord</a>
                    <button id="themeToggle" className="theme-toggle-btn" type="button" aria-label="Toggle theme" onClick={toggleTheme}>
                        <i className={theme === 'dark' ? 'ph ph-sun' : 'ph ph-moon'} id="themeIcon" />
                    </button>
                </div>
            </div>
            <button className="nav-toggle" id="navBurger" type="button" aria-expanded={open} aria-controls="navMenu" aria-label="Menu" onClick={() => setOpen(value => !value)}>
                <i className="ph ph-list" />
            </button>
        </nav>
    );
}
