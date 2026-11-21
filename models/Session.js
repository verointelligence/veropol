import mongoose from 'mongoose';

const schema = new mongoose.Schema({
    idHash: { type: String, required: true, unique: true, maxlength: 64 },
    userId: { type: String, required: true, index: true, maxlength: 40 },
    device: {
        jwk: { kty: String, crv: String, x: String, y: String },
        thumbprint: String
    },
    createdAt: { type: Number, required: true },
    lastSeenAt: { type: Number, required: true },
    expiresAt: { type: Number, required: true },
    expireAt: { type: Date, required: true, index: { expireAfterSeconds: 0 } }
});

export default mongoose.models.Session || mongoose.model('Session', schema);
