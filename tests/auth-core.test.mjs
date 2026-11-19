import test from 'node:test';
import assert from 'node:assert/strict';
import { checkEmail } from '../lib/email-policy.mjs';
import { createOtpService, OTP_MAX_ATTEMPTS, OTP_RESEND_COOLDOWN_MS, OTP_TTL_MS, OTP_MAX_SENDS_PER_HOUR } from '../lib/otp.mjs';
import { createSession, createProofVerifier, sessionState, normalizeDeviceKey, SESSION_IDLE_MS, SESSION_ABSOLUTE_MS } from '../lib/device-session.mjs';
import { createDeviceKey } from '../lib/device-key-client.mjs';

const SECRET = 'x'.repeat(48);

function memoryStore() {
    const m = new Map();
    return { get: async k => m.get(k) || null, set: async (k, v) => { m.set(k, v); }, remove: async k => { m.delete(k); } };
}

test('email policy accepts allowed providers and canonicalizes aliases', () => {
    assert.equal(checkEmail('  Test.User+spam@Gmail.com ').canonical, 'testuser@gmail.com');
    assert.equal(checkEmail('a.b@googlemail.com').canonical, 'ab@gmail.com');
    assert.equal(checkEmail('name+tag@outlook.com').canonical, 'name@outlook.com');
    assert.equal(checkEmail('name@protonmail.com').canonical, 'name@proton.me');
    assert.equal(checkEmail('name@pm.me').canonical, 'name@proton.me');
    assert.equal(checkEmail('first.last@yahoo.com').canonical, 'first.last@yahoo.com');
    assert.equal(checkEmail('me@icloud.com').ok, true);
});

test('email policy rejects other domains and malformed input', () => {
    assert.deepEqual(checkEmail('x@mailinator.com'), { ok: false, reason: 'domain_not_allowed' });
    assert.deepEqual(checkEmail('someone@company.org'), { ok: false, reason: 'domain_not_allowed' });
    assert.equal(checkEmail('a@b@gmail.com').reason, 'format');
    assert.equal(checkEmail('"quoted"@gmail.com').reason, 'format');
    assert.equal(checkEmail('a..b@gmail.com').reason, 'format');
    assert.equal(checkEmail('+tag@gmail.com').reason, 'format');
    assert.equal(checkEmail('abc@gmail.com.evil.com').reason, 'domain_not_allowed');
    assert.equal(checkEmail(null).reason, 'format');
    assert.equal(checkEmail('a'.repeat(70) + '@gmail.com').reason, 'format');
});

test('otp issues, verifies once and cannot be reused', () => {
    let t = 1_000_000;
    const otp = createOtpService({ secret: SECRET, now: () => t });
    const issued = otp.issue(null, 'a@gmail.com', 'login');
    assert.equal(issued.ok, true);
    assert.match(issued.code, /^\d{6}$/);
    assert.ok(!JSON.stringify(issued.record).includes(issued.code));
    const good = otp.verify(issued.record, 'a@gmail.com', 'login', issued.code);
    assert.equal(good.ok, true);
    const again = otp.verify(good.record, 'a@gmail.com', 'login', issued.code);
    assert.equal(again.ok, false);
    assert.equal(again.reason, 'none');
});

test('otp is bound to email and purpose', () => {
    const otp = createOtpService({ secret: SECRET });
    const issued = otp.issue(null, 'a@gmail.com', 'login');
    assert.equal(otp.verify(issued.record, 'b@gmail.com', 'login', issued.code).ok, false);
    assert.equal(otp.verify(issued.record, 'a@gmail.com', 'email_change', issued.code).ok, false);
    assert.equal(otp.issue(null, 'a@gmail.com', 'other').reason, 'purpose');
});

test('otp locks after max wrong attempts even if the right code follows', () => {
    const otp = createOtpService({ secret: SECRET });
    const issued = otp.issue(null, 'a@gmail.com', 'login');
    let record = issued.record;
    const wrong = issued.code === '000000' ? '111111' : '000000';
    let last;
    for (let i = 0; i < OTP_MAX_ATTEMPTS; i++) {
        last = otp.verify(record, 'a@gmail.com', 'login', wrong);
        record = last.record;
    }
    assert.equal(last.reason, 'locked');
    assert.equal(otp.verify(record, 'a@gmail.com', 'login', issued.code).ok, false);
});

test('otp rejects non numeric input and counts it as an attempt', () => {
    const otp = createOtpService({ secret: SECRET });
    const issued = otp.issue(null, 'a@gmail.com', 'login');
    const r = otp.verify(issued.record, 'a@gmail.com', 'login', '12ab56');
    assert.equal(r.ok, false);
    assert.equal(r.reason, 'invalid');
    assert.equal(r.record.attempts, 1);
    assert.equal(otp.verify(issued.record, 'a@gmail.com', 'login', undefined).ok, false);
});

test('otp expires', () => {
    let t = 5_000_000;
    const otp = createOtpService({ secret: SECRET, now: () => t });
    const issued = otp.issue(null, 'a@gmail.com', 'login');
    t += OTP_TTL_MS + 1;
    const r = otp.verify(issued.record, 'a@gmail.com', 'login', issued.code);
    assert.equal(r.ok, false);
    assert.equal(r.reason, 'expired');
});

test('otp enforces resend cooldown and hourly cap', () => {
    let t = 9_000_000;
    const otp = createOtpService({ secret: SECRET, now: () => t });
    let record = null;
    for (let i = 0; i < OTP_MAX_SENDS_PER_HOUR; i++) {
        const r = otp.issue(record, 'a@gmail.com', 'login');
        assert.equal(r.ok, true);
        record = r.record;
        const blocked = otp.issue(record, 'a@gmail.com', 'login');
        assert.equal(blocked.reason, 'cooldown');
        t += OTP_RESEND_COOLDOWN_MS + 1;
    }
    const capped = otp.issue(record, 'a@gmail.com', 'login');
    assert.equal(capped.reason, 'hourly_limit');
    t += 60 * 60 * 1000;
    assert.equal(otp.issue(record, 'a@gmail.com', 'login').ok, true);
});

test('otp service refuses weak secrets', () => {
    assert.throws(() => createOtpService({ secret: 'short' }));
});

test('device key rejects malformed public keys', () => {
    assert.equal(normalizeDeviceKey(null), null);
    assert.equal(normalizeDeviceKey({ kty: 'RSA' }), null);
    assert.equal(normalizeDeviceKey({ kty: 'EC', crv: 'P-256', x: 'a', y: 'b' }), null);
    assert.equal(normalizeDeviceKey({ kty: 'EC', crv: 'P-256', x: '!'.repeat(43), y: '!'.repeat(43) }), null);
});

test('a session works only with the device that created it', async () => {
    const now = () => Date.now();
    const verify = createProofVerifier({ now });
    const victim = createDeviceKey({ store: memoryStore() });
    const attacker = createDeviceKey({ store: memoryStore() });
    const created = createSession({ userId: 'u1', deviceJwk: await victim.publicJwk() });
    assert.ok(created);
    const record = created.record;
    const path = '/api/me?x=1';

    const own = await victim.sign('GET', path);
    assert.deepEqual(verify({ method: 'GET', path, record, proof: own }), { ok: true });

    const stolen = await attacker.sign('GET', path);
    assert.equal(verify({ method: 'GET', path, record, proof: stolen }).reason, 'proof_invalid');

    assert.equal(verify({ method: 'GET', path, record, proof: undefined }).reason, 'proof_missing');
    assert.equal(verify({ method: 'GET', path, record, proof: 'a.b.c' }).reason, 'proof_missing');
});

test('proofs cannot be replayed, retargeted or reused late', async () => {
    let t = Date.now();
    const verify = createProofVerifier({ now: () => t });
    const device = createDeviceKey({ store: memoryStore(), now: () => t });
    const { record } = createSession({ userId: 'u1', deviceJwk: await device.publicJwk(), now: t });

    const proof = await device.sign('POST', '/api/articles');
    assert.equal(verify({ method: 'POST', path: '/api/articles', record, proof }).ok, true);
    assert.equal(verify({ method: 'POST', path: '/api/articles', record, proof }).reason, 'proof_replay');

    const second = await device.sign('POST', '/api/articles');
    assert.equal(verify({ method: 'POST', path: '/api/me', record, proof: second }).reason, 'proof_invalid');
    assert.equal(verify({ method: 'GET', path: '/api/articles', record, proof: second }).reason, 'proof_invalid');

    const third = await device.sign('POST', '/api/articles');
    t += 61000;
    assert.equal(verify({ method: 'POST', path: '/api/articles', record, proof: third }).reason, 'proof_stale');
});

test('proof from the same key still fails for another session record', async () => {
    const verify = createProofVerifier();
    const a = createDeviceKey({ store: memoryStore() });
    const b = createDeviceKey({ store: memoryStore() });
    const sessionB = createSession({ userId: 'u2', deviceJwk: await b.publicJwk() }).record;
    const proof = await a.sign('GET', '/api/me');
    assert.equal(verify({ method: 'GET', path: '/api/me', record: sessionB, proof }).reason, 'proof_invalid');
});

test('device key persists and reset creates a new identity', async () => {
    const store = memoryStore();
    const one = createDeviceKey({ store });
    const first = await one.publicJwk();
    const two = createDeviceKey({ store });
    assert.deepEqual(await two.publicJwk(), first);
    await two.reset();
    const three = createDeviceKey({ store });
    assert.notDeepEqual(await three.publicJwk(), first);
});

test('session expiry and idle timeout', () => {
    const base = 1_700_000_000_000;
    const record = { expiresAt: base + SESSION_ABSOLUTE_MS, lastSeenAt: base };
    assert.equal(sessionState(record, base + 1000), 'ok');
    assert.equal(sessionState(record, base + SESSION_IDLE_MS + 1), 'idle');
    assert.equal(sessionState({ ...record, lastSeenAt: base + SESSION_ABSOLUTE_MS }, base + SESSION_ABSOLUTE_MS + 1), 'expired');
    assert.equal(sessionState(null, base), 'missing');
});
