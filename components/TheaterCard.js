import Link from 'next/link';
import { THEATERS } from '@/content/theaters';
import { timeAgo } from '@/lib/format';
import { reportSlug } from '@/lib/slug';

const TAGS = { breaking: 'Breaking news', new: 'New', latest: 'Latest' };

function LiveBox({ data, overview }) {
    if (!data || !data.lead) return null;
    const lead = data.lead;
    const title = overview ? overview.title : lead.title;
    return (
        <Link className="theater-live" href={'/report/' + reportSlug(lead.title, lead.url)} prefetch={false}>
            <div className="live-head">
                <span className={'live-tag ' + data.tag}>{TAGS[data.tag] || 'Latest'}</span>
                <span className="live-time">{timeAgo(lead.publishedAt)}</span>
            </div>
            <span className="live-title" dir="auto">{title}</span>
            <div className="live-foot">
                <span>{lead.source || ''}</span>
                <span className="go">Read overview <i className="ph ph-arrow-up-right" /></span>
            </div>
            <div className="live-meta">
                <span>Reports (24h): <b>{data.count24h}</b></span>
                <span>Sources: <b>{data.sources24h}</b></span>
            </div>
        </Link>
    );
}

function Cover({ className, cover, children }) {
    return (
        <div className={className + (cover ? ' has-photo' : '')}>
            {cover ? <img className="cover-live ready" src={cover.url} alt="" loading="lazy" decoding="async" referrerPolicy="no-referrer" /> : null}
            {children}
            {cover && cover.label ? (
                <a className="cover-credit" href={cover.page} target="_blank" rel="noopener noreferrer">{cover.label}</a>
            ) : null}
        </div>
    );
}

export function TheaterCard({ id, data, overview }) {
    const t = THEATERS[id];
    if (!t) return null;
    const cover = data && data.cover ? data.cover : null;
    return (
        <article className="theater-card" data-theater={id}>
            <Cover className={'theater-cover ' + t.cover} cover={cover}>
                <div className={'theater-badge ' + t.tone}><i className={'ph ' + t.icon} /> {t.badge}</div>
            </Cover>
            <div className="theater-info">
                <h3><Link href={'/live/' + id}>{t.title}</Link></h3>
                <span className="theater-overview-label">VERO Overview</span>
                <p className="theater-desc">{t.desc}</p>
                <div className="theater-stats">
                    {t.stats.map(stat => (
                        <div className="stat-box" key={stat.label}>
                            <span className="stat-label">{stat.label}</span>
                            <span className={'stat-val' + (stat.tone ? ' ' + stat.tone : '')}>{stat.value}</span>
                        </div>
                    ))}
                </div>
                <LiveBox data={data} overview={overview} />
                <div className="theater-actions">
                    <Link href={'/explore?q=' + encodeURIComponent(t.query)} className="btn-theater-action" prefetch={false}>
                        <i className="ph ph-arrows-clockwise" /> Explore reports
                    </Link>
                    {t.map ? (
                        <a href={t.map} target="_blank" rel="noopener noreferrer" className="theater-link">Live Map <i className="ph ph-arrow-square-out" /></a>
                    ) : null}
                </div>
            </div>
        </article>
    );
}

export function DevelopingCard({ card, overview }) {
    const data = { lead: card.lead, tag: card.tag, count24h: card.count24h, sources24h: card.sources24h };
    const cover = card.cover || null;
    return (
        <article className="theater-card" data-dev={card.id}>
            <Cover className="theater-cover cv-dev" cover={cover}>
                <div className="theater-badge warning"><i className="ph ph-trend-up" /> Developing</div>
            </Cover>
            <div className="theater-info">
                <h3 dir="auto">{card.title}</h3>
                <span className="theater-overview-label">Gaining coverage</span>
                <LiveBox data={data} overview={overview} />
                <div className="theater-actions">
                    <Link href={'/explore?q=' + encodeURIComponent(card.query || card.title)} className="btn-theater-action" prefetch={false}>
                        <i className="ph ph-arrows-clockwise" /> Explore reports
                    </Link>
                </div>
            </div>
        </article>
    );
}
