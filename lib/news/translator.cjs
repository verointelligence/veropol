module.exports = {
    detectToEnglish: async q => ({ text: String(q || ''), detected: 'en' }),
    normalizeLang: () => 'en',
    translateTexts: async texts => (Array.isArray(texts) ? texts.map(() => null) : [])
};
