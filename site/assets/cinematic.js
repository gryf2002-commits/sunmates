/* SunMates — moteur CINÉMATIQUE (GSAP + ScrollTrigger).
   Scroll qui raconte, scènes qui respirent (ken burns), parallaxe, lens flare,
   compteurs, boutons magnétiques, confettis sonores. Coupe tout si reduced-motion. */
(function () {
  'use strict';
  var REDUCE = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function ready(fn) {
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', fn);
    else fn();
  }

  ready(function () {
    /* --- Autoplay vidéo robuste (certains navigateurs exigent un coup de pouce) --- */
    document.querySelectorAll('video[data-bg]').forEach(function (v) {
      v.muted = true; v.playsInline = true;
      var p = v.play && v.play();
      if (p && p.catch) p.catch(function () {/* le poster reste affiché, pas grave */});
    });

    /* --- Barre de progression + rail de chapitres (sans dépendance GSAP) --- */
    (function () {
      var acts = [].slice.call(document.querySelectorAll('[data-act]'));
      var bar = document.createElement('div'); bar.className = 'cine-progress'; document.body.appendChild(bar);
      function onScroll() {
        var h = document.documentElement.scrollHeight - window.innerHeight;
        bar.style.width = (h > 0 ? (window.scrollY / h) * 100 : 0) + '%';
      }
      window.addEventListener('scroll', onScroll, { passive: true }); onScroll();
      if (!acts.length) return;
      var rail = document.createElement('nav'); rail.className = 'chapter-rail'; rail.setAttribute('aria-label', 'Chapitres');
      var links = acts.map(function (s) {
        var a = document.createElement('a'); a.href = '#' + s.id;
        a.innerHTML = '<span class="lbl">' + s.getAttribute('data-act') + ' · ' + s.getAttribute('data-act-name') + '</span><span class="dot"></span>';
        rail.appendChild(a); return a;
      });
      document.body.appendChild(rail);
      if ('IntersectionObserver' in window) {
        var io = new IntersectionObserver(function (ents) {
          ents.forEach(function (e) {
            var i = acts.indexOf(e.target);
            if (e.isIntersecting && i > -1) { links.forEach(function (l) { l.classList.remove('active'); }); links[i].classList.add('active'); }
          });
        }, { rootMargin: '-45% 0px -45% 0px', threshold: 0 });
        acts.forEach(function (s) { io.observe(s); });
      }
    })();

    var gsap = window.gsap;
    if (REDUCE || !gsap) return; // contenu visible (géré par site.js)
    var ST = window.ScrollTrigger;
    if (ST) gsap.registerPlugin(ST);

    /* --- Intro du hero --- */
    var heroEls = gsap.utils.toArray('.cine-hero-el');
    if (heroEls.length) {
      gsap.set(heroEls, { opacity: 0, y: 32, filter: 'blur(6px)' });
      gsap.to(heroEls, { opacity: 1, y: 0, filter: 'blur(0px)', duration: 1, stagger: 0.16, ease: 'power3.out', delay: 0.3 });
    }

    /* --- Scènes : parallaxe + ken burns (ça respire) + révélation du texte --- */
    gsap.utils.toArray('.scene').forEach(function (sc) {
      var bg = sc.querySelector('.scene-bg, .scene-media');
      if (bg) {
        if (ST) {
          gsap.fromTo(bg, { yPercent: -6 }, {
            yPercent: 6, ease: 'none',
            scrollTrigger: { trigger: sc, start: 'top bottom', end: 'bottom top', scrub: true },
          });
        }
        gsap.to(bg, { scale: 1.12, duration: 20, ease: 'sine.inOut', yoyo: true, repeat: -1 });
      }
      var txt = sc.querySelectorAll('.cine-reveal');
      if (txt.length) {
        if (ST) {
          ST.create({
            trigger: sc, start: 'top 62%', once: true,
            onEnter: function () { gsap.to(txt, { opacity: 1, y: 0, filter: 'blur(0px)', duration: 0.9, stagger: 0.13, ease: 'power2.out' }); },
          });
        } else {
          gsap.to(txt, { opacity: 1, y: 0, duration: 0.8, stagger: 0.1 });
        }
      }
    });

    /* --- Soleils flottants [data-float] --- */
    gsap.utils.toArray('[data-float]').forEach(function (el, i) {
      gsap.to(el, { y: '+=14', rotation: (i % 2 ? 4 : -4), duration: 2.4 + (i % 3) * 0.5, ease: 'sine.inOut', yoyo: true, repeat: -1, delay: i * 0.2 });
    });

    /* --- Compteurs [data-count] --- */
    gsap.utils.toArray('[data-count]').forEach(function (el) {
      var end = parseFloat(el.getAttribute('data-count'));
      var suffix = el.getAttribute('data-suffix') || '';
      var o = { v: 0 };
      var run = function () { gsap.to(o, { v: end, duration: 1.8, ease: 'power2.out', onUpdate: function () { el.textContent = Math.round(o.v) + suffix; } }); };
      if (ST) ST.create({ trigger: el, start: 'top 85%', once: true, onEnter: run });
      else run();
    });

    /* --- Boutons magnétiques [data-magnetic] --- */
    gsap.utils.toArray('[data-magnetic]').forEach(function (el) {
      el.addEventListener('mousemove', function (e) {
        var r = el.getBoundingClientRect();
        gsap.to(el, { x: (e.clientX - r.left - r.width / 2) * 0.3, y: (e.clientY - r.top - r.height / 2) * 0.45, duration: 0.4, ease: 'power2.out' });
      });
      el.addEventListener('mouseleave', function () { gsap.to(el, { x: 0, y: 0, duration: 0.6, ease: 'elastic.out(1,0.4)' }); });
    });

    /* --- Lens flare qui dérive au scroll --- */
    if (ST) {
      var flare = document.querySelector('.flare');
      if (flare) gsap.to(flare, { yPercent: 40, ease: 'none', scrollTrigger: { start: 0, end: 'max', scrub: true } });
    }

    /* --- Indice de scroll qui s'efface --- */
    var cue = document.querySelector('.scroll-cue');
    if (cue && ST) gsap.to(cue, { opacity: 0, scrollTrigger: { start: 60, end: 220, scrub: true } });

    /* --- Confettis-soleils sonores [data-confetti] --- */
    var EMO = ['☀️', '🌅', '💛', '⭐', '✨', '🧡', '🌞'];
    var layer = null;
    function L() { if (!layer) { layer = document.createElement('div'); layer.style.cssText = 'position:fixed;inset:0;pointer-events:none;z-index:9999;overflow:hidden'; document.body.appendChild(layer); } return layer; }
    function burst(x, y) {
      if (window.SunMatesAudio) window.SunMatesAudio.fx('pop');
      var lay = L();
      for (var i = 0; i < 28; i++) {
        var s = document.createElement('span');
        s.textContent = EMO[(Math.floor(x) + i) % EMO.length];
        s.style.cssText = 'position:absolute;left:' + x + 'px;top:' + y + 'px;font-size:' + (14 + (i % 4) * 6) + 'px;will-change:transform,opacity';
        lay.appendChild(s);
        var ang = (Math.PI * 2 * i) / 28 + (i % 5) * 0.2, dist = 130 + (i % 6) * 42;
        gsap.to(s, { x: Math.cos(ang) * dist, y: Math.sin(ang) * dist + 150 + (i % 5) * 30, rotation: (i % 2 ? 1 : -1) * (180 + i * 12), opacity: 0, scale: 0.6 + (i % 3) * 0.3, duration: 1.2 + (i % 4) * 0.25, ease: 'power2.out', onComplete: function () { this.targets()[0].remove(); } });
      }
    }
    gsap.utils.toArray('[data-confetti]').forEach(function (el) {
      el.addEventListener('click', function () { var r = el.getBoundingClientRect(); burst(r.left + r.width / 2, r.top + r.height / 2); });
    });
  });
})();
