const TRUSTED_SOURCES = [
    { name: 'Al Jazeera', domains: ['aljazeera.com', 'aljazeera.net'], region: 'Qatar' },
    { name: 'Al Arabiya', domains: ['alarabiya.net'], region: 'Saudi Arabia / UAE' },
    { name: 'Al-Monitor', domains: ['al-monitor.com'], region: 'United States' },
    { name: 'Anadolu Agency', domains: ['aa.com.tr'], region: 'Türkiye' },
    { name: 'Reuters', domains: ['reuters.com'], region: 'United Kingdom' },
    { name: 'Associated Press', domains: ['apnews.com'], region: 'United States' },
    { name: 'BBC News', domains: ['bbc.com', 'bbc.co.uk'], region: 'United Kingdom' },
    { name: 'The Guardian', domains: ['theguardian.com'], region: 'United Kingdom' },
    { name: 'France 24', domains: ['france24.com'], region: 'France' },
    { name: 'Le Monde', domains: ['lemonde.fr'], region: 'France' },
    { name: 'Deutsche Welle', domains: ['dw.com'], region: 'Germany' },
    { name: 'Euronews', domains: ['euronews.com'], region: 'European Union' },
    { name: 'El País', domains: ['elpais.com'], region: 'Spain' },
    { name: 'SWI swissinfo.ch', domains: ['swissinfo.ch'], region: 'Switzerland' },
    { name: 'UN News', domains: ['news.un.org', 'un.org'], region: 'United Nations' },
    { name: 'NPR', domains: ['npr.org'], region: 'United States' },
    { name: 'PBS NewsHour', domains: ['pbs.org'], region: 'United States' },
    { name: 'The Christian Science Monitor', domains: ['csmonitor.com'], region: 'United States' }
];

function matchSource(url) {
    let host = '';
    try { host = new URL(url).hostname.replace(/^www\./, '').toLowerCase(); } catch (e) { return null; }
    for (const s of TRUSTED_SOURCES) {
        if (s.domains.some(d => host === d || host.endsWith('.' + d))) return s;
    }
    return null;
}

module.exports = { TRUSTED_SOURCES, matchSource };
