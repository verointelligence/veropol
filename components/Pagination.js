import Link from 'next/link';

function sequence(current, total) {
    if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
    const pages = [...new Set([1, 2, current - 1, current, current + 1, total - 1, total])].filter(p => p >= 1 && p <= total).sort((a, b) => a - b);
    const out = [];
    pages.forEach((p, i) => {
        if (i > 0 && p - pages[i - 1] > 1) out.push('gap-' + p);
        out.push(p);
    });
    return out;
}

export default function Pagination({ page, totalPages, hrefFor }) {
    if (totalPages <= 1) return null;
    const prev = page > 1;
    const next = page < totalPages;
    return (
        <nav className="pagination" aria-label="Pagination">
            {prev ? (
                <Link className="page-arrow" href={hrefFor(page - 1)} aria-label="Previous page" prefetch={false}><i className="ph ph-caret-left" /></Link>
            ) : (
                <span className="page-arrow" aria-disabled="true"><i className="ph ph-caret-left" /></span>
            )}
            <div className="page-center">
                <div className="page-numbers">
                    {sequence(page, totalPages).map(p => (
                        typeof p === 'string' ? (
                            <span key={p} className="page-gap">&hellip;</span>
                        ) : (
                            <Link key={p} className={'page-num' + (p === page ? ' active' : '')} href={hrefFor(p)} aria-current={p === page ? 'page' : undefined} prefetch={false}>{p}</Link>
                        )
                    ))}
                </div>
            </div>
            {next ? (
                <Link className="page-arrow" href={hrefFor(page + 1)} aria-label="Next page" prefetch={false}><i className="ph ph-caret-right" /></Link>
            ) : (
                <span className="page-arrow" aria-disabled="true"><i className="ph ph-caret-right" /></span>
            )}
        </nav>
    );
}
