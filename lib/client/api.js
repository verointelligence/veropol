import { createDeviceKey } from '@/lib/device-key-client.mjs';

let deviceKey = null;

export function getDeviceKey() {
    if (!deviceKey) deviceKey = createDeviceKey();
    return deviceKey;
}

async function parse(response) {
    let data = null;
    try {
        data = await response.json();
    } catch {
        data = null;
    }
    return { ok: response.ok, status: response.status, data };
}

export async function apiFetch(path, { method = 'GET', body } = {}) {
    const proof = await getDeviceKey().sign(method, path);
    const response = await fetch(path, {
        method,
        credentials: 'same-origin',
        cache: 'no-store',
        headers: { 'Content-Type': 'application/json', 'X-Vero-Proof': proof },
        body: body === undefined ? undefined : JSON.stringify(body)
    });
    return parse(response);
}

export async function publicPost(path, body) {
    const response = await fetch(path, {
        method: 'POST',
        credentials: 'same-origin',
        cache: 'no-store',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
    });
    return parse(response);
}

export function hasSessionMarker() {
    return typeof document !== 'undefined' && /(?:^|;\s*)vero_in=1(?:;|$)/.test(document.cookie);
}
