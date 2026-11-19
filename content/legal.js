import { CONTACT_EMAIL, LEGAL_UPDATED } from '@/lib/site';

export const LEGAL = {
    methodology: {
        slug: 'methodology',
        title: 'Sources & Methodology',
        lead: 'How information reaches VERO, how outlets are chosen and what VERO never does.',
        updated: LEGAL_UPDATED,
        sections: [
            {
                id: 'how-information-reaches-vero',
                title: 'How information reaches VERO',
                body: [
                    'VERO does not write news. It reads the public RSS feeds that vetted outlets publish and adds results from a licensed news aggregation interface. Only outlets on the vetted list can appear. Every report is shown in the language its publisher used.'
                ]
            },
            {
                id: 'how-outlets-are-chosen',
                title: 'How outlets are chosen',
                body: [
                    'VERO selects established outlets with a public editorial process, a large audience and a track record of issuing corrections. Perspectives are deliberately mixed: Arab regional media, European public and independent media, United Nations reporting, and US-based wire services and non-profit broadcasters.',
                    'No outlet is perfectly neutral, and VERO does not claim otherwise. Some outlets on the list are funded or owned by states or state-linked groups. They are included for regional perspective, and the region of each outlet is shown so that readers can weigh its viewpoint.',
                    'When the vetted sources hold little on a topic, Explore adds reports from the wider web. These are labeled Web and are not part of the vetted list.'
                ]
            },
            {
                id: 'how-results-are-ranked',
                title: 'How results are compared and ranked',
                body: [
                    'Results are ranked by how closely a headline and description match the search, how relevant they are to geopolitics, and how recent they are. Duplicate headlines are removed. Different reports are never merged, rewritten or summarized into one, so differences between outlets stay visible.'
                ]
            },
            {
                id: 'vero-overviews',
                title: 'VERO overviews',
                body: [
                    'Every report on VERO has its own page. The page opens with a VERO overview: a short, original summary that places the report in context, followed by the publisher\u2019s headline and a link to the full report. An overview never replaces the original and is never presented as the publisher\u2019s own words.'
                ]
            },
            {
                id: 'what-vero-does-not-do',
                title: 'What VERO does not do',
                body: [
                    'VERO does not copy full articles, bypass paywalls, use anonymous blogs or social media posts as sources, or sell placement. Every report links to the original publisher.'
                ]
            },
            {
                id: 'corrections',
                title: 'Corrections',
                body: [
                    'If a page appears misleading, or a source should be added or removed, report it by email to ' + CONTACT_EMAIL + ' or in the VERO Discord server.'
                ]
            }
        ]
    },
    privacy: {
        slug: 'privacy',
        title: 'Privacy Policy',
        lead: 'What VERO collects, why, and the control you keep.',
        updated: LEGAL_UPDATED,
        sections: [
            {
                id: 'scope',
                title: 'Scope',
                body: [
                    'This policy describes how VERO processes personal data when the site is visited, searched, or used through an account.'
                ]
            },
            {
                id: 'visitors',
                title: 'Visitors',
                body: [
                    'VERO uses Google Analytics to measure anonymous, aggregate usage such as pages viewed, device type and approximate region. Cookies may be set for this purpose. The hosting provider processes IP addresses in server logs as part of normal operation. Personal data is never sold.'
                ]
            },
            {
                id: 'search',
                title: 'Search',
                body: [
                    'Search terms are sent to the news provider to return relevant reports. Searches are not stored in the VERO database. Recent searches and the theme choice remain in the visitor\u2019s own browser and can be cleared at any time.'
                ]
            },
            {
                id: 'accounts',
                title: 'Accounts',
                body: [
                    'Accounts are available to persons aged 13 or older. VERO stores a username, an email address, a date of birth, and an optional display name, photo and short bio. The date of birth is used only to apply age requirements and is never displayed.',
                    'The username, display name, photo, bio, badges, articles, edits, comments and follower counts are public. The email address is never displayed.'
                ]
            },
            {
                id: 'sign-in',
                title: 'Sign-in',
                body: [
                    'VERO has no passwords. To sign in, VERO emails a one-time code to the address on the account. A code expires after ten minutes and works once. Email is delivered through Resend, which processes the address for that purpose.'
                ]
            },
            {
                id: 'sessions-and-security',
                title: 'Sessions and security',
                body: [
                    'After sign-in, VERO sets a secure session cookie and creates a cryptographic key that stays in the browser on that device. Requests are signed with that key, so a copied cookie does not work on another device. Signing out ends the session. Traffic is encrypted and administrative access is restricted.'
                ]
            },
            {
                id: 'activity-and-notifications',
                title: 'Activity and notifications',
                body: [
                    'Articles, edit proposals, comments, reactions and follows are stored to operate the service. Articles and the history of their edits are public. In-app notifications can be switched off, in whole or by type, in the account settings. Browser alerts are shown only with the user\u2019s permission.'
                ]
            },
            {
                id: 'messages',
                title: 'Messages',
                body: [
                    'Messages sent to VERO by email are used only to reply and to improve the service.'
                ]
            },
            {
                id: 'providers',
                title: 'Providers',
                body: [
                    'VERO relies on a small number of providers: the hosting provider, Google Analytics, Resend for email delivery, and news providers for reports. Each processes data under its own terms.'
                ]
            },
            {
                id: 'retention-and-rights',
                title: 'Retention and rights',
                body: [
                    'An account and all associated content can be deleted at any time in the account settings. Access, correction or deletion of personal data can also be requested by email to ' + CONTACT_EMAIL + '.'
                ]
            },
            {
                id: 'changes',
                title: 'Changes',
                body: [
                    'This policy may be updated. The date above shows the latest version.'
                ]
            }
        ]
    },
    terms: {
        slug: 'terms',
        title: 'Terms of Service',
        lead: 'The rules for using VERO.',
        updated: LEGAL_UPDATED,
        sections: [
            {
                id: 'service',
                title: 'Service',
                body: [
                    'VERO is an information service that organizes public reporting. It is not legal, financial, military or investment advice. Original reports remain the property of their publishers.'
                ]
            },
            {
                id: 'accounts',
                title: 'Accounts',
                body: [
                    'Users must be at least 13 years old and must provide accurate information. An account is tied to a verified email address at a supported provider. Impersonation, harassment, spam and unlawful content are prohibited. VERO may remove content or suspend accounts that breach these terms.'
                ]
            },
            {
                id: 'articles',
                title: 'Articles',
                body: [
                    'Articles may be published by adults with a verified email address. Authors keep the copyright of their work and grant VERO a non-exclusive licence to publish and display it. Articles are published without prior review and express the views of their authors, not of VERO. VERO may remove an article that breaches these terms.'
                ]
            },
            {
                id: 'edit-proposals',
                title: 'Edit proposals',
                body: [
                    'Members can propose edits to an article. A proposal appears as its own thread beside the original, with its own reactions and comments, and never changes the original article. Proposals follow the same rules as articles.'
                ]
            },
            {
                id: 'comments',
                title: 'Comments',
                body: [
                    'Comments must be respectful and relevant. VERO may delete comments that breach these terms.'
                ]
            },
            {
                id: 'ownership',
                title: 'Ownership',
                body: [
                    'The VERO name, logo, design and software are the property of VERO. All rights reserved. Content from third-party publishers belongs to those publishers.'
                ]
            },
            {
                id: 'links-and-availability',
                title: 'Links and availability',
                body: [
                    'VERO links to third-party sites and is not responsible for their content. The service is provided as is, without warranty, and may change or be interrupted without notice.'
                ]
            },
            {
                id: 'changes',
                title: 'Changes',
                body: [
                    'These terms may be updated. Continued use of the site constitutes acceptance of the current version.'
                ]
            }
        ]
    }
};

export const LEGAL_ORDER = ['methodology', 'privacy', 'terms'];
