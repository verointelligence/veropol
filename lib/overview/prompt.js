export const SYSTEM_PROMPT = [
    'You are the analyst desk of VERO, an independent observatory for global affairs.',
    'You write short, original overviews of single news reports.',
    'Rules:',
    'Use only the material provided. Never add facts, names, numbers, dates, causes or quotations that are not in it.',
    'If the material is thin, write less instead of guessing.',
    'Do not reuse more than six consecutive words from the headline or snippet.',
    'Write plain, neutral, precise English.',
    'Attribute reported claims to the outlet, for example "BBC News reports" or "according to Reuters".',
    'No quotation marks, no markdown, no links, no emojis.',
    'The context field may use only the theater background supplied.',
    'Reply with one JSON object and nothing else.'
].join('\n');

export function buildMaterial({ report, theater, related }) {
    const lines = [];
    lines.push('Outlet: ' + report.source + (report.sourceRegion ? ' (' + report.sourceRegion + ')' : ''));
    if (report.publishedAt) lines.push('Published: ' + new Date(report.publishedAt).toISOString());
    lines.push('Headline: ' + report.title);
    if (report.description) lines.push('Snippet: ' + report.description);
    if (theater) lines.push('Theater background: ' + theater.title + '. ' + theater.desc);
    if (related && related.length) {
        lines.push('Other recent headlines from the same theater:');
        related.slice(0, 4).forEach(r => lines.push('- ' + r.title + ' (' + r.source + ')'));
    }
    const sourceText = [report.title, report.description, theater ? theater.title + ' ' + theater.desc : '', ...(related || []).slice(0, 4).map(r => r.title)].join(' ');
    return { prompt: lines.join('\n'), sourceText };
}

export function buildUserPrompt(material) {
    return [
        material.prompt,
        '',
        'Return a JSON object with exactly these keys:',
        'title: a clear English headline of at most 110 characters that restates the report in your own words',
        'summary: 2 or 3 sentences, at most 480 characters, saying what is reported and by whom',
        'context: 1 or 2 sentences, at most 560 characters, explaining why it matters using only the theater background',
        'keyPoints: an array of exactly 3 strings, each at most 150 characters: what is reported, who is involved, and what remains unconfirmed or open in the material'
    ].join('\n');
}
