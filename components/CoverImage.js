'use client';

import { useEffect, useRef, useState } from 'react';

export default function CoverImage({ src, eager = false }) {
    const [failed, setFailed] = useState(false);
    const ref = useRef(null);

    useEffect(() => {
        const img = ref.current;
        if (img && img.complete && img.naturalWidth === 0) setFailed(true);
    }, []);

    if (failed) return <i className="ph ph-globe-hemisphere-west cover-fallback" aria-hidden="true" />;
    return (
        <img
            ref={ref}
            className="ready"
            src={src}
            alt=""
            loading={eager ? 'eager' : 'lazy'}
            decoding="async"
            referrerPolicy="no-referrer"
            onError={() => setFailed(true)}
        />
    );
}
