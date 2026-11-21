const RESERVED = new Set([
    'admin', 'administrator', 'root', 'system', 'support', 'help', 'security', 'staff', 'team', 'moderator', 'mod',
    'vero', 'verointels', 'veropol', 'official', 'editor', 'news', 'api', 'login', 'logout', 'signup', 'register',
    'account', 'settings', 'live', 'explore', 'articles', 'article', 'report', 'privacy', 'terms', 'methodology',
    'null', 'undefined', 'anonymous', 'everyone', 'here', 'me', 'u'
]);

export const USERNAME_COOLDOWN_MS = 30 * 24 * 60 * 60 * 1000;
export const MIN_AGE = 13;
export const ADULT_AGE = 18;

export function validateUsername(input) {
    const value = typeof input === 'string' ? input.trim().toLowerCase() : '';
    if (!/^[a-z0-9_]{3,20}$/.test(value)) return { ok: false, reason: 'username_format' };
    if (!/[a-z]/.test(value)) return { ok: false, reason: 'username_format' };
    if (RESERVED.has(value)) return { ok: false, reason: 'username_reserved' };
    return { ok: true, value };
}

export function ageOn(birth, now) {
    const today = new Date(now);
    let age = today.getUTCFullYear() - birth.getUTCFullYear();
    const before = today.getUTCMonth() < birth.getUTCMonth() || (today.getUTCMonth() === birth.getUTCMonth() && today.getUTCDate() < birth.getUTCDate());
    if (before) age -= 1;
    return age;
}

export function validateBirthDate(input, now = Date.now()) {
    if (typeof input !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(input)) return { ok: false, reason: 'birth_format' };
    const birth = new Date(input + 'T00:00:00Z');
    if (Number.isNaN(birth.getTime()) || birth.toISOString().slice(0, 10) !== input) return { ok: false, reason: 'birth_format' };
    const age = ageOn(birth, now);
    if (age < 0 || age > 120) return { ok: false, reason: 'birth_format' };
    if (age < MIN_AGE) return { ok: false, reason: 'too_young' };
    return { ok: true, value: birth, age };
}

export function cleanDisplayName(input) {
    const value = typeof input === 'string' ? input.replace(/[\u0000-\u001f\u007f\u200b-\u200f\u202a-\u202e\u2066-\u2069]/g, ' ').replace(/\s+/g, ' ').trim() : '';
    if (value.length < 1 || value.length > 40) return { ok: false, reason: 'display_name' };
    return { ok: true, value };
}

export function cleanBio(input) {
    if (input === undefined || input === null || input === '') return { ok: true, value: '' };
    if (typeof input !== 'string') return { ok: false, reason: 'bio' };
    const value = input
        .replace(/[\u0000-\u0009\u000b-\u001f\u007f\u200b-\u200f\u202a-\u202e\u2066-\u2069]/g, '')
        .replace(/\r\n?/g, '\n')
        .replace(/[ \t]+/g, ' ')
        .replace(/\n{3,}/g, '\n\n')
        .trim();
    if (value.length > 280) return { ok: false, reason: 'bio' };
    return { ok: true, value };
}
