import crypto from 'node:crypto';

export const SESSION_ABSOLUTE_MS = 30 * 24 * 60 * 60 * 1000;
export const SESSION_IDLE_MS = 7 * 24 * 60 * 60 * 1000;
export const SESSION_COOKIE = '__Host-vero_session';

const B64U = /^[A-Za-z0-9_-]+$/;

export function hashToken(token) {
    return crypto.createHash('sha256').update(String(token)).digest('hex');
}

export function normalizeDeviceKey(jwk) {
    if (!jwk || typeof jwk !== 'object') return null;
    if (jwk.kty !== 'EC' || jwk.crv !== 'P-256') return null;
    if (typeof jwk.x !== 'string' || typeof jwk.y !== 'string') return null;
    if (jwk.x.length !== 43 || jwk.y.length !== 43 || !B64U.test(jwk.x) || !B64U.test(jwk.y)) return null;
    const clean = { kty: 'EC', crv: 'P-256', x: jwk.x, y: jwk.y };
    try {
        crypto.createPublicKey({ key: clean, format: 'jwk' });
    } catch {
        return null;
    }
    const thumbprint = crypto.createHash('sha256')
        .update(JSON.stringify({ crv: clean.crv, kty: clean.kty, x: clean.x, y: clean.y }))
        .digest('base64url');
    return { jwk: clean, thumbprint };
}

export function createSession({ userId, deviceJwk, now = Date.now() }) {
    const device = normalizeDeviceKey(deviceJwk);
    if (!device || !userId) return null;
    const token = crypto.randomBytes(32).toString('base64url');
    return {
        token,
        record: {
            idHash: hashToken(token),
            userId: String(userId),
            device,
            createdAt: now,
            lastSeenAt: now,
            expiresAt: now + SESSION_ABSOLUTE_MS
        }
    };
}

export function sessionState(record, now = Date.now()) {
    if (!record) return 'missing';
    if (now > record.expiresAt) return 'expired';
    if (now - record.lastSeenAt > SESSION_IDLE_MS) return 'idle';
    return 'ok';
}

export function sessionCookie(token) {
    return SESSION_COOKIE + '=' + token + '; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=' + Math.floor(SESSION_ABSOLUTE_MS / 1000);
}

export function clearedSessionCookie() {
    return SESSION_COOKIE + '=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0';
}

export function createProofVerifier({ now = () => Date.now(), windowMs = 60000, maxNonces = 5000 } = {}) {
    const seen = new Map();

    function prune(t) {
        for (const [k, exp] of seen) {
            if (exp > t) break;
            seen.delete(k);
        }
        while (seen.size > maxNonces) seen.delete(seen.keys().next().value);
    }

    return function verifyProof({ method, path, record, proof }) {
        if (!record || !record.device) return { ok: false, reason: 'session' };
        if (typeof proof !== 'string' || proof.length < 20 || proof.length > 400) return { ok: false, reason: 'proof_missing' };
        const parts = proof.split('.');
        if (parts.length !== 3) return { ok: false, reason: 'proof_format' };
        const [ts, nonce, sig] = parts;
        if (!/^\d{13}$/.test(ts) || !/^[A-Za-z0-9_-]{16,32}$/.test(nonce) || !B64U.test(sig)) return { ok: false, reason: 'proof_format' };
        const t = now();
        if (Math.abs(t - Number(ts)) > windowMs) return { ok: false, reason: 'proof_stale' };
        const replayKey = record.idHash + ':' + nonce;
        if (seen.has(replayKey)) return { ok: false, reason: 'proof_replay' };
        const data = Buffer.from([String(method).toUpperCase(), String(path), ts, nonce].join('\n'));
        let valid = false;
        try {
            const key = crypto.createPublicKey({ key: record.device.jwk, format: 'jwk' });
            valid = crypto.verify('sha256', data, { key, dsaEncoding: 'ieee-p1363' }, Buffer.from(sig, 'base64url'));
        } catch {
            valid = false;
        }
        if (!valid) return { ok: false, reason: 'proof_invalid' };
        seen.set(replayKey, t + windowMs * 2);
        prune(t);
        return { ok: true };
    };
}
