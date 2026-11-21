export function createLimiter({ limit, windowMs, maxKeys = 5000 }) {
    const hits = new Map();

    function check(key, now = Date.now()) {
        const cutoff = now - windowMs;
        const list = (hits.get(key) || []).filter(t => t > cutoff);
        if (list.length >= limit) {
            hits.set(key, list);
            return { ok: false, retryAfter: Math.max(1, Math.ceil((list[0] + windowMs - now) / 1000)) };
        }
        list.push(now);
        hits.set(key, list);
        if (hits.size > maxKeys) {
            for (const [k, v] of hits) {
                if (!v.some(t => t > cutoff)) hits.delete(k);
                if (hits.size <= maxKeys) break;
            }
        }
        return { ok: true, retryAfter: 0 };
    }

    return { check };
}

export function clientIp(headers) {
    const forwarded = headers.get('x-forwarded-for');
    if (forwarded) {
        const first = forwarded.split(',')[0].trim();
        if (first) return first.slice(0, 64);
    }
    return (headers.get('x-real-ip') || 'unknown').slice(0, 64);
}
