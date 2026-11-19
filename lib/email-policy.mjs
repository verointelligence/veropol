const FAMILIES = [
    { id: 'google', domains: ['gmail.com', 'googlemail.com'], canonicalDomain: 'gmail.com', stripDots: true, stripPlus: true },
    { id: 'microsoft', domains: ['outlook.com', 'hotmail.com', 'live.com', 'msn.com'], stripDots: false, stripPlus: true },
    { id: 'proton', domains: ['proton.me', 'protonmail.com', 'pm.me'], canonicalDomain: 'proton.me', stripDots: false, stripPlus: true },
    { id: 'icloud', domains: ['icloud.com', 'me.com'], stripDots: false, stripPlus: true },
    { id: 'yahoo', domains: ['yahoo.com'], stripDots: false, stripPlus: false }
];

const DOMAIN_INDEX = new Map();
FAMILIES.forEach(f => f.domains.forEach(d => DOMAIN_INDEX.set(d, f)));

const LOCAL_RE = /^[a-z0-9](?:[a-z0-9._+-]*[a-z0-9])?$/;

export const ALLOWED_DOMAINS = Object.freeze([...DOMAIN_INDEX.keys()]);

export function checkEmail(input) {
    if (typeof input !== 'string') return { ok: false, reason: 'format' };
    const raw = input.trim().toLowerCase();
    if (raw.length < 6 || raw.length > 254) return { ok: false, reason: 'format' };
    const at = raw.lastIndexOf('@');
    if (at < 1 || at !== raw.indexOf('@')) return { ok: false, reason: 'format' };
    const local = raw.slice(0, at);
    const domain = raw.slice(at + 1);
    if (local.length > 64 || !LOCAL_RE.test(local) || local.includes('..')) return { ok: false, reason: 'format' };
    const family = DOMAIN_INDEX.get(domain);
    if (!family) return { ok: false, reason: 'domain_not_allowed' };
    let base = local;
    if (family.stripPlus) base = base.split('+')[0];
    if (family.stripDots) base = base.replace(/\./g, '');
    if (!base || !/^[a-z0-9]/.test(base)) return { ok: false, reason: 'format' };
    const canonicalDomain = family.canonicalDomain || domain;
    return {
        ok: true,
        address: raw,
        canonical: base + '@' + canonicalDomain,
        family: family.id
    };
}
