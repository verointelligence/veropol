import { previewRows } from '@/lib/preview';
import { clientIp, createLimiter } from '@/lib/rate-limit';

export const dynamic = 'force-dynamic';

const limiter = createLimiter({ limit: 120, windowMs: 60 * 1000 });

function reply(body, status = 200, extra = {}) {
    return new Response(JSON.stringify(body), {
        status,
        headers: { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store', ...extra }
    });
}

export async function GET(request) {
    const verdict = limiter.check(clientIp(request.headers));
    if (!verdict.ok) return reply({ rows: [] }, 429, { 'Retry-After': String(verdict.retryAfter) });
    try {
        return reply({ rows: await previewRows(4) });
    } catch {
        return reply({ rows: [] }, 200);
    }
}
