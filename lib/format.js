export const CATEGORIES = {
    military: { label: 'Military', icon: 'ph-crosshair' },
    economy: { label: 'Economy', icon: 'ph-chart-line-up' },
    diplomacy: { label: 'Diplomacy', icon: 'ph-handshake' },
    energy: { label: 'Energy', icon: 'ph-gas-pump' },
    humanitarian: { label: 'Humanitarian', icon: 'ph-first-aid-kit' },
    security: { label: 'Security', icon: 'ph-shield-warning' },
    cyber: { label: 'Cyber & Tech', icon: 'ph-cpu' },
    middleeast: { label: 'Middle East', icon: 'ph-mosque' },
    europe: { label: 'Europe', icon: 'ph-castle-turret' },
    asia: { label: 'Asia-Pacific', icon: 'ph-buildings' },
    africa: { label: 'Africa', icon: 'ph-compass' },
    americas: { label: 'Americas', icon: 'ph-flag' },
    opinion: { label: 'Opinion', icon: 'ph-chat-centered-text' },
    intel: { label: 'Global', icon: 'ph-globe' }
};

export const TOPIC_KEYS = ['diplomacy', 'military', 'economy', 'energy', 'humanitarian', 'security', 'cyber'];
export const REGION_KEYS = ['middleeast', 'europe', 'asia', 'africa', 'americas'];
export const RANGES = [
    { key: 'all', label: 'Any time' },
    { key: '24h', label: '24h' },
    { key: '7d', label: '7 days' },
    { key: '30d', label: '30 days' }
];

export function timeAgo(value, now = Date.now()) {
    const t = new Date(value).getTime();
    if (Number.isNaN(t)) return '';
    const minutes = Math.max(0, Math.round((now - t) / 60000));
    if (minutes < 1) return 'just now';
    if (minutes < 60) return minutes + (minutes === 1 ? ' minute ago' : ' minutes ago');
    const hours = Math.round(minutes / 60);
    if (hours < 24) return hours + (hours === 1 ? ' hour ago' : ' hours ago');
    const days = Math.round(hours / 24);
    return days + (days === 1 ? ' day ago' : ' days ago');
}

export function formatDate(value) {
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return '';
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric', timeZone: 'UTC' });
}

export function clip(text, max) {
    const s = String(text || '').replace(/\s+/g, ' ').trim();
    if (s.length <= max) return s;
    return s.slice(0, max).replace(/\s+\S*$/, '') + '\u2026';
}

export function proxied(url) {
    return '/img?u=' + encodeURIComponent(url);
}

export function validCover(img) {
    if (typeof img !== 'string' || !/^https?:\/\//.test(img)) return false;
    const low = img.toLowerCase();
    return !['generic', 'business', 'placeholder', 'logo', 'avatar', 'default', 'icon', 'stock'].some(k => low.includes(k));
}

export function jsonLd(data) {
    return JSON.stringify(data).replace(/</g, '\\u003c');
}
