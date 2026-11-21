import { checkEmail } from '../email-policy.mjs';
import { createOtpService } from '../otp.mjs';
import { createProofVerifier, createSession, hashToken, normalizeDeviceKey, sessionState } from '../device-session.mjs';
import { ADULT_AGE, USERNAME_COOLDOWN_MS, ageOn, cleanBio, cleanDisplayName, validateBirthDate, validateUsername } from './validators.js';
import { signTicket, verifyTicket } from './ticket.js';

const TOUCH_INTERVAL_MS = 5 * 60 * 1000;

export function publicUser(user) {
    return {
        username: user.username,
        displayName: user.displayName,
        bio: user.bio || '',
        badges: Array.isArray(user.badges) ? user.badges : [],
        createdAt: new Date(user.createdAt).toISOString()
    };
}

export function selfUser(user, { admins = new Set(), now = Date.now() } = {}) {
    const changedAt = user.usernameChangedAt ? new Date(user.usernameChangedAt).getTime() : 0;
    const next = changedAt ? changedAt + USERNAME_COOLDOWN_MS : 0;
    return {
        ...publicUser(user),
        email: user.emailDisplay,
        isAdmin: admins.has(user.email),
        isAdult: user.birthDate ? ageOn(new Date(user.birthDate), now) >= ADULT_AGE : false,
        canChangeUsernameAt: next > now ? new Date(next).toISOString() : null
    };
}

export function createAuthService({ store, mailer, secret, now = () => Date.now(), verifyProof }) {
    if (typeof secret !== 'string' || secret.length < 32) throw new Error('auth secret must be at least 32 characters');
    const otp = createOtpService({ secret, now });
    const proofCheck = verifyProof || createProofVerifier({ now });

    async function startSession(user, deviceJwk) {
        const created = createSession({ userId: user.id, deviceJwk, now: now() });
        if (!created) return null;
        await store.createSession(created.record);
        return created.token;
    }

    async function sendCode(address, canonical, purpose) {
        const key = purpose + ':' + canonical;
        const previous = await store.getCode(key);
        const issued = otp.issue(previous, canonical, purpose);
        if (!issued.ok) return { ok: false, reason: issued.reason, retryAfterMs: issued.retryAfterMs };
        await store.setCode(key, issued.record);
        const sent = await mailer.sendCode(address, issued.code, purpose);
        if (!sent.ok) {
            await store.setCode(key, previous);
            return { ok: false, reason: 'mail_failed' };
        }
        return { ok: true };
    }

    async function checkCode(canonical, purpose, code) {
        const key = purpose + ':' + canonical;
        const record = await store.getCode(key);
        const result = otp.verify(record, canonical, purpose, code);
        if (result.record && result.record !== record) await store.setCode(key, result.record);
        return result;
    }

    async function requestCode({ email }) {
        const checked = checkEmail(email);
        if (!checked.ok) return { ok: false, reason: checked.reason === 'domain_not_allowed' ? 'domain_not_allowed' : 'email_format' };
        return sendCode(checked.address, checked.canonical, 'login');
    }

    async function verifyCode({ email, code, deviceJwk }) {
        const checked = checkEmail(email);
        if (!checked.ok) return { ok: false, reason: 'email_format' };
        if (!normalizeDeviceKey(deviceJwk)) return { ok: false, reason: 'device_key' };
        const result = await checkCode(checked.canonical, 'login', code);
        if (!result.ok) return { ok: false, reason: result.reason, attemptsLeft: result.attemptsLeft };
        const user = await store.findUserByEmail(checked.canonical);
        if (!user) return { ok: true, status: 'profile_required', ticket: signTicket(secret, checked, now()) };
        if (user.banned) return { ok: false, reason: 'banned' };
        const token = await startSession(user, deviceJwk);
        if (!token) return { ok: false, reason: 'device_key' };
        return { ok: true, status: 'signed_in', token, user };
    }

    async function completeSignup({ ticket, username, birthDate, deviceJwk }) {
        const data = verifyTicket(secret, ticket, now());
        if (!data) return { ok: false, reason: 'ticket' };
        if (!normalizeDeviceKey(deviceJwk)) return { ok: false, reason: 'device_key' };
        const name = validateUsername(username);
        if (!name.ok) return { ok: false, reason: name.reason };
        const birth = validateBirthDate(birthDate, now());
        if (!birth.ok) return { ok: false, reason: birth.reason };
        if (await store.findUserByEmail(data.canonical)) return { ok: false, reason: 'ticket' };
        const created = await store.createUser({
            email: data.canonical,
            emailDisplay: data.address,
            username: name.value,
            displayName: name.value,
            bio: '',
            birthDate: birth.value,
            badges: ['email_verified'],
            createdAt: new Date(now())
        });
        if (!created.ok) return { ok: false, reason: created.reason === 'duplicate_username' ? 'username_taken' : 'ticket' };
        const token = await startSession(created.user, deviceJwk);
        if (!token) return { ok: false, reason: 'device_key' };
        return { ok: true, status: 'signed_in', token, user: created.user };
    }

    async function authenticate({ token, method, path, proof }) {
        if (typeof token !== 'string' || token.length < 20 || token.length > 100) return { ok: false, reason: 'no_session' };
        const idHash = hashToken(token);
        const session = await store.findSession(idHash);
        const state = sessionState(session, now());
        if (state !== 'ok') {
            if (session) await store.deleteSession(idHash);
            return { ok: false, reason: 'no_session' };
        }
        const checked = proofCheck({ method, path, record: session, proof });
        if (!checked.ok) return { ok: false, reason: checked.reason };
        const user = await store.findUserById(session.userId);
        if (!user || user.banned) {
            await store.deleteSession(idHash);
            return { ok: false, reason: 'no_session' };
        }
        if (now() - session.lastSeenAt > TOUCH_INTERVAL_MS) await store.touchSession(idHash, now());
        return { ok: true, user, session };
    }

    async function logout({ session }) {
        if (session) await store.deleteSession(session.idHash);
        return { ok: true };
    }

    async function updateProfile({ user, displayName, bio }) {
        const patch = {};
        if (displayName !== undefined) {
            const name = cleanDisplayName(displayName);
            if (!name.ok) return { ok: false, reason: name.reason };
            patch.displayName = name.value;
        }
        if (bio !== undefined) {
            const text = cleanBio(bio);
            if (!text.ok) return { ok: false, reason: text.reason };
            patch.bio = text.value;
        }
        if (!Object.keys(patch).length) return { ok: true, user };
        const updated = await store.updateUser(user.id, patch);
        return updated.ok ? { ok: true, user: updated.user } : { ok: false, reason: 'update_failed' };
    }

    async function changeUsername({ user, username }) {
        const name = validateUsername(username);
        if (!name.ok) return { ok: false, reason: name.reason };
        if (name.value === user.username) return { ok: true, user };
        const last = user.usernameChangedAt ? new Date(user.usernameChangedAt).getTime() : 0;
        if (last && now() - last < USERNAME_COOLDOWN_MS) {
            return { ok: false, reason: 'cooldown', retryAt: new Date(last + USERNAME_COOLDOWN_MS).toISOString() };
        }
        const updated = await store.updateUser(user.id, { username: name.value, usernameChangedAt: new Date(now()) });
        if (!updated.ok) return { ok: false, reason: updated.reason === 'duplicate_username' ? 'username_taken' : 'update_failed' };
        return { ok: true, user: updated.user };
    }

    async function requestEmailChange({ user, newEmail }) {
        const checked = checkEmail(newEmail);
        if (!checked.ok) return { ok: false, reason: checked.reason === 'domain_not_allowed' ? 'domain_not_allowed' : 'email_format' };
        if (checked.canonical === user.email) return { ok: false, reason: 'same_email' };
        if (await store.findUserByEmail(checked.canonical)) return { ok: false, reason: 'email_taken' };
        return sendCode(checked.address, checked.canonical, 'email_change');
    }

    async function confirmEmailChange({ user, newEmail, code }) {
        const checked = checkEmail(newEmail);
        if (!checked.ok) return { ok: false, reason: 'email_format' };
        const result = await checkCode(checked.canonical, 'email_change', code);
        if (!result.ok) return { ok: false, reason: result.reason, attemptsLeft: result.attemptsLeft };
        const taken = await store.findUserByEmail(checked.canonical);
        if (taken && taken.id !== user.id) return { ok: false, reason: 'email_taken' };
        const updated = await store.updateUser(user.id, { email: checked.canonical, emailDisplay: checked.address });
        if (!updated.ok) return { ok: false, reason: updated.reason === 'duplicate_email' ? 'email_taken' : 'update_failed' };
        return { ok: true, user: updated.user };
    }

    return { requestCode, verifyCode, completeSignup, authenticate, logout, updateProfile, changeUsername, requestEmailChange, confirmEmailChange };
}
