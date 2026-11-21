import test from 'node:test';
import assert from 'node:assert/strict';
import { slugify, reportSlug, isReportSlug } from '../lib/slug.js';
import { createLimiter, clientIp } from '../lib/rate-limit.js';
import { extractJson, validateOverview } from '../lib/overview/validate.js';
import { overviewConfig, generateOverview } from '../lib/overview/generate.js';
import { buildMaterial } from '../lib/overview/prompt.js';

const report = {
    source: 'BBC News',
    sourceRegion: 'United Kingdom',
    title: 'Ukrainian military hit the Crimean bridge during a Russian attack on the Dnieper',
    description: 'Ten people were injured when the bridge was struck, regional officials said.',
    publishedAt: '2026-11-19T10:00:00.000Z'
};
const theater = { title: 'Russo-Ukrainian Conflict', desc: 'Frontline monitoring, territory changes, and tactical air/artillery activity.' };
const material = buildMaterial({ report, theater, related: [{ title: 'Kyiv reports overnight drone attacks', source: 'Reuters' }] });

const good = {
    title: 'Crimean bridge struck as Ukraine and Russia trade attacks near the Dnieper',
    summary: 'BBC News reports that Ukrainian forces struck the Crimean bridge while Russia attacked positions along the Dnieper. Regional officials said ten people were injured in the incident.',
    context: 'The Russo-Ukrainian Conflict is tracked through frontline monitoring and territory changes, so strikes on key crossings matter for tactical conditions.',
    keyPoints: [
        'BBC News reports a strike on the Crimean bridge.',
        'Ukrainian and Russian forces are both named as acting.',
        'The cause and full extent of damage are not stated.'
    ]
};

test('slug helpers build stable, safe slugs', () => {
    assert.equal(slugify('Ukraine: Kyiv hit by drones & missiles!'), 'ukraine-kyiv-hit-by-drones-and-missiles');
    assert.equal(slugify('\u0623\u062e\u0628\u0627\u0631 \u0639\u0627\u062c\u0644\u0629'), '');
    const slug = reportSlug('Hello World', 'https://example.com/a');
    assert.match(slug, /^hello-world-[a-f0-9]{10}$/);
    assert.equal(slug, reportSlug('Hello World', 'https://example.com/a'));
    assert.notEqual(slug, reportSlug('Hello World', 'https://example.com/b'));
    assert.match(reportSlug('\u0623\u062e\u0628\u0627\u0631', 'https://example.com/a'), /^report-[a-f0-9]{10}$/);
    assert.ok(slugify('a'.repeat(200)).length <= 60);
    assert.equal(isReportSlug(slug), true);
    for (const bad of ['', '../etc', 'abc', 'Hello-World-aaaaaaaaaa', 'x-aaaaaaaaaaa', 'x-gggggggggg', 'a'.repeat(120) + '-aaaaaaaaaa', null, 5]) {
        assert.equal(isReportSlug(bad), false);
    }
});

test('limiter blocks after the limit and recovers', () => {
    const limiter = createLimiter({ limit: 3, windowMs: 1000 });
    assert.equal(limiter.check('a', 0).ok, true);
    assert.equal(limiter.check('a', 10).ok, true);
    assert.equal(limiter.check('a', 20).ok, true);
    const blocked = limiter.check('a', 30);
    assert.equal(blocked.ok, false);
    assert.ok(blocked.retryAfter >= 1);
    assert.equal(limiter.check('b', 30).ok, true);
    assert.equal(limiter.check('a', 1100).ok, true);
});

test('client ip takes the first forwarded address', () => {
    const headers = new Headers({ 'x-forwarded-for': '1.2.3.4, 5.6.7.8' });
    assert.equal(clientIp(headers), '1.2.3.4');
    assert.equal(clientIp(new Headers()), 'unknown');
});

test('overview validation accepts a grounded overview', () => {
    const result = validateOverview(good, material.sourceText);
    assert.equal(result.ok, true);
    assert.equal(result.value.keyPoints.length, 3);
});

test('overview validation rejects unsafe or ungrounded output', () => {
    const cases = [
        [{ ...good, summary: good.summary + ' See https://example.com' }, 'forbidden_content'],
        [{ ...good, summary: good.summary.replace('struck', '"struck"') }, 'forbidden_content'],
        [{ ...good, summary: good.summary + ' About 12 people were hurt.' }, 'unsupported_number'],
        [{ ...good, keyPoints: good.keyPoints.slice(0, 2) }, 'key_points_count'],
        [{ ...good, title: 'x'.repeat(200) }, 'too_long'],
        [{ ...good, title: 'Short' }, 'too_short'],
        [{ ...good, summary: ('\u0645\u0644\u062e\u0635 \u0639\u0631\u0628\u064a \u0637\u0648\u064a\u0644 \u062c\u062f\u0627 \u064a\u062d\u062a\u0648\u064a \u0639\u0644\u0649 \u0627\u0644\u0643\u062b\u064a\u0631 \u0645\u0646 \u0627\u0644\u0643\u0644\u0645\u0627\u062a \u0627\u0644\u0639\u0631\u0628\u064a\u0629 \u0647\u0646\u0627 \u0644\u0627\u062e\u062a\u0628\u0627\u0631 \u0627\u0644\u0644\u063a\u0629 ').repeat(3) }, 'not_english'],
        [{ ...good, summary: 'Ten people were injured when the bridge was struck, regional officials said, according to the report.' }, 'copied_text'],
        [null, 'not_object'],
        [{ ...good, context: '' }, 'missing_field']
    ];
    for (const [input, reason] of cases) {
        const result = validateOverview(input, material.sourceText);
        assert.equal(result.ok, false, reason);
        assert.equal(result.reason, reason);
    }
});

test('extractJson tolerates fences and surrounding text', () => {
    assert.deepEqual(extractJson('```json\n{"a":1}\n```'), { a: 1 });
    assert.deepEqual(extractJson('Here you go: {"a":2} thanks'), { a: 2 });
    assert.equal(extractJson('no json'), null);
    assert.equal(extractJson('{broken'), null);
});

test('overview config requires https and all variables', () => {
    assert.equal(overviewConfig({}), null);
    assert.equal(overviewConfig({ LLM_BASE_URL: 'http://x.test', LLM_API_KEY: 'k', LLM_MODEL: 'm' }), null);
    const config = overviewConfig({ LLM_BASE_URL: 'https://x.test/v1/', LLM_API_KEY: 'k', LLM_MODEL: 'm', OVERVIEW_DAILY_LIMIT: '40' });
    assert.equal(config.baseUrl, 'https://x.test/v1');
    assert.equal(config.dailyLimit, 40);
    assert.equal(overviewConfig({ LLM_BASE_URL: 'https://x.test', LLM_API_KEY: 'k', LLM_MODEL: 'm', OVERVIEW_DAILY_LIMIT: 'abc' }).dailyLimit, 150);
});

function fakeFetch(replies) {
    const calls = [];
    const impl = async (url, init) => {
        calls.push({ url, body: JSON.parse(init.body) });
        const next = replies.shift();
        if (next.status && next.status !== 200) return { ok: false, status: next.status, json: async () => ({}) };
        return { ok: true, status: 200, json: async () => ({ choices: [{ message: { content: next.content } }] }) };
    };
    impl.calls = calls;
    return impl;
}

const config = { baseUrl: 'https://x.test/v1', apiKey: 'k', model: 'm', dailyLimit: 10 };

test('generation returns a validated overview', async () => {
    const f = fakeFetch([{ content: JSON.stringify(good) }]);
    const result = await generateOverview(material, config, f);
    assert.equal(result.ok, true);
    assert.equal(f.calls.length, 1);
    assert.equal(f.calls[0].url, 'https://x.test/v1/chat/completions');
    assert.equal(f.calls[0].body.messages[0].role, 'system');
});

test('generation retries once after a rejected answer', async () => {
    const f = fakeFetch([{ content: JSON.stringify({ ...good, summary: good.summary + ' See https://example.com' }) }, { content: JSON.stringify(good) }]);
    const result = await generateOverview(material, config, f);
    assert.equal(result.ok, true);
    assert.equal(f.calls.length, 2);
    assert.match(f.calls[1].body.messages.at(-1).content, /rejected \(forbidden_content\)/);
});

test('generation gives up cleanly', async () => {
    const bad = JSON.stringify({ ...good, keyPoints: [] });
    const twice = await generateOverview(material, config, fakeFetch([{ content: bad }, { content: bad }]));
    assert.deepEqual([twice.ok, twice.reason], [false, 'key_points_count']);
    const limited = await generateOverview(material, config, fakeFetch([{ status: 429 }]));
    assert.deepEqual([limited.ok, limited.reason], [false, 'provider_429']);
    const none = await generateOverview(material, null, fakeFetch([]));
    assert.equal(none.reason, 'not_configured');
});
