import dns from 'node:dns/promises';
import net from 'node:net';
import { getEngine } from '@/lib/news/engine';
import { clientIp, createLimiter } from '@/lib/rate-limit';

export const dynamic = 'force-dynamic';

const MAX_BYTES = 6 * 1024 * 1024;
const CACHE_LIMIT = 70 * 1024 * 1024;
const UA = 'Mozilla/5.0 (compatible; VEROBot/1.0; +https://veropol.onrender.com; veropol@proton.me)';
const STATE = Symbol.for('vero.img.cache');
const limiter = createLimiter({ limit: 400, windowMs: 60 * 1000 });

function state() {
    if (!globalThis[STATE]) globalThis[STATE] = { map: new Map(), bytes: 0 };
    return globalThis[STATE];
}

function privateAddress(ip) {
    if (net.isIPv4(ip)) {
        const p = ip.split('.').map(Number);
        return p[0] === 10 || p[0] === 127 || p[0] === 0 || (p[0] === 169 && p[1] === 254) || (p[0] === 172 && p[1] >= 16 && p[1] <= 31) || (p[0] === 192 && p[1] === 168) || (p[0] === 100 && p[1] >= 64 && p[1] <= 127);
    }
    const v = ip.toLowerCase();
    return v === '::1' || v === '::' || v.startsWith('fc') || v.startsWith('fd') || v.startsWith('fe80') || v.startsWith('::ffff:');
}

async function safeHost(hostname) {
    const list = await dns.lookup(hostname, { all: true });
    return list.length > 0 && list.every(a => !privateAddress(a.address));
}

async function pullImage(u, hops) {
    const url = new URL(u);
    if (!/^https?:$/.test(url.protocol) || !(await safeHost(url.hostname))) throw new Error('blocked');
    const response = await fetch(u, {
        headers: { 'User-Agent': UA, Accept: 'image/avif,image/webp,image/png,image/jpeg,image/*;q=0.8', Referer: url.origin + '/' },
        redirect: 'manual',
        signal: AbortSignal.timeout(10000)
    });
    if (response.status >= 300 && response.status < 400 && response.headers.get('location') && hops < 3) {
        return pullImage(new URL(response.headers.get('location'), u).toString(), hops + 1);
    }
    if (!response.ok) throw new Error('HTTP ' + response.status);
    const type = String(response.headers.get('content-type') || '').split(';')[0].trim().toLowerCase();
    if (!/^image\/(jpeg|png|webp|gif|avif)$/.test(type)) throw new Error('type');
    const len = parseInt(response.headers.get('content-length') || '0', 10);
    if (len > MAX_BYTES) throw new Error('big');
    const buf = Buffer.from(await response.arrayBuffer());
    if (buf.length < 200 || buf.length > MAX_BYTES) throw new Error('size');
    return { buf, type };
}

function remember(key, value, size) {
    const s = state();
    s.map.set(key, value);
    s.bytes += size;
    while (s.bytes > CACHE_LIMIT && s.map.size) {
        const k = s.map.keys().next().value;
        const v = s.map.get(k);
        s.bytes -= v && v.buf ? v.buf.length : 0;
        s.map.delete(k);
    }
}

const plain = status => new Response(null, { status });

export async function GET(request) {
    if (!limiter.check(clientIp(request.headers)).ok) return plain(429);
    const u = String(new URL(request.url).searchParams.get('u') || '').slice(0, 1500);
    let url;
    try {
        url = new URL(u);
    } catch {
        return plain(400);
    }
    const wiki = url.hostname === 'upload.wikimedia.org' || url.hostname === 'commons.wikimedia.org';
    if (!wiki && !getEngine().imageAllowed(u)) return plain(403);
    const s = state();
    let hit = s.map.get(u);
    if (hit && hit.fail && hit.exp < Date.now()) {
        s.map.delete(u);
        hit = null;
    }
    if (!hit) {
        try {
            const got = await pullImage(u, 0);
            hit = { buf: got.buf, type: got.type };
            remember(u, hit, got.buf.length);
        } catch {
            remember(u, { fail: true, exp: Date.now() + 10 * 60 * 1000 }, 0);
            return plain(502);
        }
    }
    if (hit.fail) return plain(502);
    return new Response(hit.buf, {
        headers: {
            'Content-Type': hit.type,
            'Cache-Control': 'public, max-age=604800',
            'X-Content-Type-Options': 'nosniff',
            'Content-Security-Policy': "default-src 'none'; sandbox"
        }
    });
}
