export const MARKER_COOKIE = 'vero_in';

const STATUS = {
    domain_not_allowed: 422, email_format: 422, cooldown: 429, hourly_limit: 429, mail_failed: 502, invalid: 400, expired: 400,
    locked: 429, none: 400, device_key: 400, banned: 403, ticket: 400, username_format: 422, username_reserved: 422,
    username_taken: 409, birth_format: 422, too_young: 403, display_name: 422, bio: 422, same_email: 422, email_taken: 409,
    update_failed: 500, purpose: 400, title: 422, summary: 422, body: 422, category: 422, links: 422, spam: 422, daily_limit: 429,
    duplicate: 409, adult_only: 403, not_found: 404, forbidden: 403, unavailable: 503
};

export function json(data, status = 200, cookies = [], extra = {}) {
    const headers = new Headers({ 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store', ...extra });
    cookies.forEach(cookie => headers.append('Set-Cookie', cookie));
    return new Response(JSON.stringify(data), { status, headers });
}

export function failure(result) {
    const body = { ok: false, reason: result.reason };
    if (result.attemptsLeft !== undefined) body.attemptsLeft = result.attemptsLeft;
    if (result.retryAt) body.retryAt = result.retryAt;
    if (result.retryAfterMs) body.retryAfterSeconds = Math.ceil(result.retryAfterMs / 1000);
    const extra = result.retryAfterMs ? { 'Retry-After': String(Math.ceil(result.retryAfterMs / 1000)) } : {};
    return json(body, STATUS[result.reason] || 400, [], extra);
}

export async function readJson(request, max = 8192) {
    const declared = parseInt(request.headers.get('content-length') || '0', 10);
    if (declared > max) return null;
    let text;
    try {
        text = await request.text();
    } catch {
        return null;
    }
    if (text.length > max) return null;
    try {
        const value = JSON.parse(text);
        return value && typeof value === 'object' && !Array.isArray(value) ? value : null;
    } catch {
        return null;
    }
}

export function sameOrigin(request) {
    const origin = request.headers.get('origin');
    if (!origin) return false;
    const host = request.headers.get('x-forwarded-host') || request.headers.get('host');
    try {
        return new URL(origin).host === host;
    } catch {
        return false;
    }
}

export function readCookie(request, name) {
    const header = request.headers.get('cookie') || '';
    for (const part of header.split(';')) {
        const index = part.indexOf('=');
        if (index === -1) continue;
        if (part.slice(0, index).trim() === name) return part.slice(index + 1).trim();
    }
    return '';
}

export function markerCookie(on, maxAgeSeconds = 2592000) {
    return MARKER_COOKIE + '=' + (on ? '1' : '') + '; Path=/; Secure; SameSite=Lax; Max-Age=' + (on ? maxAgeSeconds : 0);
}
