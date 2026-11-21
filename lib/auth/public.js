import connect from '@/lib/db';
import User from '@/models/User';

export async function getPublicProfile(username) {
    const name = String(username || '').toLowerCase();
    if (!/^[a-z0-9_]{3,20}$/.test(name) || !(await connect())) return null;
    const doc = await User.findOne({ username: name, banned: { $ne: true } }).select('username displayName bio badges createdAt').lean().catch(() => null);
    if (!doc) return null;
    return { id: String(doc._id), username: doc.username, displayName: doc.displayName, bio: doc.bio || '', badges: doc.badges || [], createdAt: doc.createdAt };
}

export async function authorsById(ids) {
    const list = [...new Set((ids || []).map(String))].filter(id => /^[a-f0-9]{24}$/.test(id)).slice(0, 60);
    if (!list.length || !(await connect())) return new Map();
    const docs = await User.find({ _id: { $in: list } }).select('username displayName badges').lean().catch(() => []);
    return new Map(docs.map(d => [String(d._id), { username: d.username, displayName: d.displayName, badges: d.badges || [] }]));
}
