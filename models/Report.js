import mongoose from 'mongoose';

const schema = new mongoose.Schema({
    slug: { type: String, required: true, unique: true, maxlength: 100 },
    urlHash: { type: String, required: true, maxlength: 16 },
    url: { type: String, required: true, maxlength: 1500 },
    title: { type: String, required: true, maxlength: 300 },
    description: { type: String, default: '', maxlength: 400 },
    source: { type: String, required: true, maxlength: 80 },
    sourceRegion: { type: String, default: '', maxlength: 80 },
    image: { type: String, default: '', maxlength: 1000 },
    publishedAt: { type: Date, required: true },
    theater: { type: String, default: '', maxlength: 24 },
    category: { type: String, default: 'intel', maxlength: 24 },
    lang: { type: String, default: 'en', maxlength: 8 },
    overview: {
        title: String,
        summary: String,
        context: String,
        keyPoints: [String],
        model: String,
        generatedAt: Date
    },
    overviewFailures: { type: Number, default: 0 },
    lastTriedAt: Date,
    firstSeenAt: { type: Date, default: Date.now },
    lastSeenAt: { type: Date, default: Date.now }
});

schema.index({ 'overview.generatedAt': -1 });
schema.index({ theater: 1, publishedAt: -1 });
schema.index({ publishedAt: -1 });

export default mongoose.models.Report || mongoose.model('Report', schema);
