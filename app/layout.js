import Script from 'next/script';
import Nav from '@/components/Nav';
import Footer from '@/components/Footer';
import Backdrop from '@/components/Backdrop';
import { CONTACT_EMAIL, GA_ID, SITE_DESCRIPTION, SITE_NAME, SITE_TITLE, SITE_URL } from '@/lib/site';
import './css/style.css';
import './css/nav.css';
import './css/home.css';
import './css/live.css';
import './css/explore.css';
import './css/pages.css';
import './css/report.css';
import './css/forms.css';
import './css/background.css';

export const metadata = {
    metadataBase: new URL(SITE_URL),
    title: { default: SITE_TITLE, template: '%s | VERO' },
    description: SITE_DESCRIPTION,
    applicationName: SITE_NAME,
    authors: [{ name: SITE_NAME }],
    robots: { index: true, follow: true, googleBot: { index: true, follow: true, 'max-image-preview': 'large' } },
    icons: {
        icon: [
            { url: '/favicon.ico', sizes: '48x48' },
            { url: '/assets/icon-48.png', sizes: '48x48', type: 'image/png' },
            { url: '/assets/icon-32.png', sizes: '32x32', type: 'image/png' },
            { url: '/assets/icon-16.png', sizes: '16x16', type: 'image/png' },
            { url: '/assets/icon-192.png', sizes: '192x192', type: 'image/png' }
        ],
        apple: [{ url: '/assets/icon-180.png', sizes: '180x180' }]
    },
    openGraph: {
        type: 'website',
        siteName: SITE_NAME,
        title: SITE_TITLE,
        description: SITE_DESCRIPTION,
        url: '/',
        images: [{ url: '/assets/BANNER.png', width: 1584, height: 672, alt: 'VERO' }]
    },
    twitter: { card: 'summary_large_image', title: SITE_TITLE, description: SITE_DESCRIPTION, images: ['/assets/BANNER.png'] }
};

export const viewport = {
    width: 'device-width',
    initialScale: 1,
    viewportFit: 'cover',
    themeColor: '#0A0A0C'
};

const THEME_SCRIPT = "(function(){try{var t=localStorage.getItem('vero_theme');if(t!=='light'&&t!=='dark'){t=window.matchMedia&&window.matchMedia('(prefers-color-scheme: light)').matches?'light':'dark';}document.documentElement.setAttribute('data-theme',t);}catch(e){}})();";

const GA_SCRIPT = "window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments);}gtag('js',new Date());gtag('config','" + GA_ID + "');";

const JSON_LD = JSON.stringify({
    '@context': 'https://schema.org',
    '@graph': [
        {
            '@type': 'WebSite',
            '@id': SITE_URL + '/#website',
            name: SITE_NAME,
            alternateName: ['VERO Global Intelligence', 'VERO Observatory', 'verointels'],
            url: SITE_URL + '/',
            inLanguage: 'en',
            publisher: { '@id': SITE_URL + '/#organization' }
        },
        {
            '@type': 'Organization',
            '@id': SITE_URL + '/#organization',
            name: SITE_NAME,
            url: SITE_URL + '/',
            logo: { '@type': 'ImageObject', url: SITE_URL + '/assets/icon-512.png', width: 512, height: 512 },
            email: CONTACT_EMAIL
        }
    ]
}).replace(/</g, '\\u003c');

export default function RootLayout({ children }) {
    return (
        <html lang="en" dir="ltr" data-theme="dark" suppressHydrationWarning>
            <head>
                <script dangerouslySetInnerHTML={{ __html: THEME_SCRIPT }} />
                <link rel="preconnect" href="https://fonts.googleapis.com" />
                <link rel="preconnect" href="https://unpkg.com" crossOrigin="" />
                <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
                <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Rubik:ital,wght@0,300..900;1,300..900&family=Unbounded:wght@700;800&display=swap" />
                <script defer src="https://unpkg.com/@phosphor-icons/web@2.1.1" />
            </head>
            <body>
                <Backdrop />
                <div className="toast-box" id="toastBox" role="status" />
                <Nav />
                {children}
                <Footer />
                <Script src={'https://www.googletagmanager.com/gtag/js?id=' + GA_ID} strategy="afterInteractive" />
                <Script id="ga-init" strategy="afterInteractive">{GA_SCRIPT}</Script>
                <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON_LD }} />
            </body>
        </html>
    );
}
