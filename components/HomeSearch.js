'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function HomeSearch() {
    const router = useRouter();
    const [value, setValue] = useState('');

    function submit(event) {
        event.preventDefault();
        const q = value.trim().slice(0, 120);
        router.push(q ? '/explore?q=' + encodeURIComponent(q) : '/explore');
    }

    return (
        <form className="home-search" role="search" autoComplete="off" onSubmit={submit}>
            <div className="search-bar massive">
                <i className="ph ph-magnifying-glass search-icon" />
                <input type="text" value={value} onChange={event => setValue(event.target.value)} maxLength={120} autoComplete="off" spellCheck={false} placeholder="Search any region, leader or crisis" aria-label="Search" />
                <button className="search-pulse-btn" type="submit" aria-label="Run search">
                    <svg className="radar-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                        <circle cx="12" cy="12" r="9" />
                        <circle cx="12" cy="12" r="4.8" />
                        <g className="radar-sweep">
                            <path d="M12 12L19.8 7.5" />
                            <path d="M12 12V3A9 9 0 0 1 19.8 7.5Z" fill="currentColor" fillOpacity="0.35" stroke="none" />
                        </g>
                        <circle className="radar-blip" cx="15.8" cy="16" r="1.1" fill="currentColor" stroke="none" />
                    </svg>
                </button>
            </div>
        </form>
    );
}
