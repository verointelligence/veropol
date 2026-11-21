'use client';

import { useEffect, useRef, useState } from 'react';
import { getDeviceKey, hasSessionMarker, publicPost } from '@/lib/client/api';
import { messageFor } from '@/lib/client/messages';

function safeNext(next) {
    return typeof next === 'string' && /^\/(?!\/)[\w\-./?=&%]{0,200}$/.test(next) ? next : '/account';
}

export default function LoginForm({ next }) {
    const [step, setStep] = useState('email');
    const [email, setEmail] = useState('');
    const [code, setCode] = useState('');
    const [username, setUsername] = useState('');
    const [birth, setBirth] = useState('');
    const [ticket, setTicket] = useState('');
    const [error, setError] = useState('');
    const [busy, setBusy] = useState(false);
    const [wait, setWait] = useState(0);
    const codeRef = useRef(null);

    useEffect(() => {
        if (hasSessionMarker()) window.location.replace(safeNext(next));
    }, [next]);

    useEffect(() => {
        if (wait <= 0) return undefined;
        const id = setTimeout(() => setWait(value => value - 1), 1000);
        return () => clearTimeout(id);
    }, [wait]);

    useEffect(() => {
        if (step === 'code' && codeRef.current) codeRef.current.focus();
    }, [step]);

    function go() {
        window.location.assign(safeNext(next));
    }

    async function sendCode(event) {
        if (event) event.preventDefault();
        if (busy) return;
        setBusy(true);
        setError('');
        const result = await publicPost('/api/auth/code', { email });
        setBusy(false);
        if (result.ok) {
            setStep('code');
            setCode('');
            setWait(60);
            return;
        }
        if (result.data && result.data.retryAfterSeconds) setWait(result.data.retryAfterSeconds);
        setError(messageFor(result.data));
    }

    async function verify(event) {
        event.preventDefault();
        if (busy) return;
        setBusy(true);
        setError('');
        try {
            const deviceJwk = await getDeviceKey().publicJwk();
            const result = await publicPost('/api/auth/verify', { email, code: code.trim(), deviceJwk });
            if (result.ok && result.data.status === 'signed_in') return go();
            if (result.ok && result.data.status === 'profile_required') {
                setTicket(result.data.ticket);
                setStep('profile');
            } else {
                setError(messageFor(result.data));
            }
        } catch {
            setError(messageFor({ reason: 'device_key' }));
        }
        setBusy(false);
    }

    async function complete(event) {
        event.preventDefault();
        if (busy) return;
        setBusy(true);
        setError('');
        try {
            const deviceJwk = await getDeviceKey().publicJwk();
            const result = await publicPost('/api/auth/complete', { ticket, username, birthDate: birth, deviceJwk });
            if (result.ok) return go();
            if (result.data && result.data.reason === 'ticket') setStep('email');
            setError(messageFor(result.data));
        } catch {
            setError(messageFor({ reason: 'device_key' }));
        }
        setBusy(false);
    }

    const today = new Date().toISOString().slice(0, 10);

    return (
        <div className="auth-page">
            <div className="auth-card">
                {step === 'email' ? (
                    <form onSubmit={sendCode} noValidate>
                        <h1>Sign in or create an account</h1>
                        <p className="auth-lead">Enter your email. We send a one-time code. No password needed.</p>
                        <label className="field">
                            <span>Email</span>
                            <input type="email" value={email} onChange={e => setEmail(e.target.value)} maxLength={254} autoComplete="email" inputMode="email" placeholder="you@gmail.com" required />
                        </label>
                        <p className="auth-hint">Supported: Gmail, Outlook, Proton, iCloud and Yahoo.</p>
                        {error ? <p className="auth-error" role="alert">{error}</p> : null}
                        <button className="btn-primary auth-submit" type="submit" disabled={busy || wait > 0}>{busy ? 'Sending...' : wait > 0 ? 'Wait ' + wait + 's' : 'Send code'}</button>
                    </form>
                ) : null}
                {step === 'code' ? (
                    <form onSubmit={verify} noValidate>
                        <h1>Enter your code</h1>
                        <p className="auth-lead">We sent a 6-digit code to <b>{email}</b>. It expires in 10 minutes.</p>
                        <label className="field">
                            <span>Code</span>
                            <input ref={codeRef} className="code-input" type="text" value={code} onChange={e => setCode(e.target.value.replace(/\D/g, '').slice(0, 6))} inputMode="numeric" autoComplete="one-time-code" maxLength={6} placeholder="000000" required />
                        </label>
                        {error ? <p className="auth-error" role="alert">{error}</p> : null}
                        <button className="btn-primary auth-submit" type="submit" disabled={busy || code.length !== 6}>{busy ? 'Checking...' : 'Continue'}</button>
                        <div className="auth-links">
                            <button type="button" className="link-btn" onClick={() => { setStep('email'); setError(''); }}>Change email</button>
                            <button type="button" className="link-btn" onClick={sendCode} disabled={busy || wait > 0}>{wait > 0 ? 'Resend in ' + wait + 's' : 'Resend code'}</button>
                        </div>
                    </form>
                ) : null}
                {step === 'profile' ? (
                    <form onSubmit={complete} noValidate>
                        <h1>Create your profile</h1>
                        <p className="auth-lead">Your email is verified. Choose a username to finish.</p>
                        <label className="field">
                            <span>Username</span>
                            <input type="text" value={username} onChange={e => setUsername(e.target.value.toLowerCase())} maxLength={20} autoComplete="username" autoCapitalize="none" spellCheck={false} placeholder="your_name" required />
                        </label>
                        <label className="field">
                            <span>Date of birth</span>
                            <input type="date" value={birth} onChange={e => setBirth(e.target.value)} max={today} min="1900-01-01" required />
                        </label>
                        <p className="auth-hint">By continuing you accept the <a href="/terms">Terms</a> and the <a href="/privacy">Privacy Policy</a>. You must be 13 or older. Your date of birth is never shown.</p>
                        {error ? <p className="auth-error" role="alert">{error}</p> : null}
                        <button className="btn-primary auth-submit" type="submit" disabled={busy || username.length < 3 || !birth}>{busy ? 'Creating...' : 'Create account'}</button>
                    </form>
                ) : null}
            </div>
        </div>
    );
}
