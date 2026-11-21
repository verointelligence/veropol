import test from 'node:test';
import assert from 'node:assert/strict';
import { createAuthService, selfUser, publicUser } from '../lib/auth/service.js';
import { createDeviceKey } from '../lib/device-key-client.mjs';
import { createMailer, buildMessage } from '../lib/mail.js';
import { signTicket, verifyTicket } from '../lib/auth/ticket.js';
import { USERNAME_COOLDOWN_MS } from '../lib/auth/validators.js';

const SECRET = 's'.repeat(48);

function memoryStore() {
    const users = new Map();
    const sessions = new Map();
    const codes = new Map();
    let seq = 0;
    const dupe = (data, skipId) => {
        for (const u of users.values()) {
            if (u.id === skipId) continue;
            if (data.email && u.email === data.email) return 'duplicate_email';
            if (data.username && u.username === data.username) return 'duplicate_username';
        }
        return null;
    };
    return {
        users, sessions, codes,
        findUserByEmail: async e => [...users.values()].find(u => u.email === e) || null,
        findUserByUsername: async n => [...users.values()].find(u => u.username === n) || null,
        findUserById: async id => users.get(id) || null,
        createUser: async data => {
            const reason = dupe(data);
            if (reason) return { ok: false, reason };
            const user = { id: 'u' + ++seq, banned: false, ...data };
            users.set(user.id, user);
            return { ok: true, user };
        },
        updateUser: async (id, patch) => {
            const reason = dupe(patch, id);
            if (reason) return { ok: false, reason };
            const user = { ...users.get(id), ...patch };
            users.set(id, user);
            return { ok: true, user };
        },
        getCode: async k => codes.get(k) || null,
        setCode: async (k, r) => { if (r) codes.set(k, r); else codes.delete(k); },
        createSession: async r => { sessions.set(r.idHash, r); },
        findSession: async h => sessions.get(h) || null,
        touchSession: async (h, t) => { sessions.get(h).lastSeenAt = t; },
        deleteSession: async h => { sessions.delete(h); }
    };
}

function setup(options = {}) {
    const store = memoryStore();
    const sent = [];
    const mailer = { sendCode: async (to, code, purpose) => { if (options.failMail) return { ok: false }; sent.push({ to, code, purpose }); return { ok: true }; } };
    const clock = { t: Date.UTC(2026, 10, 21, 12, 0, 0) };
    const auth = createAuthService({ store, mailer, secret: SECRET, now: () => clock.t });
    return { store, sent, auth, clock };
}

function memKeyStore() {
    const m = new Map();
    return { get: async k => m.get(k) || null, set: async (k, v) => { m.set(k, v); }, remove: async k => { m.delete(k); } };
}

async function newDevice(clock) {
    return createDeviceKey({ store: memKeyStore(), now: () => clock.t });
}

async function signUp(env, email = 'Test.User+a@gmail.com', username = 'tester') {
    const device = await newDevice(env.clock);
    const jwk = await device.publicJwk();
    assert.equal((await env.auth.requestCode({ email })).ok, true);
    const code = env.sent.at(-1).code;
    const verified = await env.auth.verifyCode({ email, code, deviceJwk: jwk });
    assert.equal(verified.status, 'profile_required');
    const done = await env.auth.completeSignup({ ticket: verified.ticket, username, birthDate: '2000-05-05', deviceJwk: jwk });
    assert.equal(done.ok, true);
    return { device, jwk, token: done.token, user: done.user };
}

async function authed(env, session, method, path) {
    const proof = await session.device.sign(method, path);
    return env.auth.authenticate({ token: session.token, method, path, proof });
}

test('service refuses a weak secret', () => {
    assert.throws(() => createAuthService({ store: memoryStore(), mailer: {}, secret: 'short' }));
});

test('request code rejects unsupported domains and bad emails', async () => {
    const env = setup();
    assert.deepEqual(await env.auth.requestCode({ email: 'a@mailinator.com' }), { ok: false, reason: 'domain_not_allowed' });
    assert.deepEqual(await env.auth.requestCode({ email: 'nope' }), { ok: false, reason: 'email_format' });
    assert.equal(env.sent.length, 0);
});

test('request code applies cooldown and restores state when mail fails', async () => {
    const env = setup();
    assert.equal((await env.auth.requestCode({ email: 'a@gmail.com' })).ok, true);
    const again = await env.auth.requestCode({ email: 'a@gmail.com' });
    assert.equal(again.reason, 'cooldown');
    const failing = setup({ failMail: true });
    const r = await failing.auth.requestCode({ email: 'b@gmail.com' });
    assert.equal(r.reason, 'mail_failed');
    assert.equal(failing.store.codes.size, 0);
});

test('new users get a profile ticket, then an account and session', async () => {
    const env = setup();
    const session = await signUp(env);
    assert.equal(session.user.email, 'testuser@gmail.com');
    assert.equal(session.user.emailDisplay, 'test.user+a@gmail.com');
    assert.deepEqual(session.user.badges, ['email_verified']);
    const me = await authed(env, session, 'GET', '/api/me');
    assert.equal(me.ok, true);
    assert.equal(me.user.username, 'tester');
});

test('returning users sign in directly and aliases map to one account', async () => {
    const env = setup();
    await signUp(env);
    env.clock.t += 120000;
    const device = await newDevice(env.clock);
    await env.auth.requestCode({ email: 'testuser@gmail.com' });
    const code = env.sent.at(-1).code;
    const result = await env.auth.verifyCode({ email: 'T.e.s.t.u.s.e.r+other@gmail.com', code, deviceJwk: await device.publicJwk() });
    assert.equal(result.status, 'signed_in');
    assert.equal(env.store.users.size, 1);
});

test('wrong and reused codes fail, and lockout follows five misses', async () => {
    const env = setup();
    const device = await newDevice(env.clock);
    const jwk = await device.publicJwk();
    await env.auth.requestCode({ email: 'a@gmail.com' });
    const code = env.sent.at(-1).code;
    const wrong = code === '000000' ? '111111' : '000000';
    const miss = await env.auth.verifyCode({ email: 'a@gmail.com', code: wrong, deviceJwk: jwk });
    assert.deepEqual([miss.ok, miss.reason, miss.attemptsLeft], [false, 'invalid', 4]);
    for (let i = 0; i < 4; i++) await env.auth.verifyCode({ email: 'a@gmail.com', code: wrong, deviceJwk: jwk });
    assert.equal((await env.auth.verifyCode({ email: 'a@gmail.com', code, deviceJwk: jwk })).ok, false);
    const env2 = setup();
    await env2.auth.requestCode({ email: 'a@gmail.com' });
    const c2 = env2.sent.at(-1).code;
    assert.equal((await env2.auth.verifyCode({ email: 'a@gmail.com', code: c2, deviceJwk: jwk })).ok, true);
    assert.equal((await env2.auth.verifyCode({ email: 'a@gmail.com', code: c2, deviceJwk: jwk })).ok, false);
});

test('verify requires a valid device key before touching the code', async () => {
    const env = setup();
    await env.auth.requestCode({ email: 'a@gmail.com' });
    const code = env.sent.at(-1).code;
    assert.equal((await env.auth.verifyCode({ email: 'a@gmail.com', code, deviceJwk: { kty: 'EC' } })).reason, 'device_key');
    const device = await newDevice(env.clock);
    assert.equal((await env.auth.verifyCode({ email: 'a@gmail.com', code, deviceJwk: await device.publicJwk() })).ok, true);
});

test('signup validates ticket, username and age', async () => {
    const env = setup();
    const device = await newDevice(env.clock);
    const jwk = await device.publicJwk();
    await env.auth.requestCode({ email: 'a@gmail.com' });
    const verified = await env.auth.verifyCode({ email: 'a@gmail.com', code: env.sent.at(-1).code, deviceJwk: jwk });
    const base = { ticket: verified.ticket, username: 'valid_name', birthDate: '2000-01-01', deviceJwk: jwk };
    assert.equal((await env.auth.completeSignup({ ...base, ticket: 'x.y' })).reason, 'ticket');
    assert.equal((await env.auth.completeSignup({ ...base, ticket: verified.ticket.slice(0, -2) + 'aa' })).reason, 'ticket');
    assert.equal((await env.auth.completeSignup({ ...base, username: 'ab' })).reason, 'username_format');
    assert.equal((await env.auth.completeSignup({ ...base, username: 'admin' })).reason, 'username_reserved');
    assert.equal((await env.auth.completeSignup({ ...base, birthDate: '2020-01-01' })).reason, 'too_young');
    assert.equal((await env.auth.completeSignup({ ...base, birthDate: 'soon' })).reason, 'birth_format');
    assert.equal((await env.auth.completeSignup({ ...base, deviceJwk: {} })).reason, 'device_key');
    assert.equal((await env.auth.completeSignup(base)).ok, true);
    assert.equal((await env.auth.completeSignup(base)).reason, 'ticket');
});

test('usernames are unique and tickets expire', async () => {
    const env = setup();
    await signUp(env, 'a@gmail.com', 'taken_name');
    const device = await newDevice(env.clock);
    const jwk = await device.publicJwk();
    env.clock.t += 120000;
    await env.auth.requestCode({ email: 'b@gmail.com' });
    const verified = await env.auth.verifyCode({ email: 'b@gmail.com', code: env.sent.at(-1).code, deviceJwk: jwk });
    const clash = await env.auth.completeSignup({ ticket: verified.ticket, username: 'Taken_Name', birthDate: '2000-01-01', deviceJwk: jwk });
    assert.equal(clash.reason, 'username_taken');
    env.clock.t += 16 * 60 * 1000;
    const late = await env.auth.completeSignup({ ticket: verified.ticket, username: 'late_name', birthDate: '2000-01-01', deviceJwk: jwk });
    assert.equal(late.reason, 'ticket');
});

test('a stolen session token without the device key is useless', async () => {
    const env = setup();
    const session = await signUp(env);
    const attacker = await newDevice(env.clock);
    const proof = await attacker.sign('GET', '/api/me');
    const stolen = await env.auth.authenticate({ token: session.token, method: 'GET', path: '/api/me', proof });
    assert.deepEqual([stolen.ok, stolen.reason], [false, 'proof_invalid']);
    const noProof = await env.auth.authenticate({ token: session.token, method: 'GET', path: '/api/me', proof: undefined });
    assert.equal(noProof.reason, 'proof_missing');
    assert.equal((await env.auth.authenticate({ token: 'bogus', method: 'GET', path: '/api/me', proof })).reason, 'no_session');
});

test('sessions expire when idle and are removed on logout', async () => {
    const env = setup();
    const session = await signUp(env);
    const ok = await authed(env, session, 'GET', '/api/me');
    assert.equal(ok.ok, true);
    await env.auth.logout({ session: ok.session });
    assert.equal((await authed(env, session, 'GET', '/api/me')).reason, 'no_session');
    const env2 = setup();
    const s2 = await signUp(env2, 'z@gmail.com', 'zed_user');
    env2.clock.t += 8 * 24 * 60 * 60 * 1000;
    assert.equal((await authed(env2, s2, 'GET', '/api/me')).reason, 'no_session');
});

test('banned users cannot sign in or use sessions', async () => {
    const env = setup();
    const session = await signUp(env);
    env.store.users.set(session.user.id, { ...env.store.users.get(session.user.id), banned: true });
    assert.equal((await authed(env, session, 'GET', '/api/me')).reason, 'no_session');
    env.clock.t += 120000;
    const device = await newDevice(env.clock);
    await env.auth.requestCode({ email: 'testuser@gmail.com' });
    const r = await env.auth.verifyCode({ email: 'testuser@gmail.com', code: env.sent.at(-1).code, deviceJwk: await device.publicJwk() });
    assert.equal(r.reason, 'banned');
});

test('profile edits are cleaned and validated', async () => {
    const env = setup();
    const session = await signUp(env);
    const ok = await env.auth.updateProfile({ user: session.user, displayName: '  Le   Gateau \u0007 ', bio: 'Line one\r\n\r\n\r\n\r\nLine two' });
    assert.equal(ok.user.displayName, 'Le Gateau');
    assert.equal(ok.user.bio, 'Line one\n\nLine two');
    assert.equal((await env.auth.updateProfile({ user: session.user, displayName: '' })).reason, 'display_name');
    assert.equal((await env.auth.updateProfile({ user: session.user, bio: 'x'.repeat(281) })).reason, 'bio');
});

test('username changes enforce rules, uniqueness and a cooldown', async () => {
    const env = setup();
    const a = await signUp(env, 'a@gmail.com', 'first_user');
    env.clock.t += 120000;
    await signUp(env, 'b@gmail.com', 'second_user');
    const user = env.store.users.get(a.user.id);
    assert.equal((await env.auth.changeUsername({ user, username: 'second_user' })).reason, 'username_taken');
    assert.equal((await env.auth.changeUsername({ user, username: 'x' })).reason, 'username_format');
    const changed = await env.auth.changeUsername({ user, username: 'Renamed_One' });
    assert.equal(changed.user.username, 'renamed_one');
    const again = await env.auth.changeUsername({ user: changed.user, username: 'another_one' });
    assert.equal(again.reason, 'cooldown');
    assert.ok(again.retryAt);
    env.clock.t += USERNAME_COOLDOWN_MS + 1000;
    assert.equal((await env.auth.changeUsername({ user: changed.user, username: 'another_one' })).ok, true);
});

test('email change needs a code sent to the new address', async () => {
    const env = setup();
    const a = await signUp(env, 'a@gmail.com', 'first_user');
    env.clock.t += 120000;
    await signUp(env, 'b@gmail.com', 'second_user');
    const user = env.store.users.get(a.user.id);
    assert.equal((await env.auth.requestEmailChange({ user, newEmail: 'a@gmail.com' })).reason, 'same_email');
    assert.equal((await env.auth.requestEmailChange({ user, newEmail: 'b@gmail.com' })).reason, 'email_taken');
    assert.equal((await env.auth.requestEmailChange({ user, newEmail: 'x@example.org' })).reason, 'domain_not_allowed');
    env.clock.t += 120000;
    const req = await env.auth.requestEmailChange({ user, newEmail: 'New.Mail@outlook.com' });
    assert.equal(req.ok, true);
    const last = env.sent.at(-1);
    assert.deepEqual([last.to, last.purpose], ['new.mail@outlook.com', 'email_change']);
    const wrong = last.code === '000000' ? '111111' : '000000';
    assert.equal((await env.auth.confirmEmailChange({ user, newEmail: 'new.mail@outlook.com', code: wrong })).reason, 'invalid');
    const done = await env.auth.confirmEmailChange({ user, newEmail: 'new.mail@outlook.com', code: last.code });
    assert.equal(done.ok, true);
    assert.equal(done.user.email, 'new.mail@outlook.com');
});

test('a login code cannot confirm an email change', async () => {
    const env = setup();
    const a = await signUp(env, 'a@gmail.com', 'first_user');
    env.clock.t += 120000;
    await env.auth.requestCode({ email: 'c@gmail.com' });
    const loginCode = env.sent.at(-1).code;
    const result = await env.auth.confirmEmailChange({ user: env.store.users.get(a.user.id), newEmail: 'c@gmail.com', code: loginCode });
    assert.equal(result.ok, false);
});

test('user shapes hide private fields', () => {
    const user = { id: 'u1', email: 'a@gmail.com', emailDisplay: 'A@gmail.com', username: 'a_user', displayName: 'A', bio: '', badges: ['verified'], createdAt: new Date(0), birthDate: new Date('2000-01-01') };
    const pub = publicUser(user);
    assert.equal(pub.email, undefined);
    assert.equal(pub.birthDate, undefined);
    const me = selfUser(user, { admins: new Set(['a@gmail.com']), now: Date.UTC(2026, 10, 21) });
    assert.equal(me.isAdmin, true);
    assert.equal(me.isAdult, true);
    assert.equal(me.email, 'A@gmail.com');
});

test('ticket signing detects tampering and expiry', () => {
    const t = signTicket(SECRET, { canonical: 'a@gmail.com', address: 'a@gmail.com' }, 1000);
    assert.deepEqual(verifyTicket(SECRET, t, 2000), { canonical: 'a@gmail.com', address: 'a@gmail.com' });
    assert.equal(verifyTicket('other'.repeat(10), t, 2000), null);
    assert.equal(verifyTicket(SECRET, t, 1000 + 16 * 60 * 1000), null);
    assert.equal(verifyTicket(SECRET, 'a.b.c', 2000), null);
    assert.equal(verifyTicket(SECRET, undefined, 2000), null);
});

test('mailer picks Brevo or Resend and never throws', async () => {
    const calls = [];
    const ok = async (url, init) => { calls.push({ url, init }); return { ok: true, status: 200 }; };
    const brevo = createMailer({ env: { MAIL_FROM: 'VERO <veropol@proton.me>', BREVO_API_KEY: 'bk' }, fetchImpl: ok });
    assert.deepEqual(await brevo.sendCode('a@gmail.com', '123456', 'login'), { ok: true });
    assert.match(calls[0].url, /brevo/);
    assert.equal(JSON.parse(calls[0].init.body).sender.email, 'veropol@proton.me');
    const resend = createMailer({ env: { MAIL_FROM: 'veropol@proton.me', RESEND_API_KEY: 'rk' }, fetchImpl: ok });
    assert.equal((await resend.sendCode('a@gmail.com', '123456', 'login')).ok, true);
    assert.match(calls[1].url, /resend/);
    assert.equal((await createMailer({ env: {}, fetchImpl: ok }).sendCode('a@gmail.com', '1', 'login')).reason, 'not_configured');
    assert.equal((await createMailer({ env: { MAIL_FROM: 'bad' , RESEND_API_KEY: 'k' }, fetchImpl: ok }).sendCode('a@gmail.com', '1', 'login')).reason, 'not_configured');
    const failing = createMailer({ env: { MAIL_FROM: 'a@proton.me', RESEND_API_KEY: 'k' }, fetchImpl: async () => ({ ok: false, status: 403 }) });
    assert.equal((await failing.sendCode('a@gmail.com', '1', 'login')).reason, 'provider_403');
    const boom = createMailer({ env: { MAIL_FROM: 'a@proton.me', RESEND_API_KEY: 'k' }, fetchImpl: async () => { throw new Error('x'); } });
    assert.equal((await boom.sendCode('a@gmail.com', '1', 'login')).reason, 'request_failed');
    const msg = buildMessage('<b>1</b>', 'login');
    assert.ok(!msg.html.includes('<b>1</b>'));
});
