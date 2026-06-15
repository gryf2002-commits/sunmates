/* SunMates site — header/footer partagés, menu mobile, reveals GSAP.
   Header & footer sont injectés ici pour rester DRY : on édite la marque à UN seul endroit. */
(function () {
  'use strict';

  var APP_URL = 'https://gryf2002-commits.github.io/bootcamp-projet/';
  var page = document.body.getAttribute('data-page') || '';

  var NAV = [
    { href: 'index.html',            key: 'home',     label: 'Accueil' },
    { href: 'securite.html',         key: 'securite', label: 'Sécurité' },
    { href: 'fonctionnalites.html',  key: 'features', label: 'Fonctionnalités' },
    { href: 'a-propos.html',         key: 'about',    label: 'À propos' },
  ];

  // Logo « soleil » bespoke (clin d'œil à la DA jour/nuit de l'app)
  var LOGO = '' +
    '<span class="inline-flex items-center gap-2.5">' +
      '<svg width="34" height="34" viewBox="0 0 48 48" aria-hidden="true" class="shrink-0">' +
        '<defs><linearGradient id="lg-sun" x1="0" y1="0" x2="1" y2="1">' +
          '<stop offset="0" stop-color="#FFC93C"/><stop offset=".5" stop-color="#FF7A3D"/><stop offset="1" stop-color="#FF4F6D"/>' +
        '</linearGradient></defs>' +
        '<g fill="url(#lg-sun)">' +
          '<circle cx="24" cy="24" r="9"/>' +
          '<g>' +
            '<rect x="22.5" y="2"  width="3" height="7" rx="1.5"/>' +
            '<rect x="22.5" y="39" width="3" height="7" rx="1.5"/>' +
            '<rect x="2"  y="22.5" width="7" height="3" rx="1.5"/>' +
            '<rect x="39" y="22.5" width="7" height="3" rx="1.5"/>' +
            '<rect x="8"  y="8"  width="3" height="7" rx="1.5" transform="rotate(-45 9.5 11.5)"/>' +
            '<rect x="37" y="33" width="3" height="7" rx="1.5" transform="rotate(-45 38.5 36.5)"/>' +
            '<rect x="8"  y="33" width="3" height="7" rx="1.5" transform="rotate(45 9.5 36.5)"/>' +
            '<rect x="37" y="8"  width="3" height="7" rx="1.5" transform="rotate(45 38.5 11.5)"/>' +
          '</g>' +
        '</g>' +
      '</svg>' +
      '<span class="font-display font-black text-xl tracking-tightish text-ink">SunMates</span>' +
    '</span>';

  function navLinks(extra) {
    extra = extra || '';
    return NAV.map(function (n) {
      var active = n.key === page;
      var cls = active ? 'text-coral-ink' : 'text-ink/70 hover:text-ink';
      return '<a href="' + n.href + '" class="lnk font-semibold ' + cls + ' ' + extra + '"' +
             (active ? ' aria-current="page"' : '') + '>' + n.label + '</a>';
    }).join('');
  }

  /* ---------- HEADER ---------- */
  var header = document.getElementById('site-header');
  if (header) {
    header.innerHTML = '' +
      '<div class="sticky top-0 z-50">' +
        '<div class="mx-auto max-w-content px-5">' +
          '<nav class="mt-3 flex items-center justify-between rounded-full border border-line bg-white/80 px-4 py-2.5 shadow-warm-sm backdrop-blur-md">' +
            '<a href="index.html" aria-label="SunMates, accueil">' + LOGO + '</a>' +
            '<div class="hidden items-center gap-7 md:flex">' + navLinks() + '</div>' +
            '<div class="flex items-center gap-2">' +
              '<a href="' + APP_URL + '" class="hidden rounded-full bg-sunset px-5 py-2.5 text-sm font-bold text-white shadow-glow lift sm:inline-block">Ouvrir l\'app</a>' +
              '<button id="burger" class="grid h-10 w-10 place-items-center rounded-full border border-line bg-white text-ink md:hidden" aria-label="Menu" aria-expanded="false">' +
                '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M4 7h16M4 12h16M4 17h16"/></svg>' +
              '</button>' +
            '</div>' +
          '</nav>' +
          '<div id="mobile-menu" class="mt-2 hidden flex-col gap-1 rounded-2xl border border-line bg-white/95 p-3 shadow-warm backdrop-blur-md md:hidden">' +
            navLinks('block rounded-xl px-3 py-2.5 hover:bg-coral-soft') +
            '<a href="' + APP_URL + '" class="mt-1 block rounded-xl bg-sunset px-3 py-3 text-center font-bold text-white">Ouvrir l\'app</a>' +
          '</div>' +
        '</div>' +
      '</div>';

    var burger = document.getElementById('burger');
    var menu = document.getElementById('mobile-menu');
    if (burger && menu) {
      burger.addEventListener('click', function () {
        var open = menu.classList.toggle('hidden') === false;
        menu.classList.toggle('flex', open);
        burger.setAttribute('aria-expanded', String(open));
      });
    }
  }

  /* ---------- FOOTER ---------- */
  var footer = document.getElementById('site-footer');
  if (footer) {
    var year = document.body.getAttribute('data-year') || '2026';
    footer.innerHTML = '' +
      '<div class="mx-auto max-w-content px-5 pb-10 pt-16">' +
        '<div class="card-soft overflow-hidden">' +
          '<div class="grid gap-8 p-8 md:grid-cols-[1.4fr_1fr_1fr] md:p-10">' +
            '<div>' + LOGO +
              '<p class="mt-4 max-w-xs text-sm leading-relaxed text-muted">Rencontrer le monde en voyageant solo, sans jamais sacrifier sa sécurité. La chaleur d\'un coucher de soleil, la confiance d\'un lieu sûr.</p>' +
            '</div>' +
            '<div>' +
              '<p class="mb-3 text-xs font-bold uppercase tracking-wide text-coral-ink">Naviguer</p>' +
              '<ul class="space-y-2 text-sm text-body">' +
                NAV.map(function (n) { return '<li><a href="' + n.href + '" class="lnk hover:text-ink">' + n.label + '</a></li>'; }).join('') +
              '</ul>' +
            '</div>' +
            '<div>' +
              '<p class="mb-3 text-xs font-bold uppercase tracking-wide text-coral-ink">Commencer</p>' +
              '<a href="' + APP_URL + '" class="inline-block rounded-full bg-sunset px-5 py-2.5 text-sm font-bold text-white shadow-glow lift">Essayer SunMates</a>' +
              '<p class="mt-4 text-xs text-muted">Web app gratuite · installable · FR / EN</p>' +
            '</div>' +
          '</div>' +
          '<div class="flex flex-col items-center justify-between gap-2 border-t border-line px-8 py-5 text-xs text-muted sm:flex-row md:px-10">' +
            '<span>© ' + year + ' SunMates — Sécurité d\'abord, toujours.</span>' +
            '<span>Fait avec ☀️ pour les voyageurs solo.</span>' +
          '</div>' +
        '</div>' +
      '</div>';
  }

  /* ---------- Reveals au scroll (GSAP) — dégradation propre ---------- */
  function initMotion() {
    var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    // Filet de sécurité : si aucune anim n'est possible, on retire la classe qui cache
    // → le contenu reste visible. Toutes les animations (reveals + fx) vivent dans fx.js.
    if (reduce || !window.gsap) {
      document.documentElement.classList.remove('js-anim');
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initMotion);
  } else {
    initMotion();
  }
})();
