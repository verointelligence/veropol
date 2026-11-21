import mongoose from 'mongoose';

const schema = new mongoose.Schema({
    slug: { type: String, required: true, unique: true, maxlength: 90 },
    title: { type: String, required: true, maxlength: 140 },
    summary: { type: String, required: true, maxlength: 300 },
    body: { type: String, required: true, maxlength: 30000 },
    category: { type: String, required: true, maxlength: 24 },
    authorId: { type: String, required: true, index: true, maxlength: 40 },
    status: { type: String, default: 'published', maxlength: 12 },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date }
});

schema.index({ createdAt: -1 });
schema.index({ category: 1, createdAt: -1 });

export default mongoose.models.Article || mongoose.model('Article', schema);
