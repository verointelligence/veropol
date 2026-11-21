import mongoose from 'mongoose';

const schema = new mongoose.Schema({
    key: { type: String, required: true, unique: true, maxlength: 300 },
    purpose: { type: String, default: '', maxlength: 24 },
    codeHash: { type: String, default: null, maxlength: 128 },
    expiresAt: { type: Number, default: 0 },
    attempts: { type: Number, default: 0 },
    sentAt: { type: Number, default: 0 },
    sendTimes: { type: [Number], default: [] },
    updatedAt: { type: Date, default: Date.now, index: { expireAfterSeconds: 172800 } }
});

export default mongoose.models.AuthCode || mongoose.model('AuthCode', schema);
