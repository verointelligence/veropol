const DB_NAME = 'vero-device';
const STORE_NAME = 'keys';
const KEY_ID = 'primary';

function toBase64Url(bytes) {
    let bin = '';
    for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i]);
    return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function indexedDbStore() {
    function open() {
        return new Promise((resolve, reject) => {
            const req = indexedDB.open(DB_NAME, 1);
            req.onupgradeneeded = () => req.result.createObjectStore(STORE_NAME);
            req.onsuccess = () => resolve(req.result);
            req.onerror = () => reject(req.error);
        });
    }
    return {
        async get(id) {
            const db = await open();
            return new Promise((resolve, reject) => {
                const r = db.transaction(STORE_NAME, 'readonly').objectStore(STORE_NAME).get(id);
                r.onsuccess = () => resolve(r.result || null);
                r.onerror = () => reject(r.error);
            });
        },
        async set(id, value) {
            const db = await open();
            return new Promise((resolve, reject) => {
                const tx = db.transaction(STORE_NAME, 'readwrite');
                tx.objectStore(STORE_NAME).put(value, id);
                tx.oncomplete = () => resolve();
                tx.onerror = () => reject(tx.error);
            });
        },
        async remove(id) {
            const db = await open();
            return new Promise((resolve, reject) => {
                const tx = db.transaction(STORE_NAME, 'readwrite');
                tx.objectStore(STORE_NAME).delete(id);
                tx.oncomplete = () => resolve();
                tx.onerror = () => reject(tx.error);
            });
        }
    };
}

export function createDeviceKey({
    store,
    subtle = globalThis.crypto.subtle,
    getRandomValues = bytes => globalThis.crypto.getRandomValues(bytes),
    now = () => Date.now()
} = {}) {
    const keyStore = store || indexedDbStore();
    let cached = null;

    async function ensure() {
        if (cached) return cached;
        const saved = await keyStore.get(KEY_ID);
        if (saved && saved.privateKey && saved.publicJwk) {
            cached = saved;
            return cached;
        }
        const pair = await subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, false, ['sign', 'verify']);
        const jwk = await subtle.exportKey('jwk', pair.publicKey);
        cached = { privateKey: pair.privateKey, publicJwk: { kty: jwk.kty, crv: jwk.crv, x: jwk.x, y: jwk.y } };
        await keyStore.set(KEY_ID, cached);
        return cached;
    }

    async function publicJwk() {
        return (await ensure()).publicJwk;
    }

    async function sign(method, path) {
        const { privateKey } = await ensure();
        const ts = String(now());
        const nonceBytes = new Uint8Array(16);
        getRandomValues(nonceBytes);
        const nonce = toBase64Url(nonceBytes);
        const data = new TextEncoder().encode([String(method).toUpperCase(), String(path), ts, nonce].join('\n'));
        const sig = await subtle.sign({ name: 'ECDSA', hash: 'SHA-256' }, privateKey, data);
        return ts + '.' + nonce + '.' + toBase64Url(new Uint8Array(sig));
    }

    async function reset() {
        cached = null;
        await keyStore.remove(KEY_ID);
    }

    return { publicJwk, sign, reset };
}
