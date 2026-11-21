'use client';

import { useEffect, useState } from 'react';
import { apiFetch, hasSessionMarker } from '@/lib/client/api';
import { messageFor } from '@/lib/client/messages';
import { ARTICLE_CATEGORIES } from '@/lib/articles-core';
import { CATEGORIES } from '@/lib/format';

export default function ArticleEditor({ mode = 'new', slug = '', authorUsername = '', initial }) {
    const [title, setTitle] = useState(initial ? initial.title : '');
    const [category, setCategory] = useState(initial ? initial.category : 'opinion');
    const [summary, setSummary] = useState(initial ? initial.summary : '');
    const [body, setBody] = useState(initial ? initial.body : '');
    const [error, setError] = useState('');
    const [busy, setBusy] = useState(false);
    const [allowed, setAllowed] = useState(null);

    const nextPath = mode === 'edit' ? '/articles/' + slug + '/edit' : '/articles/new';

    useEffect(() => {
        let cancelled = false;
        if (!hasSessionMarker()) {
            window.location.replace('/login?next=' + encodeURIComponent(nextPath));
            return undefined;
        }
        apiFetch('/api/me')
            .then(result => {
                if (cancelled) return;
                if (!result.ok || !result.data || !result.data.ok) {
                    window.location.replace('/login?next=' + encodeURIComponent(nextPath));
                    return;
                }
                const user = result.data.user;
                if (!user.isAdult) setAllowed('adult');
                else if (mode === 'edit' && user.username !== authorUsername && !user.isAdmin) setAllowed('owner');
                else setAllowed('yes');
            })
            .catch(() => {
                if (!cancelled) window.location.replace('/login?next=' + encodeURIComponent(nextPath));
            });
        return () => {
            cancelled = true;
        };
    }, [mode, authorUsername, nextPath]);

    async function submit(event) {
        event.preventDefault();
        if (busy) return;
        setBusy(true);
        setError('');
        const payload = { title, category, summary, body };
        const result = mode === 'edit'
            ? await apiFetch('/api/articles/' + slug, { method: 'PATCH', body: payload })
            : await apiFetch('/api/articles', { method: 'POST', body: payload });
        if (result.ok && result.data && result.data.slug) {
            window.location.assign('/articles/' + result.data.slug);
            return;
        }
        setBusy(false);
        setError(messageFor(result.data));
    }

    if (allowed === null) return <main className="editor-page"><p className="auth-lead">Loading...</p></main>;
    if (allowed === 'adult') return <main className="editor-page"><p className="auth-error">Publishing is limited to users aged 18 or older.</p></main>;
    if (allowed === 'owner') return <main className="editor-page"><p className="auth-error">You can only edit your own articles.</p></main>;

    return (
        <main className="editor-page">
            <h1>{mode === 'edit' ? 'Edit article' : 'Write an article'}</h1>
            <p className="auth-lead">Articles are published immediately under your name. Keep them accurate and respectful.</p>
            <form className="editor-form" onSubmit={submit} noValidate>
                <label className="field"><span>Title</span><input type="text" value={title} onChange={e => setTitle(e.target.value)} maxLength={140} required /></label>
                <label className="field">
                    <span>Category</span>
                    <select value={category} onChange={e => setCategory(e.target.value)}>
                        {ARTICLE_CATEGORIES.map(key => <option key={key} value={key}>{CATEGORIES[key].label}</option>)}
                    </select>
                </label>
                <label className="field"><span>Summary</span><textarea value={summary} onChange={e => setSummary(e.target.value)} maxLength={300} rows={3} required /></label>
                <p className="auth-hint">{summary.length}/300</p>
                <label className="field"><span>Article</span><textarea className="editor-body" value={body} onChange={e => setBody(e.target.value)} maxLength={30000} rows={18} required /></label>
                <p className="auth-hint">{body.length}/30,000. Use a blank line between paragraphs, a line starting with ## for a heading and lines starting with - for a list. At most 3 links.</p>
                {error ? <p className="auth-error" role="alert">{error}</p> : null}
                <div className="auth-links">
                    <button className="btn-primary" type="submit" disabled={busy}>{busy ? 'Publishing...' : mode === 'edit' ? 'Save changes' : 'Publish'}</button>
                    <a className="link-btn" href={mode === 'edit' ? '/articles/' + slug : '/articles'}>Cancel</a>
                </div>
            </form>
        </main>
    );
}
