import Link from 'next/link';
import { CONTACT_EMAIL, DEV_EMAIL, DISCORD_URL } from '@/lib/site';

export default function Footer() {
    return (
        <footer className="site-footer">
            <div className="banner-wrap">
                <img src="/assets/BANNER.png" width="1584" height="672" loading="lazy" decoding="async" alt="VERO Banner" className="banner-img" />
            </div>
            <div className="footer-grid">
                <div className="footer-brand">
                    <div className="brand-line">
                        <img src="/assets/logo-192.webp" width="44" height="44" alt="VERO" className="brand-logo" data-vl="1" />
                        <span>VERO</span>
                    </div>
                    <p>Independent global intelligence and diplomatic monitoring observatory.</p>
                </div>
                <div className="footer-col">
                    <h4>Explore</h4>
                    <Link href="/live"><i className="ph ph-broadcast" /> <span>Live</span></Link>
                    <Link href="/explore"><i className="ph ph-compass" /> <span>Explore</span></Link>
                    <Link href="/articles"><i className="ph ph-newspaper" /> <span>Articles</span></Link>
                    <Link href="/articles/new"><i className="ph ph-pen-nib" /> <span>Write for VERO</span></Link>
                </div>
                <div className="footer-col">
                    <h4>Transparency</h4>
                    <Link href="/methodology"><i className="ph ph-book-open-text" /> <span>Sources &amp; Methodology</span></Link>
                    <Link href="/privacy"><i className="ph ph-shield-check" /> <span>Privacy Policy</span></Link>
                    <Link href="/terms"><i className="ph ph-file-text" /> <span>Terms of Service</span></Link>
                </div>
                <div className="footer-col">
                    <h4>Contact</h4>
                    <a href={'mailto:' + CONTACT_EMAIL}><i className="ph ph-envelope-simple" /> <span><small>Secure Email</small>{CONTACT_EMAIL}</span></a>
                    <a href={'mailto:' + DEV_EMAIL}><i className="ph ph-envelope-simple-open" /> <span><small>Developers Email</small>{DEV_EMAIL}</span></a>
                    <a href={DISCORD_URL} target="_blank" rel="noopener noreferrer"><i className="ph ph-discord-logo" /> <span><small>Community</small>Discord server</span></a>
                </div>
            </div>
            <div className="footer-bottom">
                <span>© 2026 VERO</span>
                <span>All rights reserved.</span>
            </div>
        </footer>
    );
}
