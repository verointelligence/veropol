import mongoose from 'mongoose';

const KEY = Symbol.for('vero.mongo');
const FAIL_TTL_MS = 30000;

function state() {
    if (!globalThis[KEY]) globalThis[KEY] = { promise: null, failedAt: 0 };
    return globalThis[KEY];
}

export default async function connect() {
    const uri = process.env.MONGODB_URI;
    if (!uri) return false;
    const s = state();
    if (s.promise) return s.promise;
    if (s.failedAt && Date.now() - s.failedAt < FAIL_TTL_MS) return false;
    mongoose.set('strictQuery', true);
    s.promise = mongoose
        .connect(uri, { serverSelectionTimeoutMS: 6000, maxPoolSize: 5 })
        .then(() => true)
        .catch(() => {
            s.promise = null;
            s.failedAt = Date.now();
            return false;
        });
    return s.promise;
}

export async function dbReady() {
    return connect();
}
