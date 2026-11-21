import mongoose from 'mongoose';

const schema = new mongoose.Schema({
    email: { type: String, required: true, unique: true, maxlength: 254 },
    emailDisplay: { type: String, required: true, maxlength: 254 },
    username: { type: String, required: true, unique: true, maxlength: 20 },
    displayName: { type: String, required: true, maxlength: 40 },
    bio: { type: String, default: '', maxlength: 280 },
    birthDate: { type: Date, required: true },
    badges: { type: [String], default: [] },
    banned: { type: Boolean, default: false },
    createdAt: { type: Date, default: Date.now },
    usernameChangedAt: { type: Date }
});

export default mongoose.models.User || mongoose.model('User', schema);
