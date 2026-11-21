import test from 'node:test';
import assert from 'node:assert/strict';
import { ARTICLE_CATEGORIES, articleSlug, countLinks, isArticleSlug, parseBody, readingMinutes, validateArticle } from '../lib/articles-core.js';

const body = ('This is a paragraph with enough words to make the body long enough for validation. ').repeat(8);
const ok = { title: 'Why the Black Sea matters for grain', summary: 'A short explanation of why shipping lanes in the Black Sea shape global grain prices and diplomacy.', body, category: 'economy' };

test('valid article is cleaned and accepted', () => {
    const r = validateArticle({ ...ok, title: '  Why   the Black Sea matters for grain \u0007' });
    assert.equal(r.ok, true);
    assert.equal(r.value.title, 'Why the Black Sea matters for grain');
});

test('articles are rejected for bad fields', () => {
    const cases = [
        [{ ...ok, title: 'Short' }, 'title'],
        [{ ...ok, summary: 'Too short.' }, 'summary'],
        [{ ...ok, body: 'tiny' }, 'body'],
        [{ ...ok, body: 'x '.repeat(20000) }, 'body'],
        [{ ...ok, category: 'sports' }, 'category'],
        [{ ...ok, title: 'Read more at https://spam.example now' }, 'links'],
        [{ ...ok, body: body + ' http://a.test http://b.test http://c.test http://d.test' }, 'links'],
        [{ ...ok, body: ('buy now buy now buy now buy now buy now buy now buy now buy now buy now ').repeat(8) }, 'spam'],
        [null, 'title']
    ];
    for (const [input, reason] of cases) {
        const r = validateArticle(input);
        assert.equal(r.ok, false);
        assert.equal(r.reason, reason);
    }
    assert.ok(ARTICLE_CATEGORIES.includes('opinion'));
});

test('slugs have a stable shape', () => {
    const slug = articleSlug('Why the Black Sea matters', 'a1b2c3');
    assert.equal(slug, 'why-the-black-sea-matters-a1b2c3');
    assert.equal(isArticleSlug(slug), true);
    assert.equal(articleSlug('\u0623\u062e\u0628\u0627\u0631', 'a1b2c3'), 'article-a1b2c3');
    for (const bad of ['', '../x', 'abc', 'x-ZZZZZZ', 'x-a1b2c', null]) assert.equal(isArticleSlug(bad), false);
});

test('body parser builds safe blocks', () => {
    const blocks = parseBody('## Heading here\n\nFirst line\nsecond line\n\n- one\n- two\n\n<script>alert(1)</script>');
    assert.deepEqual(blocks.map(b => b.type), ['h2', 'p', 'ul', 'p']);
    assert.equal(blocks[1].text, 'First line second line');
    assert.deepEqual(blocks[2].items, ['one', 'two']);
    assert.equal(blocks[3].text, '<script>alert(1)</script>');
    assert.equal(countLinks('see https://a.test and www.b.test'), 2);
    assert.equal(readingMinutes('word '.repeat(660)), 3);
});
