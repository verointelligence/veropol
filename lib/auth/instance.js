import connect from '@/lib/db';
import { checkEmail } from '@/lib/email-policy.mjs';
import { SESSION_COOKIE, clearedSessionCookie } from '@/lib/device-session.mjs';
import { createMailer } from '@/lib/mail';
import { clientIp, createLimiter } from '@/lib/rate-limit';
import { createAuthService, selfUser } from '@/lib/auth/service';
import { createMongoStore } from '@/lib/auth/store-mongo';
import { failure, json, markerCookie, readCookie, sameOrigin } from '@/lib/auth/http';

const KEY = Symbol.for('vero.auth');
const HOUR = 60 * 60 * 1000;

export const limits = {
    code: createLimiter({ limit: 8, windowMs: HOUR }),
    verify: createLimiter({ limit: 40, windowMs: 10 * 60 * 1000 }),
    complete: createLimiter({ limit: 10, windowMs: HOUR }),
    mutate: createLimiter({ limit: 60, windowMs: 10 * 60 * 1000 }),
    emailChange: createLimiter({ limit: 6, windowMs: HOUR })
};

export function getAuth() {
    if (!globalThis[KEY]) {
        const secret = process.env.AUTH_SECRET || '';
        if (secret.length < 32) return null;
        globalThis[KEY] = createAuthService({ store: createMongoStore(), mailer: createMailer(), secret });
    }
    return globalThis[KEY];
}

export function adminSet() {
    const set = new Set();
    String(process.env.ADMIN_EMAILS || '').split(',').forEach(raw => {
        const checked = checkEmail(raw);
        if (checked.ok) set.add(checked.canonical);
    });
    return set;
}

export function shapeSelf(user) {
    return selfUser(user, { admins: adminSet() });
}

export function sessionCookies(token) {
    return [sessionCookieValue(token), markerCookie(true)];
}

function sessionCookieValue(token) {
    return SESSION_COOKIE + '=' + token + '; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=2592000';
}

export function clearCookies() {
    return [clearedSessionCookie(), markerCookie(false)];
}

export async function guard(request, limiter) {
    if (!sameOrigin(request)) return json({ ok: false, reason: 'forbidden' }, 403);
    if (limiter) {
        const verdict = limiter.check(clientIp(request.headers));
        if (!verdict.ok) return json({ ok: false, reason: 'rate_limited', retryAfterSeconds: verdict.retryAfter }, 429, [], { 'Retry-After': String(verdict.retryAfter) });
    }
    if (!getAuth() || !(await connect())) return json({ ok: false, reason: 'unavailable' }, 503);
    return null;
}

export async function requireUser(request) {
    const auth = getAuth();
    if (!auth || !(await connect())) return { response: json({ ok: false, reason: 'unavailable' }, 503) };
    const url = new URL(request.url);
    const result = await auth.authenticate({
        token: readCookie(request, SESSION_COOKIE),
        method: request.method,
        path: url.pathname + url.search,
        proof: request.headers.get('x-vero-proof') || ''
    });
    if (!result.ok) return { response: json({ ok: false, reason: 'unauthorized' }, 401, clearCookies()) };
    return { auth, user: result.user, session: result.session };
}

export { failure, json };
