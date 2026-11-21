import crypto from 'node:crypto';
import { slugify } from './slugify.js';

export { slugify };

export function urlHash(url) {
    return crypto.createHash('sha256').update(String(url)).digest('hex').slice(0, 10);
}

export function reportSlug(title, url) {
    return (slugify(title) || 'report') + '-' + urlHash(url);
}

export function isReportSlug(value) {
    return typeof value === 'string' && value.length <= 100 && /^[a-z0-9]+(?:-[a-z0-9]+)*-[a-f0-9]{10}$/.test(value);
}
