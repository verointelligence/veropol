import AutoRefresh from '@/components/AutoRefresh';
import { DevelopingCard, TheaterCard } from '@/components/TheaterCard';
import { THEATERS, THEATER_SECTIONS } from '@/content/theaters';
import { dbReady } from '@/lib/db';
import { theatersWithCovers } from '@/lib/news/engine';
import { ingest } from '@/lib/reports';
import { reportSlug } from '@/lib/slug';

export const dynamic = 'force-dynamic';

export const metadata = {
    title: 'Live Theaters',
    description: 'Active conflicts and strategic flashpoints tracked live from vetted newsrooms, each with a VERO overview and a map link.',
    alternates: { canonical: '/live' },
    openGraph: { title: 'Live Theaters | VERO', description: 'Active conflicts and strategic flashpoints tracked live from vetted newsrooms.', url: '/live', type: 'website' }
};

async function loadData() {
    try {
        return await theatersWithCovers();
    } catch {
        return { theaters: {}, developing: [], updatedAt: null };
    }
}

export default async function LivePage() {
    const data = await loadData();
    const linkable = await dbReady();
    const overviews = new Map();
    if (linkable) await Promise.all(Object.keys(data.theaters).map(async id => {
        const t = data.theaters[id];
        if (!t || !t.lead) return;
        const map = await ingest([t.lead, ...(t.more || [])], { theater: id, warm: 1 }).catch(() => new Map());
        map.forEach((v, k) => overviews.set(k, v));
    }));
    const devMap = linkable ? await ingest((data.developing || []).map(d => d.lead).filter(Boolean), { warm: 0 }).catch(() => new Map()) : new Map();
    devMap.forEach((v, k) => overviews.set(k, v));
    const overviewOf = lead => (lead ? overviews.get(reportSlug(lead.title, lead.url)) : undefined);

    return (
        <div className="page-live">
            <AutoRefresh seconds={300} />
            <main className="container live-main">
                <header className="page-head">
                    <h1>Live Theaters</h1>
                    <p className="live-status"><span className="dot" /><span>Updated every 5 minutes.</span></p>
                </header>
                {THEATER_SECTIONS.map(section => (
                    <section className="live-section" key={section.key} id={section.key}>
                        <div className="live-section-head">
                            <h2><i className={'ph ' + section.icon} /> {section.title}</h2>
                            <p>{section.sub}</p>
                        </div>
                        <div className="flex-grid theaters-grid">
                            {section.ids.filter(id => THEATERS[id]).map(id => (
                                <TheaterCard key={id} id={id} data={data.theaters[id]} overview={overviewOf(data.theaters[id] && data.theaters[id].lead)} linkable={linkable} />
                            ))}
                        </div>
                    </section>
                ))}
                {data.developing && data.developing.length ? (
                    <section className="live-section" id="developing">
                        <div className="live-section-head">
                            <h2><i className="ph ph-trend-up" /> Developing</h2>
                            <p>Stories gaining coverage now. Removed when the trend ends.</p>
                        </div>
                        <div className="flex-grid theaters-grid">
                            {data.developing.map(card => (
                                <DevelopingCard key={card.id} card={card} overview={overviewOf(card.lead)} linkable={linkable} />
                            ))}
                        </div>
                    </section>
                ) : null}
            </main>
        </div>
    );
}
