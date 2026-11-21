import createSearch from './search.cjs';
import translator from './translator.cjs';
import { matchSource } from './sources.cjs';
import coverFinder from './cover.cjs';

const KEY = Symbol.for('vero.news.engine');

function build() {
    const search = createSearch({ translator, matchSource });
    search.warm();
    return search;
}

export function getEngine() {
    if (!globalThis[KEY]) globalThis[KEY] = build();
    return globalThis[KEY];
}

export async function theatersWithCovers() {
    const engine = getEngine();
    const data = await engine.theaters();
    const theaters = { ...data.theaters };
    await Promise.all(Object.keys(theaters).map(async id => {
        const t = theaters[id];
        if (!t || !t.lead) return;
        const og = await Promise.race([engine.og(t.lead.url), new Promise(r => setTimeout(() => r(null), 2500))]).catch(() => null);
        if (og) {
            theaters[id] = { ...t, cover: { url: '/img?u=' + encodeURIComponent(og), page: t.lead.url, label: t.lead.source || '' } };
            return;
        }
        if (t.tag !== 'breaking') return;
        const found = await Promise.race([coverFinder.resolve(id, t.lead.title), new Promise(r => setTimeout(() => r(null), 1500))]).catch(() => null);
        if (found) theaters[id] = { ...t, cover: { url: found.url, page: found.page, label: [found.credit, found.license, 'Wikimedia Commons'].filter(Boolean).join(' · ') } };
    }));
    const developing = await Promise.all((data.developing || []).map(async card => {
        const og = await Promise.race([engine.og(card.lead.url), new Promise(r => setTimeout(() => r(null), 2500))]).catch(() => null);
        return og ? { ...card, cover: { url: '/img?u=' + encodeURIComponent(og), page: card.lead.url, label: card.lead.source || '' } } : card;
    }));
    return { theaters, developing, updatedAt: data.updatedAt };
}

export function theaterOf(title, description) {
    return createSearch.theaterOf(title, description);
}

export { matchSource };
