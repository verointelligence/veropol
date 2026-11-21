import crypto from 'node:crypto';

export function urlHash(url) {
    return crypto.createHash('sha256').update(String(url)).digest('hex').slice(0, 10);
}

export function slugify(text, max = 60) {
    const base = String(text || '')
        .normalize('NFKD')
        .replace(/[\u0300-\u036f]/g, '')
        .toLowerCase()
        .replace(/&/g, ' and ')
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');
    if (base.length <= max) return base;
    const cut = base.slice(0, max);
    const at = cut.lastIndexOf('-');
    return (at > 20 ? cut.slice(0, at) : cut).replace(/-+$/g, '');
}

export function reportSlug(title, url) {
    return (slugify(title) || 'report') + '-' + urlHash(url);
}

export function isReportSlug(value) {
    return typeof value === 'string' && value.length <= 100 && /^[a-z0-9]+(?:-[a-z0-9]+)*-[a-f0-9]{10}$/.test(value);
}
