import { SYSTEM_PROMPT, buildUserPrompt } from './prompt.js';
import { extractJson, validateOverview } from './validate.js';

export function overviewConfig(env = process.env) {
    const baseUrl = String(env.LLM_BASE_URL || '').replace(/\/+$/, '');
    const apiKey = String(env.LLM_API_KEY || '');
    const model = String(env.LLM_MODEL || '');
    if (!/^https:\/\//.test(baseUrl) || !apiKey || !model) return null;
    const daily = parseInt(env.OVERVIEW_DAILY_LIMIT || '150', 10);
    return { baseUrl, apiKey, model, dailyLimit: Number.isFinite(daily) && daily > 0 ? daily : 150 };
}

async function ask(config, messages, fetchImpl) {
    const response = await fetchImpl(config.baseUrl + '/chat/completions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + config.apiKey },
        body: JSON.stringify({ model: config.model, messages, temperature: 0.3, max_tokens: 700 }),
        signal: AbortSignal.timeout(25000)
    });
    if (!response.ok) throw new Error('provider_' + response.status);
    const data = await response.json();
    const text = data && data.choices && data.choices[0] && data.choices[0].message ? data.choices[0].message.content : '';
    return typeof text === 'string' ? text : '';
}

export async function generateOverview(material, config, fetchImpl = fetch) {
    if (!config) return { ok: false, reason: 'not_configured' };
    const messages = [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: buildUserPrompt(material) }
    ];
    let lastReason = 'unknown';
    for (let attempt = 0; attempt < 2; attempt++) {
        let text;
        try {
            text = await ask(config, messages, fetchImpl);
        } catch (e) {
            return { ok: false, reason: String(e && e.message ? e.message : 'request_failed').slice(0, 40) };
        }
        const checked = validateOverview(extractJson(text), material.sourceText);
        if (checked.ok) return { ok: true, overview: checked.value, model: config.model };
        lastReason = checked.reason;
        messages.push({ role: 'assistant', content: text.slice(0, 1500) });
        messages.push({ role: 'user', content: 'Your answer was rejected (' + checked.reason + '). Follow every rule and return only the JSON object.' });
    }
    return { ok: false, reason: lastReason };
}
