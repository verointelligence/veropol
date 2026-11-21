import { slugify } from './slugify.js';

export const ARTICLE_CATEGORIES = ['opinion', 'diplomacy', 'military', 'economy', 'energy', 'humanitarian', 'security', 'cyber'];
export const LIMITS = { title: [12, 140], summary: [40, 300], body: [400, 30000], links: 3 };
export const DAILY_LIMIT = 5;

function clean(value) {
    return typeof value === 'string' ? value.replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f\u200b-\u200f\u202a-\u202e\u2066-\u2069]/g, '') : '';
}

export function countLinks(text) {
    return (String(text || '').match(/https?:\/\/|www\./gi) || []).length;
}

function repetitive(text) {
    if (/(.)\1{14,}/.test(text)) return true;
    const words = text.toLowerCase().split(/\s+/).filter(Boolean);
    const seen = new Map();
    for (let i = 0; i + 3 <= words.length; i++) {
        const key = words[i] + ' ' + words[i + 1] + ' ' + words[i + 2];
        const n = (seen.get(key) || 0) + 1;
        if (n >= 12) return true;
        seen.set(key, n);
    }
    return false;
}

export function validateArticle(input) {
    const data = input && typeof input === 'object' ? input : {};
    const title = clean(data.title).replace(/\s+/g, ' ').trim();
    const summary = clean(data.summary).replace(/\s+/g, ' ').trim();
    const body = clean(data.body).replace(/\r\n?/g, '\n').replace(/[ \t]+/g, ' ').replace(/\n{3,}/g, '\n\n').trim();
    const category = typeof data.category === 'string' ? data.category : '';
    if (title.length < LIMITS.title[0] || title.length > LIMITS.title[1]) return { ok: false, reason: 'title' };
    if (summary.length < LIMITS.summary[0] || summary.length > LIMITS.summary[1]) return { ok: false, reason: 'summary' };
    if (body.length < LIMITS.body[0] || body.length > LIMITS.body[1]) return { ok: false, reason: 'body' };
    if (!ARTICLE_CATEGORIES.includes(category)) return { ok: false, reason: 'category' };
    if (countLinks(title) || countLinks(summary)) return { ok: false, reason: 'links' };
    if (countLinks(body) > LIMITS.links) return { ok: false, reason: 'links' };
    if (repetitive(title + ' ' + summary + ' ' + body)) return { ok: false, reason: 'spam' };
    return { ok: true, value: { title, summary, body, category } };
}

export function articleSlug(title, suffix) {
    return (slugify(title, 70) || 'article') + '-' + suffix;
}

export function isArticleSlug(value) {
    return typeof value === 'string' && value.length <= 90 && /^[a-z0-9]+(?:-[a-z0-9]+)*-[a-f0-9]{6}$/.test(value);
}

export function parseBody(text) {
    const blocks = [];
    String(text || '').split(/\n{2,}/).forEach(chunk => {
        const lines = chunk.split('\n').map(l => l.trim()).filter(Boolean);
        if (!lines.length) return;
        if (lines.length === 1 && /^##\s+/.test(lines[0])) {
            blocks.push({ type: 'h2', text: lines[0].replace(/^##\s+/, '').slice(0, 140) });
        } else if (lines.every(l => /^[-*]\s+/.test(l))) {
            blocks.push({ type: 'ul', items: lines.map(l => l.replace(/^[-*]\s+/, '')) });
        } else {
            blocks.push({ type: 'p', text: lines.join(' ') });
        }
    });
    return blocks;
}

export function readingMinutes(text) {
    const words = String(text || '').trim().split(/\s+/).filter(Boolean).length;
    return Math.max(1, Math.round(words / 220));
}
