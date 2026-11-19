(function () {
    const panel = document.getElementById('filterPanel');
    const toggle = document.getElementById('filterToggle');
    const scrim = document.getElementById('filterScrim');
    const closeBtn = document.getElementById('filterClose');
    const applyBtn = document.getElementById('filterApply');
    const count = document.getElementById('filterCount');
    if (!panel || !toggle || !scrim) return;

    const wide = window.matchMedia('(min-width: 1100px)');
    let opener = null;

    function syncInert() {
        panel.inert = !wide.matches && !panel.classList.contains('open');
    }

    function setOpen(open) {
        if (wide.matches) open = false;
        const was = panel.classList.contains('open');
        panel.classList.toggle('open', open);
        scrim.classList.toggle('show', open);
        document.documentElement.classList.toggle('filters-open', open);
        toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        syncInert();
        if (open && !was) {
            opener = document.activeElement;
            const first = panel.querySelector('.filter-btn.active') || panel.querySelector('button');
            if (first) first.focus({ preventScroll: true });
        } else if (!open && was && opener && typeof opener.focus === 'function') {
            opener.focus({ preventScroll: true });
            opener = null;
        }
    }

    function refreshCount() {
        if (!count) return;
        let n = 0;
        const topic = panel.querySelector('.filter-btn.active');
        if (topic && topic.dataset.filter !== 'all') n++;
        const range = panel.querySelector('.range-btn.active');
        if (range && range.dataset.range !== 'all') n++;
        count.textContent = String(n);
        count.hidden = n === 0;
    }

    toggle.addEventListener('click', () => setOpen(!panel.classList.contains('open')));
    scrim.addEventListener('click', () => setOpen(false));
    if (closeBtn) closeBtn.addEventListener('click', () => setOpen(false));
    if (applyBtn) applyBtn.addEventListener('click', () => setOpen(false));

    panel.addEventListener('click', e => {
        if (e.target.closest('.filter-btn, .range-btn')) setTimeout(refreshCount, 0);
    });

    document.addEventListener('keydown', e => {
        if (e.key === 'Escape' && panel.classList.contains('open')) setOpen(false);
    });

    const onChange = () => {
        if (wide.matches) setOpen(false);
        syncInert();
    };
    if (wide.addEventListener) wide.addEventListener('change', onChange);
    else if (wide.addListener) wide.addListener(onChange);

    syncInert();
    refreshCount();
})();
