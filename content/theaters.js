export const THEATER_SECTIONS = [
    {
        key: "war",
        title: "War Theaters",
        icon: "ph-crosshair",
        sub: "Active fronts, each with a live map.",
        ids: ["ukraine", "mideast", "yemen", "syria", "lebanon", "sudan"]
    },
    {
        key: "strategic",
        title: "Strategic Watch",
        icon: "ph-binoculars",
        sub: "Diplomatic and economic flashpoints.",
        ids: ["taiwan", "brics", "korea", "sahel"]
    }
];

export const THEATERS = {
    ukraine: {
        "id": "ukraine",
        "cover": "cv-ukraine",
        "tone": "danger",
        "icon": "ph-warning-diamond",
        "badge": "Active War Zone",
        "title": "Russo-Ukrainian Conflict",
        "desc": "Frontline monitoring, territory changes, and tactical air/artillery activity.",
        "stats": [
                {
                        "label": "Artillery Posture",
                        "value": "Heavy",
                        "tone": "alert"
                },
                {
                        "label": "Air Defense",
                        "value": "Active",
                        "tone": ""
                }
        ],
        "query": "Ukraine war Russia conflict",
        "map": "https://liveuamap.com/"
    },
    mideast: {
        "id": "mideast",
        "cover": "cv-mideast",
        "tone": "danger",
        "icon": "ph-crosshair",
        "badge": "Escalation Index",
        "title": "Middle East Conflict",
        "desc": "US-Israeli military stance, Lebanese front, Iranian proxy strikes, and naval security.",
        "stats": [
                {
                        "label": "Interceptions",
                        "value": "Active",
                        "tone": "alert"
                },
                {
                        "label": "Naval Posture",
                        "value": "CSG Deployed",
                        "tone": ""
                }
        ],
        "query": "Israel Lebanon Iran Middle East",
        "map": "https://israelpalestine.liveuamap.com/"
    },
    yemen: {
        "id": "yemen",
        "cover": "cv-yemen",
        "tone": "danger",
        "icon": "ph-anchor",
        "badge": "Chokepoint Crisis",
        "title": "Yemeni Civil War & Red Sea",
        "desc": "Houthi anti-ship ballistic missile strikes, naval coalition defenses, and maritime trade disruption.",
        "stats": [
                {
                        "label": "Shipping Risk",
                        "value": "Critical",
                        "tone": "alert"
                },
                {
                        "label": "Naval Escort",
                        "value": "Active",
                        "tone": ""
                }
        ],
        "query": "Yemen Houthi Red Sea military",
        "map": "https://yemen.liveuamap.com/"
    },
    syria: {
        "id": "syria",
        "cover": "cv-syria",
        "tone": "danger",
        "icon": "ph-flag-banner",
        "badge": "Transition Watch",
        "title": "Syria, Israel & the Druze",
        "desc": "Transitional authorities, Suwayda tensions, Israeli strikes and the Golan line.",
        "stats": [
                {
                        "label": "Transition",
                        "value": "Fragile",
                        "tone": "alert"
                },
                {
                        "label": "Southern Front",
                        "value": "Tense",
                        "tone": ""
                }
        ],
        "query": "Syria Israel Druze Suwayda",
        "map": "https://syria.liveuamap.com/"
    },
    lebanon: {
        "id": "lebanon",
        "cover": "cv-lebanon",
        "tone": "danger",
        "icon": "ph-crosshair",
        "badge": "Border Front",
        "title": "Lebanon, Israel & Hezbollah",
        "desc": "South Lebanon strikes, ceasefire terms, Hezbollah disarmament and reconstruction.",
        "stats": [
                {
                        "label": "Ceasefire",
                        "value": "Contested",
                        "tone": "alert"
                },
                {
                        "label": "Border Strikes",
                        "value": "Ongoing",
                        "tone": ""
                }
        ],
        "query": "Lebanon Israel Hezbollah ceasefire",
        "map": "https://lebanon.liveuamap.com/"
    },
    sudan: {
        "id": "sudan",
        "cover": "cv-sudan",
        "tone": "danger",
        "icon": "ph-first-aid",
        "badge": "Humanitarian Crisis",
        "title": "Sudan War",
        "desc": "Army and Rapid Support Forces fighting, El Fasher, famine and displacement.",
        "stats": [
                {
                        "label": "Fronts",
                        "value": "Multiple",
                        "tone": "alert"
                },
                {
                        "label": "Displacement",
                        "value": "Critical",
                        "tone": ""
                }
        ],
        "query": "Sudan RSF army El Fasher",
        "map": "https://sudan.liveuamap.com/"
    },
    taiwan: {
        "id": "taiwan",
        "cover": "cv-taiwan",
        "tone": "warning",
        "icon": "ph-eye",
        "badge": "Indo-Pacific Watch",
        "title": "China - Taiwan Strait",
        "desc": "PLA naval encirclement exercises, ADIZ incursions, and US deterrence shifts.",
        "stats": [
                {
                        "label": "ADIZ Incursions",
                        "value": "Elevated",
                        "tone": "warning"
                },
                {
                        "label": "Chokepoint",
                        "value": "Monitored",
                        "tone": ""
                }
        ],
        "query": "China Taiwan US military",
        "map": ""
    },
    brics: {
        "id": "brics",
        "cover": "cv-brics",
        "tone": "info",
        "icon": "ph-currency-dollar-simple",
        "badge": "Geo-Economics",
        "title": "BRICS & Multipolarity",
        "desc": "De-dollarization initiatives, alternative payment routing, and resource corridors.",
        "stats": [
                {
                        "label": "Trade Currency",
                        "value": "Local Pivot",
                        "tone": ""
                },
                {
                        "label": "Sanctions",
                        "value": "Systemic",
                        "tone": ""
                }
        ],
        "query": "BRICS economy sanctions trade",
        "map": ""
    },
    korea: {
        "id": "korea",
        "cover": "cv-korea",
        "tone": "warning",
        "icon": "ph-warning",
        "badge": "East Asia Watch",
        "title": "Korean Peninsula",
        "desc": "Ballistic missile tests, demilitarized zone tensions, and trilateral defense pacts.",
        "stats": [
                {
                        "label": "Missile Tests",
                        "value": "Frequent",
                        "tone": "alert"
                },
                {
                        "label": "Border Status",
                        "value": "Tense",
                        "tone": ""
                }
        ],
        "query": "North Korea South Korea military",
        "map": ""
    },
    sahel: {
        "id": "sahel",
        "cover": "cv-sahel",
        "tone": "danger",
        "icon": "ph-fire",
        "badge": "High Instability",
        "title": "Sahel Region Crisis",
        "desc": "Military juntas, insurgent expansions, and shifts in foreign military influence.",
        "stats": [
                {
                        "label": "Regime Status",
                        "value": "Transitional",
                        "tone": "alert"
                },
                {
                        "label": "Insurgency",
                        "value": "Expanding",
                        "tone": ""
                }
        ],
        "query": "Sahel Africa military coup",
        "map": ""
    }
};

export const THEATER_IDS = Object.keys(THEATERS);

export function isTheater(id) {
    return Object.prototype.hasOwnProperty.call(THEATERS, id);
}
