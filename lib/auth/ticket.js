import crypto from 'node:crypto';

export const TICKET_TTL_MS = 15 * 60 * 1000;

function mac(secret, payload) {
    return crypto.createHmac('sha256', secret).update('vero-signup|' + payload).digest('base64url');
}

export function signTicket(secret, { canonical, address }, now = Date.now()) {
    const payload = Buffer.from(JSON.stringify({ c: canonical, a: address, x: now + TICKET_TTL_MS })).toString('base64url');
    return payload + '.' + mac(secret, payload);
}

export function verifyTicket(secret, ticket, now = Date.now()) {
    if (typeof ticket !== 'string' || ticket.length > 600) return null;
    const parts = ticket.split('.');
    if (parts.length !== 2) return null;
    const expected = Buffer.from(mac(secret, parts[0]));
    const actual = Buffer.from(parts[1]);
    if (expected.length !== actual.length || !crypto.timingSafeEqual(expected, actual)) return null;
    let data;
    try {
        data = JSON.parse(Buffer.from(parts[0], 'base64url').toString('utf8'));
    } catch {
        return null;
    }
    if (!data || typeof data.c !== 'string' || typeof data.a !== 'string' || typeof data.x !== 'number' || now > data.x) return null;
    return { canonical: data.c, address: data.a };
}
