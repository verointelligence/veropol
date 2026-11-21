import connect from '@/lib/db';
import User from '@/models/User';
import Session from '@/models/Session';
import AuthCode from '@/models/AuthCode';

function toUser(doc) {
    if (!doc) return null;
    return {
        id: String(doc._id),
        email: doc.email,
        emailDisplay: doc.emailDisplay,
        username: doc.username,
        displayName: doc.displayName,
        bio: doc.bio || '',
        birthDate: doc.birthDate,
        badges: doc.badges || [],
        banned: Boolean(doc.banned),
        createdAt: doc.createdAt,
        usernameChangedAt: doc.usernameChangedAt || null
    };
}

function duplicateReason(error) {
    if (!error || error.code !== 11000) return null;
    const keys = Object.keys(error.keyPattern || error.keyValue || {});
    return keys.includes('username') ? 'duplicate_username' : 'duplicate_email';
}

async function ready() {
    if (!(await connect())) throw new Error('database unavailable');
}

export function createMongoStore() {
    return {
        async findUserByEmail(email) {
            await ready();
            return toUser(await User.findOne({ email: String(email) }).lean());
        },
        async findUserByUsername(username) {
            await ready();
            return toUser(await User.findOne({ username: String(username) }).lean());
        },
        async findUserById(id) {
            await ready();
            if (!/^[a-f0-9]{24}$/.test(String(id))) return null;
            return toUser(await User.findById(String(id)).lean());
        },
        async createUser(data) {
            await ready();
            try {
                const doc = await User.create(data);
                return { ok: true, user: toUser(doc.toObject()) };
            } catch (error) {
                const reason = duplicateReason(error);
                if (reason) return { ok: false, reason };
                throw error;
            }
        },
        async updateUser(id, patch) {
            await ready();
            try {
                const doc = await User.findByIdAndUpdate(String(id), { $set: patch }, { new: true, runValidators: true }).lean();
                return doc ? { ok: true, user: toUser(doc) } : { ok: false, reason: 'missing' };
            } catch (error) {
                const reason = duplicateReason(error);
                if (reason) return { ok: false, reason };
                throw error;
            }
        },
        async getCode(key) {
            await ready();
            const doc = await AuthCode.findOne({ key: String(key) }).lean();
            if (!doc) return null;
            return { purpose: doc.purpose, codeHash: doc.codeHash || null, expiresAt: doc.expiresAt, attempts: doc.attempts, sentAt: doc.sentAt, sendTimes: doc.sendTimes || [] };
        },
        async setCode(key, record) {
            await ready();
            if (!record) {
                await AuthCode.deleteOne({ key: String(key) });
                return;
            }
            await AuthCode.updateOne({ key: String(key) }, { $set: { ...record, updatedAt: new Date() } }, { upsert: true });
        },
        async createSession(record) {
            await ready();
            await Session.create({ ...record, expireAt: new Date(record.expiresAt) });
        },
        async findSession(idHash) {
            await ready();
            const doc = await Session.findOne({ idHash: String(idHash) }).lean();
            if (!doc) return null;
            return {
                idHash: doc.idHash,
                userId: doc.userId,
                device: { jwk: { kty: doc.device.jwk.kty, crv: doc.device.jwk.crv, x: doc.device.jwk.x, y: doc.device.jwk.y }, thumbprint: doc.device.thumbprint },
                createdAt: doc.createdAt,
                lastSeenAt: doc.lastSeenAt,
                expiresAt: doc.expiresAt
            };
        },
        async touchSession(idHash, time) {
            await ready();
            await Session.updateOne({ idHash: String(idHash) }, { $set: { lastSeenAt: time } });
        },
        async deleteSession(idHash) {
            await ready();
            await Session.deleteOne({ idHash: String(idHash) });
        }
    };
}
