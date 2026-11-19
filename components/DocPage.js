import Link from 'next/link';
import { LEGAL, LEGAL_ORDER } from '@/content/legal';

function formatDate(value) {
    return new Date(value + 'T00:00:00Z').toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric', timeZone: 'UTC' });
}

const ICONS = { methodology: 'ph-book-open-text', privacy: 'ph-shield-check', terms: 'ph-file-text' };

export default function DocPage({ doc }) {
    const others = LEGAL_ORDER.filter(slug => slug !== doc.slug);
    return (
        <main className="doc-page">
            <header className="doc-head">
                <p className="doc-eyebrow">VERO</p>
                <h1>{doc.title}</h1>
                <p className="doc-lead">{doc.lead}</p>
                <p className="doc-meta">Last updated {formatDate(doc.updated)}</p>
            </header>
            <div className="doc-layout">
                <nav className="doc-toc" aria-label="On this page">
                    <p>On this page</p>
                    <ul>
                        {doc.sections.map(section => (
                            <li key={section.id}><a href={'#' + section.id}>{section.title}</a></li>
                        ))}
                    </ul>
                </nav>
                <article className="doc-body">
                    {doc.sections.map(section => (
                        <section key={section.id} id={section.id}>
                            <h2>{section.title}</h2>
                            {section.body.map((paragraph, index) => (
                                <p key={index}>{paragraph}</p>
                            ))}
                        </section>
                    ))}
                </article>
            </div>
            <div className="doc-links">
                {others.map(slug => (
                    <Link key={slug} href={'/' + slug} className="btn-ghost">
                        <i className={'ph ' + ICONS[slug]} /> <span>{LEGAL[slug].title}</span>
                    </Link>
                ))}
            </div>
        </main>
    );
}
