'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { apiFetch, hasSessionMarker } from '@/lib/client/api';
import { messageFor } from '@/lib/client/messages';
import { BADGES } from '@/content/badges';

function Notice({ state }) {
    if (!state || !state.text) return null;
    return <p className={state.ok ? 'auth-ok' : 'auth-error'} role={state.ok ? 'status' : 'alert'}>{state.text}</p>;
}

export default function AccountPanel() {
    const [me, setMe] = useState(null);
    const [loading, setLoading] = useState(true);
    const [displayName, setDisplayName] = useState('');
    const [bio, setBio] = useState('');
    const [username, setUsername] = useState('');
    const [newEmail, setNewEmail] = useState('');
    const [emailCode, setEmailCode] = useState('');
    const [emailStep, setEmailStep] = useState('idle');
    const [profileNote, setProfileNote] = useState(null);
    const [nameNote, setNameNote] = useState(null);
    const [emailNote, setEmailNote] = useState(null);
    const [busy, setBusy] = useState('');

    const adopt = useCallback(user => {
        setMe(user);
        setDisplayName(user.displayName);
        setBio(user.bio || '');
        setUsername(user.username);
    }, []);

    useEffect(() => {
        let cancelled = false;
        if (!hasSessionMarker()) {
            window.location.replace('/login?next=/account');
            return undefined;
        }
        apiFetch('/api/me')
            .then(result => {
                if (cancelled) return;
                if (result.ok && result.data && result.data.ok) {
                    adopt(result.data.user);
                    setLoading(false);
                } else {
                    window.location.replace('/login?next=/account');
                }
            })
            .catch(() => {
                if (!cancelled) window.location.replace('/login?next=/account');
            });
        return () => {
            cancelled = true;
        };
    }, [adopt]);

    async function saveProfile(event) {
        event.preventDefault();
        setBusy('profile');
        const result = await apiFetch('/api/me', { method: 'PATCH', body: { displayName, bio } });
        setBusy('');
        if (result.ok) {
            adopt(result.data.user);
            setProfileNote({ ok: true, text: 'Profile saved.' });
        } else {
            setProfileNote({ ok: false, text: messageFor(result.data) });
        }
    }

    async function saveUsername(event) {
        event.preventDefault();
        setBusy('username');
        const result = await apiFetch('/api/me/username', { method: 'POST', body: { username } });
        setBusy('');
        if (result.ok) {
            adopt(result.data.user);
            setNameNote({ ok: true, text: 'Username updated.' });
        } else {
            setNameNote({ ok: false, text: messageFor(result.data) });
        }
    }

    async function requestEmail(event) {
        event.preventDefault();
        setBusy('email');
        const result = await apiFetch('/api/me/email', { method: 'POST', body: { email: newEmail } });
        setBusy('');
        if (result.ok) {
            setEmailStep('code');
            setEmailNote({ ok: true, text: 'We sent a code to the new address.' });
        } else {
            setEmailNote({ ok: false, text: messageFor(result.data) });
        }
    }

    async function confirmEmail(event) {
        event.preventDefault();
        setBusy('email');
        const result = await apiFetch('/api/me/email/confirm', { method: 'POST', body: { email: newEmail, code: emailCode } });
        setBusy('');
        if (result.ok) {
            adopt(result.data.user);
            setEmailStep('idle');
            setNewEmail('');
            setEmailCode('');
            setEmailNote({ ok: true, text: 'Email updated.' });
        } else {
            setEmailNote({ ok: false, text: messageFor(result.data) });
        }
    }

    async function logout() {
        setBusy('logout');
        await apiFetch('/api/auth/logout', { method: 'POST', body: {} });
        window.location.assign('/');
    }

    if (loading || !me) {
        return <main className="account-page"><p className="auth-lead">Loading your account...</p></main>;
    }

    const lockedUntil = me.canChangeUsernameAt ? new Date(me.canChangeUsernameAt) : null;

    return (
        <main className="account-page">
            <header className="account-head">
                <div className="avatar-circle" aria-hidden="true">{me.displayName.slice(0, 1).toUpperCase()}</div>
                <div>
                    <h1>{me.displayName}</h1>
                    <p className="account-handle">@{me.username}</p>
                    <div className="badge-row">
                        {me.badges.filter(b => BADGES[b]).map(b => (
                            <span className="badge-chip" key={b}><i className={'ph ' + BADGES[b].icon} /> {BADGES[b].label}</span>
                        ))}
                    </div>
                </div>
                <div className="account-actions">
                    <Link href={'/u/' + me.username} className="btn-ghost"><i className="ph ph-user" /> <span>Public profile</span></Link>
                    <Link href="/articles/new" className="btn-primary"><i className="ph ph-pen-nib" /> <span>Write an article</span></Link>
                </div>
            </header>
            <div className="account-grid">
                <form className="account-card" onSubmit={saveProfile}>
                    <h2>Profile</h2>
                    <label className="field"><span>Display name</span><input type="text" value={displayName} onChange={e => setDisplayName(e.target.value)} maxLength={40} required /></label>
                    <label className="field"><span>Bio</span><textarea value={bio} onChange={e => setBio(e.target.value)} maxLength={280} rows={4} /></label>
                    <p className="auth-hint">{bio.length}/280</p>
                    <Notice state={profileNote} />
                    <button className="btn-primary" type="submit" disabled={busy === 'profile'}>{busy === 'profile' ? 'Saving...' : 'Save profile'}</button>
                </form>
                <form className="account-card" onSubmit={saveUsername}>
                    <h2>Username</h2>
                    <label className="field"><span>Username</span><input type="text" value={username} onChange={e => setUsername(e.target.value.toLowerCase())} maxLength={20} autoCapitalize="none" spellCheck={false} disabled={Boolean(lockedUntil)} required /></label>
                    <p className="auth-hint">{lockedUntil ? 'You can change it again on ' + lockedUntil.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }) + '.' : 'You can change your username once every 30 days.'}</p>
                    <Notice state={nameNote} />
                    <button className="btn-primary" type="submit" disabled={busy === 'username' || Boolean(lockedUntil) || username === me.username}>{busy === 'username' ? 'Saving...' : 'Change username'}</button>
                </form>
                <div className="account-card">
                    <h2>Email</h2>
                    <p className="auth-lead">Current email: <b>{me.email}</b></p>
                    {emailStep === 'idle' ? (
                        <form onSubmit={requestEmail}>
                            <label className="field"><span>New email</span><input type="email" value={newEmail} onChange={e => setNewEmail(e.target.value)} maxLength={254} autoComplete="email" placeholder="new@gmail.com" required /></label>
                            <Notice state={emailNote} />
                            <button className="btn-primary" type="submit" disabled={busy === 'email'}>{busy === 'email' ? 'Sending...' : 'Send confirmation code'}</button>
                        </form>
                    ) : (
                        <form onSubmit={confirmEmail}>
                            <label className="field"><span>Code sent to {newEmail}</span><input className="code-input" type="text" value={emailCode} onChange={e => setEmailCode(e.target.value.replace(/\D/g, '').slice(0, 6))} inputMode="numeric" maxLength={6} placeholder="000000" required /></label>
                            <Notice state={emailNote} />
                            <div className="auth-links">
                                <button className="btn-primary" type="submit" disabled={busy === 'email' || emailCode.length !== 6}>Confirm email</button>
                                <button type="button" className="link-btn" onClick={() => { setEmailStep('idle'); setEmailNote(null); }}>Cancel</button>
                            </div>
                        </form>
                    )}
                </div>
                <div className="account-card">
                    <h2>Session</h2>
                    <p className="auth-lead">This device is signed in. Signing out ends the session on this browser.</p>
                    <button className="btn-ghost" type="button" onClick={logout} disabled={busy === 'logout'}><i className="ph ph-sign-out" /> <span>Sign out</span></button>
                </div>
            </div>
        </main>
    );
}
