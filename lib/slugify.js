export function slugify(text, max = 60) {
    const base = String(text || '')
        .normalize('NFKD')
        .replace(/[\u0300-\u036f]/g, '')
        .toLowerCase()
        .replace(/&/g, ' and ')
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');
    if (base.length <= max) return base;
    const cut = base.slice(0, max);
    const at = cut.lastIndexOf('-');
    return (at > 20 ? cut.slice(0, at) : cut).replace(/-+$/g, '');
}
