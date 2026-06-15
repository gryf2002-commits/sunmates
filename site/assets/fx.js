/* SunMates — moteur d'animation « zinzin » (GSAP).
   Voyage × rencontre × fun. 100% désactivé si prefers-reduced-motion.
   site.js gère le filet de sécurité (retire .js-anim si pas d'anim → contenu visible). */
(function () {
  'use strict';

  var REDUCE = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function ready(fn) {
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', fn);
    else fn();
  }

  ready(function () {
    var gsap = window.gsap;
    if (REDUCE || !gsap) return; // tout reste visible (géré par site.js)
    var ST = window.ScrollTrigger;
    if (ST) gsap.registerPlugin(ST);

    /* ---------- 1. Reveals au scroll (.reveal) ---------- */
    if (ST) {
      ST.batch('.reveal', {
        start: 'top 90%',
        onEnter: function (els) {
          gsap.to(els, { opacity: 1, y: 0, duration: 0.62, stagger: 0.08, ease: 'power2.out', overwrite: true });
        },
      });
    } else {
      gsap.to('.reveal', { opacity: 1, y: 0, duration: 0.6, stagger: 0.05 });
    }

    /* ---------- 2. Timeline d'entrée du hero (.fx-hero, dans l'ordre) ---------- */
    var heroEls = gsap.utils.toArray('.fx-hero');
    if (heroEls.length) {
      gsap.set(heroEls, { opacity: 0, y: 34 });
      gsap.to(heroEls, { opacity: 1, y: 0, duration: 0.8, stagger: 0.12, ease: 'power3.out', delay: 0.15 });
    }

    /* ---------- 3. Joyaux flottants [data-float] ---------- */
    gsap.utils.toArray('[data-float]').forEach(function (el, i) {
      gsap.to(el, {
        y: '+=16', rotation: (i % 2 ? 4 : -4),
        duration: 2.3 + (i % 3) * 0.5, ease: 'sine.inOut',
        yoyo: true, repeat: -1, delay: i * 0.18,
      });
    });

    /* ---------- 4. Parallaxe au scroll [data-parallax="0.25"] ---------- */
    if (ST) {
      gsap.utils.toArray('[data-parallax]').forEach(function (el) {
        var amt = parseFloat(el.getAttribute('data-parallax')) || 0.2;
        gsap.to(el, {
          yPercent: -amt * 100, ease: 'none',
          scrollTrigger: { trigger: el.closest('section') || el, start: 'top bottom', end: 'bottom top', scrub: true },
        });
      });
    }

    /* ---------- 5. Compteurs animés [data-count="42"][data-suffix="…"] ---------- */
    gsap.utils.toArray('[data-count]').forEach(function (el) {
      var end = parseFloat(el.getAttribute('data-count'));
      var suffix = el.getAttribute('data-suffix') || '';
      var prefix = el.getAttribute('data-prefix') || '';
      var o = { v: 0 };
      var tw = function () {
        gsap.to(o, { v: end, duration: 1.7, ease: 'power2.out', onUpdate: function () { el.textContent = prefix + Math.round(o.v) + suffix; } });
      };
      if (ST) ST.create({ trigger: el, start: 'top 88%', once: true, onEnter: tw });
      else tw();
    });

    /* ---------- 6. Boutons magnétiques [data-magnetic] ---------- */
    gsap.utils.toArray('[data-magnetic]').forEach(function (el) {
      el.addEventListener('mousemove', function (e) {
        var r = el.getBoundingClientRect();
        gsap.to(el, { x: (e.clientX - r.left - r.width / 2) * 0.3, y: (e.clientY - r.top - r.height / 2) * 0.45, duration: 0.4, ease: 'power2.out' });
      });
      el.addEventListener('mouseleave', function () {
        gsap.to(el, { x: 0, y: 0, duration: 0.6, ease: 'elastic.out(1,0.4)' });
      });
    });

    /* ---------- 7. Cartes 3D inclinables [data-tilt] ---------- */
    gsap.utils.toArray('[data-tilt]').forEach(function (el) {
      el.addEventListener('mousemove', function (e) {
        var r = el.getBoundingClientRect();
        var px = (e.clientX - r.left) / r.width - 0.5;
        var py = (e.clientY - r.top) / r.height - 0.5;
        gsap.to(el, { rotationY: px * 9, rotationX: -py * 9, transformPerspective: 850, transformOrigin: 'center', duration: 0.4, ease: 'power2.out' });
      });
      el.addEventListener('mouseleave', function () {
        gsap.to(el, { rotationX: 0, rotationY: 0, duration: 0.6, ease: 'power3.out' });
      });
    });

    /* ---------- 8. Confettis-soleils maison [data-confetti] ---------- */
    var EMO = ['☀️', '🌅', '💛', '⭐', '✨', '🧡', '🌞'];
    var layer = null;
    function confettiLayer() {
      if (!layer) {
        layer = document.createElement('div');
        layer.style.cssText = 'position:fixed;inset:0;pointer-events:none;z-index:9999;overflow:hidden';
        document.body.appendChild(layer);
      }
      return layer;
    }
    function burst(x, y) {
      if (window.SunMatesAudio) window.SunMatesAudio.fx('pop');
      var L = confettiLayer();
      for (var i = 0; i < 26; i++) {
        var s = document.createElement('span');
        s.textContent = EMO[(Math.floor(x) + i) % EMO.length];
        s.style.cssText = 'position:absolute;left:' + x + 'px;top:' + y + 'px;font-size:' + (14 + (i % 4) * 6) + 'px;will-change:transform,opacity';
        L.appendChild(s);
        var ang = (Math.PI * 2 * i) / 26 + (i % 5) * 0.2;
        var dist = 120 + (i % 6) * 40;
        gsap.to(s, {
          x: Math.cos(ang) * dist, y: Math.sin(ang) * dist + 140 + (i % 5) * 30,
          rotation: (i % 2 ? 1 : -1) * (180 + i * 12), opacity: 0, scale: 0.6 + (i % 3) * 0.3,
          duration: 1.1 + (i % 4) * 0.25, ease: 'power2.out',
          onComplete: function () { this.targets()[0].remove(); },
        });
      }
    }
    gsap.utils.toArray('[data-confetti]').forEach(function (el) {
      el.addEventListener('click', function () {
        var r = el.getBoundingClientRect();
        burst(r.left + r.width / 2, r.top + r.height / 2);
      });
    });
    // petite salve d'accueil sur le premier [data-confetti-auto]
    var auto = document.querySelector('[data-confetti-auto]');
    if (auto) {
      var r = auto.getBoundingClientRect();
      gsap.delayedCall(0.8, function () { burst(r.left + r.width / 2, r.top + r.height / 2); });
    }

    /* ---------- 9. Galerie destinations : scroll horizontal au scroll vertical [data-hscroll] ---------- */
    if (ST) {
      gsap.utils.toArray('[data-hscroll]').forEach(function (track) {
        var dist = track.scrollWidth - track.parentElement.offsetWidth;
        if (dist > 40) {
          gsap.to(track, {
            x: -dist, ease: 'none',
            scrollTrigger: { trigger: track.closest('section'), start: 'top 70%', end: '+=' + dist, scrub: 0.6 },
          });
        }
      });
    }
  });
})();
