import Link from 'next/link';
import CoverImage from '@/components/CoverImage';
import { CATEGORIES, clip, formatDate, proxied, validCover } from '@/lib/format';
import { reportSlug } from '@/lib/slug';

export default function ReportCard({ item, overview, eager = false, linkable = true }) {
    const cat = CATEGORIES[item.cat] || CATEGORIES.intel;
    const image = validCover(item.image) ? proxied(item.image) : null;
    const stored = !item.web && linkable;
    const title = overview ? overview.title : item.title;
    const description = overview
        ? clip(overview.summary, 170)
        : clip(item.description, 150) || 'Open the report for the full story from the original publisher.';

    const body = (
        <>
            <div className={'card-banner' + (image ? '' : ' noimg')}>
                <div className="card-tag"><i className={'ph ' + cat.icon} /> {cat.label}</div>
                {image ? <CoverImage src={image} eager={eager} /> : <i className="ph ph-globe-hemisphere-west cover-fallback" aria-hidden="true" />}
            </div>
            <div className="card-content">
                <span className="card-date">{formatDate(item.publishedAt) || 'Recent'}</span>
                <h3 className="card-title" dir="auto">{title}</h3>
                <p className="card-desc" dir="auto">{description}</p>
                <div className="card-footer">
                    <div className="source-info">
                        <i className="ph ph-newspaper-clipping" />
                        <span>{item.source || ''}</span>
                        {item.web ? <span className="web-tag">Web</span> : null}
                    </div>
                    <div className="read-more">{stored ? 'Read overview' : 'Read source'} <i className="ph ph-arrow-up-right" /></div>
                </div>
            </div>
        </>
    );

    if (stored) {
        return <Link href={'/report/' + reportSlug(item.title, item.url)} className="card" prefetch={false}>{body}</Link>;
    }
    return <a href={item.url} className="card" target="_blank" rel="noopener noreferrer">{body}</a>;
}
