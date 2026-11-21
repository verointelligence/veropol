const SUBJECTS = {
    login: code => 'Your VERO code: ' + code,
    email_change: code => 'Confirm your new VERO email: ' + code
};

const INTROS = {
    login: 'Use this code to sign in to VERO.',
    email_change: 'Use this code to confirm this email address for your VERO account.'
};

function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, ch => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[ch]));
}

export function buildMessage(code, purpose) {
    const intro = INTROS[purpose] || INTROS.login;
    const subject = (SUBJECTS[purpose] || SUBJECTS.login)(code);
    const text = intro + '\n\n' + code + '\n\nThe code expires in 10 minutes. If you did not request it, ignore this email. VERO will never ask you for this code.';
    const html = '<div style="font-family:Arial,Helvetica,sans-serif;max-width:420px;margin:0 auto;padding:24px;color:#121214">'
        + '<p style="font-size:15px;margin:0 0 16px">' + escapeHtml(intro) + '</p>'
        + '<p style="font-size:34px;font-weight:700;letter-spacing:8px;margin:0 0 16px">' + escapeHtml(code) + '</p>'
        + '<p style="font-size:13px;color:#5E5A57;margin:0">The code expires in 10 minutes. If you did not request it, ignore this email. VERO will never ask you for this code.</p>'
        + '</div>';
    return { subject, text, html };
}

export function createMailer({ env = process.env, fetchImpl = fetch } = {}) {
    const from = String(env.MAIL_FROM || '').trim();
    const match = from.match(/^(?:(.*?)\s*)?<([^<>@\s]+@[^<>@\s]+)>$/) || from.match(/^()([^<>@\s]+@[^<>@\s]+)$/);
    const sender = match ? { name: (match[1] || 'VERO').replace(/^"|"$/g, '') || 'VERO', email: match[2] } : null;

    async function sendCode(to, code, purpose) {
        if (!sender) return { ok: false, reason: 'not_configured' };
        const message = buildMessage(code, purpose);
        try {
            let response;
            if (env.BREVO_API_KEY) {
                response = await fetchImpl('https://api.brevo.com/v3/smtp/email', {
                    method: 'POST',
                    headers: { 'api-key': env.BREVO_API_KEY, 'Content-Type': 'application/json', Accept: 'application/json' },
                    body: JSON.stringify({ sender, to: [{ email: to }], subject: message.subject, htmlContent: message.html, textContent: message.text }),
                    signal: AbortSignal.timeout(12000)
                });
            } else if (env.RESEND_API_KEY) {
                response = await fetchImpl('https://api.resend.com/emails', {
                    method: 'POST',
                    headers: { Authorization: 'Bearer ' + env.RESEND_API_KEY, 'Content-Type': 'application/json' },
                    body: JSON.stringify({ from: sender.name + ' <' + sender.email + '>', to: [to], subject: message.subject, html: message.html, text: message.text }),
                    signal: AbortSignal.timeout(12000)
                });
            } else {
                return { ok: false, reason: 'not_configured' };
            }
            return response.ok ? { ok: true } : { ok: false, reason: 'provider_' + response.status };
        } catch {
            return { ok: false, reason: 'request_failed' };
        }
    }

    return { sendCode };
}
