import crypto from 'node:crypto';

export const OTP_TTL_MS = 10 * 60 * 1000;
export const OTP_MAX_ATTEMPTS = 5;
export const OTP_RESEND_COOLDOWN_MS = 60 * 1000;
export const OTP_MAX_SENDS_PER_HOUR = 5;

const HOUR_MS = 60 * 60 * 1000;
const PURPOSES = new Set(['login', 'email_change']);

function emptyRecord() {
    return { purpose: '', codeHash: null, expiresAt: 0, attempts: 0, sentAt: 0, sendTimes: [] };
}

export function createOtpService({ secret, now = () => Date.now() }) {
    if (typeof secret !== 'string' || secret.length < 32) throw new Error('otp secret must be at least 32 characters');

    function digest(email, purpose, code) {
        return crypto.createHmac('sha256', secret).update(email + '|' + purpose + '|' + code).digest();
    }

    function issue(record, email, purpose) {
        if (!PURPOSES.has(purpose)) return { ok: false, reason: 'purpose' };
        const t = now();
        const prev = record || emptyRecord();
        const sendTimes = prev.sendTimes.filter(x => t - x < HOUR_MS);
        if (prev.sentAt && t - prev.sentAt < OTP_RESEND_COOLDOWN_MS) {
            return { ok: false, reason: 'cooldown', retryAfterMs: OTP_RESEND_COOLDOWN_MS - (t - prev.sentAt) };
        }
        if (sendTimes.length >= OTP_MAX_SENDS_PER_HOUR) {
            return { ok: false, reason: 'hourly_limit', retryAfterMs: HOUR_MS - (t - sendTimes[0]) };
        }
        const code = String(crypto.randomInt(0, 1000000)).padStart(6, '0');
        return {
            ok: true,
            code,
            record: {
                purpose,
                codeHash: digest(email, purpose, code).toString('hex'),
                expiresAt: t + OTP_TTL_MS,
                attempts: 0,
                sentAt: t,
                sendTimes: sendTimes.concat(t)
            }
        };
    }

    function verify(record, email, purpose, input) {
        const t = now();
        if (!record || !record.codeHash || record.purpose !== purpose) return { ok: false, reason: 'none', record };
        if (t > record.expiresAt) return { ok: false, reason: 'expired', record: { ...record, codeHash: null } };
        const candidate = typeof input === 'string' ? input.trim() : '';
        const expected = Buffer.from(record.codeHash, 'hex');
        const actual = digest(email, purpose, /^\d{6}$/.test(candidate) ? candidate : 'invalid');
        const match = /^\d{6}$/.test(candidate) && expected.length === actual.length && crypto.timingSafeEqual(expected, actual);
        if (match) return { ok: true, record: { ...record, codeHash: null, attempts: 0 } };
        const attempts = record.attempts + 1;
        if (attempts >= OTP_MAX_ATTEMPTS) return { ok: false, reason: 'locked', record: { ...record, codeHash: null, attempts } };
        return { ok: false, reason: 'invalid', attemptsLeft: OTP_MAX_ATTEMPTS - attempts, record: { ...record, attempts } };
    }

    return { issue, verify };
}
