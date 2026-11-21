import mongoose from 'mongoose';

const KEY = Symbol.for('vero.mongo');

export default async function connect() {
    const uri = process.env.MONGODB_URI;
    if (!uri) return false;
    if (!globalThis[KEY]) {
        mongoose.set('strictQuery', true);
        globalThis[KEY] = mongoose
            .connect(uri, { serverSelectionTimeoutMS: 8000, maxPoolSize: 5 })
            .then(() => true)
            .catch(() => {
                globalThis[KEY] = null;
                return false;
            });
    }
    return globalThis[KEY];
}
