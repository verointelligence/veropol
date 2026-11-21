import Link from 'next/link';
import { CATEGORIES, formatDate } from '@/lib/format';
import { clip } from '@/lib/format';

export default function ArticleCard({ article }) {
    const cat = CATEGORIES[article.category] || CATEGORIES.intel;
    const author = article.author;
    return (
        <Link href={'/articles/' + article.slug} className="card" prefetch={false}>
            <div className="card-banner noimg">
                <div className="card-tag"><i className={'ph ' + cat.icon} /> {cat.label}</div>
                <i className={'ph ' + cat.icon + ' cover-fallback'} aria-hidden="true" />
            </div>
            <div className="card-content">
                <span className="card-date">{formatDate(article.createdAt)}</span>
                <h3 className="card-title" dir="auto">{article.title}</h3>
                <p className="card-desc" dir="auto">{clip(article.summary, 150)}</p>
                <div className="card-footer">
                    <div className="source-info">
                        <i className="ph ph-user" />
                        <span>{author ? author.displayName : 'VERO member'}</span>
                    </div>
                    <div className="read-more">Read <i className="ph ph-arrow-up-right" /></div>
                </div>
            </div>
        </Link>
    );
}
