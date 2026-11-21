export const LIMITS = { title: 110, summary: 480, context: 560, point: 150, points: 3 };

export function extractJson(text) {
    const raw = String(text || '').replace(/```json|```/gi, '').trim();
    const start = raw.indexOf('{');
    const end = raw.lastIndexOf('}');
    if (start === -1 || end <= start) return null;
    try {
        return JSON.parse(raw.slice(start, end + 1));
    } catch {
        return null;
    }
}

function words(text) {
    return String(text || '').toLowerCase().replace(/[^\p{L}\p{N}\s]/gu, ' ').split(/\s+/).filter(Boolean);
}

function shingles(list, size) {
    const out = new Set();
    for (let i = 0; i + size <= list.length; i++) out.add(list.slice(i, i + size).join(' '));
    return out;
}

function clean(value) {
    return typeof value === 'string' ? value.replace(/\s+/g, ' ').trim() : '';
}

function hasForbidden(text) {
    return /https?:|www\.|<|>|\*\*|^#|["\u201c\u201d\u00ab\u00bb]/m.test(text);
}

function mostlyEnglish(text) {
    const letters = text.match(/\p{L}/gu) || [];
    if (!letters.length) return false;
    const ascii = letters.filter(ch => /[A-Za-z]/.test(ch)).length;
    return ascii / letters.length >= 0.95;
}

export function validateOverview(raw, sourceText) {
    if (!raw || typeof raw !== 'object') return { ok: false, reason: 'not_object' };
    const title = clean(raw.title);
    const summary = clean(raw.summary);
    const context = clean(raw.context);
    const points = Array.isArray(raw.keyPoints) ? raw.keyPoints.map(clean).filter(Boolean) : [];
    if (!title || !summary || !context) return { ok: false, reason: 'missing_field' };
    if (points.length !== LIMITS.points) return { ok: false, reason: 'key_points_count' };
    if (title.length > LIMITS.title || summary.length > LIMITS.summary || context.length > LIMITS.context || points.some(p => p.length > LIMITS.point)) {
        return { ok: false, reason: 'too_long' };
    }
    if (title.length < 20 || summary.length < 80 || context.length < 40 || points.some(p => p.length < 15)) return { ok: false, reason: 'too_short' };
    const all = [title, summary, context, ...points];
    if (all.some(hasForbidden)) return { ok: false, reason: 'forbidden_content' };
    if (!all.every(mostlyEnglish)) return { ok: false, reason: 'not_english' };
    const sourceLower = String(sourceText || '').toLowerCase();
    const numbers = all.join(' ').match(/\d[\d,.]*/g) || [];
    for (const n of numbers) {
        const bare = n.replace(/[.,]+$/g, '');
        if (bare && !sourceLower.includes(bare.toLowerCase())) return { ok: false, reason: 'unsupported_number' };
    }
    const src = shingles(words(sourceText), 8);
    const out = shingles(words([summary, context, ...points].join(' ')), 8);
    for (const s of out) if (src.has(s)) return { ok: false, reason: 'copied_text' };
    return { ok: true, value: { title, summary, context, keyPoints: points } };
}
