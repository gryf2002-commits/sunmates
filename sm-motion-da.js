/* ════════════════════════════════════════════════════════════════════════════
   SUNMATES · DA DE MOTION — « Le mouvement du couchant »
   Source de vérité du langage de mouvement de SunMates. Utilisable dans le
   showcase (motion-da.html) ET dans l'app réelle. Dépend de GSAP (+ Flip).
   Tout est best-effort : si GSAP absent → no-op (l'app marche sans motion).

   ── PERSONNALITÉ (7 principes) ──────────────────────────────────────────────
   1. DÉCÉLÉRATION CHAUDE   — l'action arrive vite et se POSE en douceur
                              (ease-out dominant, comme le soleil qui descend).
   2. POIDS DE JOYAU        — les objets s'installent avec un léger dépassement
                              maîtrisé (back.out) ; jamais d'élastique criard,
                              sauf pour la CÉLÉBRATION.
   3. LUMIÈRE QUI GLISSE    — les surfaces-joyaux captent un reflet en mouvement.
   4. CASCADE ORCHESTRÉE    — les éléments entrent en chœur (stagger), jamais en bloc.
   5. CONTINUITÉ SPATIALE   — on ne coupe pas, on TRANSFORME (l'objet voyage : morph).
   6. CALME PAR DÉFAUT      — micro-interactions discrètes ; la fête est réservée
                              aux grands moments (déblocage, niveau, check-in).
   7. ZÉRO FRICTION 60FPS   — transform/opacity uniquement ; prefers-reduced-motion
                              respecté ; rien ne fige le scroll.
   ════════════════════════════════════════════════════════════════════════════ */
(function (global) {
  "use strict";
  var G = global.gsap;
  var RM = global.matchMedia && matchMedia("(prefers-reduced-motion: reduce)").matches;
  var has = !!G;

  /* ── TOKENS ──────────────────────────────────────────────────────────────── */
  var DUR = { instant: 0.12, quick: 0.22, base: 0.38, slow: 0.56, grand: 0.8 };
  var EASE = {
    out: "power3.out",          // décélération chaude (défaut)
    io: "power3.inOut",         // morph / déplacements
    in: "power3.in",            // sorties
    spring: "back.out(1.5)",    // pose avec poids de joyau
    springSoft: "back.out(1.1)",// pose discrète
    springBig: "back.out(2.2)", // entrée affirmée
    celebrate: "elastic.out(1,0.5)", // grands moments uniquement
    drawer: "cubic-bezier(.32,.72,0,1)", // feuilles/tiroirs iOS
  };
  var STAGGER = 0.06;
  var COLORS = ["#FFC93C", "#FF8A3D", "#FF5A4D", "#11B5A0", "#7A5CFF"]; // palette confetti DA

  function reduce() { return RM || !has; }
  function arr(x) { return x == null ? [] : (x.forEach ? x : (x.length != null && typeof x !== "string" ? [].slice.call(x) : [x])); }
  function nodes(sel) { return typeof sel === "string" ? [].slice.call(document.querySelectorAll(sel)) : arr(sel); }

  /* ── FONDATIONS ──────────────────────────────────────────────────────────── */

  // Apparition : rien ne surgit du néant (y + scale + opacity), en cascade chaude.
  function reveal(sel, opt) {
    opt = opt || {}; var els = nodes(sel); if (!els.length) return;
    if (reduce()) { G && G.set(els, { opacity: 1, clearProps: "all" }); return; }
    G.fromTo(els,
      { y: opt.y != null ? opt.y : 18, opacity: 0, scale: opt.scale != null ? opt.scale : 0.96 },
      { y: 0, opacity: 1, scale: 1, duration: opt.duration || DUR.slow, ease: opt.ease || EASE.spring,
        stagger: opt.stagger != null ? opt.stagger : STAGGER, delay: opt.delay || 0, clearProps: "transform" });
  }

  // Press : retour tactile (compression douce). À câbler sur pointerdown/up ou :active CSS.
  function press(sel) {
    nodes(sel).forEach(function (el) {
      el.style.transition = "transform .14s " + "cubic-bezier(.22,1,.36,1)";
      el.addEventListener("pointerdown", function () { el.style.transform = "scale(.95)"; });
      ["pointerup", "pointerleave", "pointercancel"].forEach(function (ev) {
        el.addEventListener(ev, function () { el.style.transform = ""; });
      });
    });
  }

  // Compteur qui s'incrémente (chiffres héros).
  function countUp(el, to, opt) {
    el = nodes(el)[0]; if (!el) return; opt = opt || {};
    to = Number(to) || 0;
    var fmt = function (v) { return (opt.prefix || "") + (opt.dec ? v.toFixed(opt.dec) : Math.round(v)) + (opt.suffix || ""); };
    if (reduce()) { el.textContent = fmt(to); return; }
    /* v768 : requestAnimationFrame PUR (fiable sans GSAP, qui ne se chargeait pas toujours) */
    var from = Number(opt.from || 0), dur = (opt.duration || 1.1) * 1000, start = null;
    var run = function () {
      var step = function (ts) {
        if (start === null) start = ts;
        var p = Math.min(1, (ts - start) / dur), e = 1 - Math.pow(1 - p, 2); /* power2.out */
        el.textContent = fmt(from + (to - from) * e);
        if (p < 1) requestAnimationFrame(step); else el.textContent = fmt(to);
      };
      requestAnimationFrame(step);
    };
    if (opt.delay) setTimeout(run, opt.delay * 1000); else run();
  }

  /* ── CONTINUITÉ SPATIALE (morph élément partagé) ─────────────────────────── */
  // Déplace le MÊME noeud d'un conteneur à l'autre avec une transition Flip.
  function morph(node, target, opt) {
    node = nodes(node)[0]; target = nodes(target)[0]; if (!node || !target || !global.Flip) { target && target.appendChild(node); return; }
    opt = opt || {};
    if (reduce()) { target.appendChild(node); return; }
    var st = global.Flip.getState(node);
    target.appendChild(node);
    return global.Flip.from(st, { duration: opt.duration || DUR.slow, ease: opt.ease || EASE.io, absolute: true, scale: true, onComplete: opt.onComplete });
  }

  /* ── FEEDBACK & NOTIFICATIONS ────────────────────────────────────────────── */

  // Pulse d'attention (compteur de notif, badge). 1 coup discret.
  function pop(sel) {
    var el = nodes(sel)[0]; if (!el || reduce()) return;
    G.fromTo(el, { scale: 0.4, opacity: 0 }, { scale: 1, opacity: 1, duration: DUR.slow, ease: EASE.springBig });
  }

  // Halo d'attention répété (live / SOS / présence). NE PAS abuser : signaux only.
  function pulse(sel, opt) {
    var el = nodes(sel)[0]; if (!el || reduce()) return; opt = opt || {};
    var c = opt.color || "rgba(255,90,77,.5)";
    G.fromTo(el, { boxShadow: "0 0 0 0 " + c }, { boxShadow: "0 0 0 14px rgba(255,90,77,0)",
      duration: opt.duration || 1.6, ease: "power2.out", repeat: -1 });
  }

  // Secousse d'erreur (refus, champ invalide).
  function shake(sel) {
    var el = nodes(sel)[0]; if (!el || reduce()) return;
    G.fromTo(el, { x: -8 }, { x: 0, duration: 0.5, ease: "elastic.out(1.4,0.3)" });
  }

  // Toast (entrée par le haut, sortie auto). Réutilisable pour toute notif.
  function toast(el, opt) {
    el = nodes(el)[0]; if (!el) return; opt = opt || {};
    if (reduce()) { el.style.transform = "translateY(0)"; G && G.delayedCall(opt.hold || 2.4, function () { el.style.transform = "translateY(-160%)"; }); return; }
    G.fromTo(el, { y: "-160%" }, { y: 0, duration: DUR.slow, ease: EASE.spring });
    G.to(el, { y: "-160%", duration: DUR.base, ease: EASE.in, delay: (opt.hold || 2.4) });
  }

  // Coche qui se dessine (succès). Cible un <path> SVG avec stroke-dasharray.
  function checkDraw(pathSel) {
    var p = nodes(pathSel)[0]; if (!p) return;
    var len = p.getTotalLength ? p.getTotalLength() : 40;
    p.style.strokeDasharray = len; p.style.strokeDashoffset = len;
    if (reduce()) { p.style.strokeDashoffset = 0; return; }
    G.to(p, { strokeDashoffset: 0, duration: DUR.slow, ease: EASE.out });
  }

  /* ── CÉLÉBRATION (grands moments) ────────────────────────────────────────── */
  function burst(origin, opt) {
    opt = opt || {}; if (reduce()) return;
    var o = nodes(origin)[0]; var r = o ? o.getBoundingClientRect() : { left: innerWidth / 2, top: innerHeight / 2, width: 0, height: 0 };
    var cx = r.left + r.width / 2, cy = r.top + r.height / 2, n = opt.count || 26, shape = opt.shape || "conf";
    for (var i = 0; i < n; i++) {
      var c = document.createElement("div");
      if (shape === "heart") { c.textContent = "♥"; c.style.cssText = "position:fixed;color:#FF5A4D;font-size:" + (12 + Math.random() * 12) + "px;z-index:9000;pointer-events:none;left:" + cx + "px;top:" + cy + "px"; }
      else { c.style.cssText = "position:fixed;width:9px;height:13px;border-radius:2px;z-index:9000;pointer-events:none;left:" + cx + "px;top:" + cy + "px;background:" + COLORS[i % COLORS.length]; }
      document.body.appendChild(c);
      (function (c) {
        G.to(c, { x: (Math.random() - 0.5) * (opt.spread || 300), y: -(40 + Math.random() * (opt.rise || 320)), rotation: Math.random() * 540,
          opacity: 0, duration: 0.9 + Math.random() * 0.6, ease: "power3.out", onComplete: function () { c.remove(); } });
      })(c);
    }
  }

  /* ── GAMIFICATION (jeux) ─────────────────────────────────────────────────── */

  // Remplissage d'une jauge (XP, progression). Cible un élément dont on anime width %.
  function fillBar(sel, pct, opt) {
    var el = nodes(sel)[0]; if (!el) return; opt = opt || {};
    if (reduce()) { el.style.width = pct + "%"; return; }
    G.fromTo(el, { width: (opt.from || 0) + "%" }, { width: pct + "%", duration: opt.duration || 0.9, ease: EASE.out, delay: opt.delay || 0 });
  }

  // Déblocage de badge : la médaille tombe + rebondit + reflet qui balaie.
  function unlock(sel) {
    var el = nodes(sel)[0]; if (!el || reduce()) { el && (el.style.opacity = 1); return; }
    G.timeline()
      .fromTo(el, { scale: 0, rotation: -25, opacity: 0 }, { scale: 1, rotation: 0, opacity: 1, duration: DUR.grand, ease: EASE.celebrate })
      .add(function () { shine(el); }, "-=0.2");
  }

  // Niveau supérieur : pulsation + anneau qui s'étend + burst.
  function levelUp(sel) {
    var el = nodes(sel)[0]; if (!el) return; if (!reduce()) {
      G.timeline().fromTo(el, { scale: 1 }, { scale: 1.18, duration: DUR.quick, ease: EASE.out, yoyo: true, repeat: 1 });
      burst(el, { count: 30, rise: 280 });
    }
  }

  // Reflet de lumière qui glisse sur une surface-joyau (tuile, sceau, CTA).
  function shine(sel) {
    nodes(sel).forEach(function (el) {
      if (reduce()) return;
      var gloss = document.createElement("span");
      gloss.style.cssText = "position:absolute;top:0;left:-60%;width:45%;height:100%;pointer-events:none;background:linear-gradient(105deg,transparent,rgba(255,255,255,.45),transparent);transform:skewX(-18deg)";
      var cs = getComputedStyle(el); if (cs.position === "static") el.style.position = "relative";
      if (cs.overflow === "visible") el.style.overflow = "hidden";
      el.appendChild(gloss);
      G.fromTo(gloss, { x: 0 }, { x: el.offsetWidth * 2.2, duration: 0.9, ease: "power2.inOut", onComplete: function () { gloss.remove(); } });
    });
  }

  /* ── MAP & PINS ──────────────────────────────────────────────────────────── */

  // Chute de pin (drop + rebond + ombre qui s'écrase).
  function pinDrop(sel, opt) {
    nodes(sel).forEach(function (el, i) {
      if (reduce()) { el.style.opacity = 1; return; }
      G.fromTo(el, { y: -40, opacity: 0, scale: 0.6 }, { y: 0, opacity: 1, scale: 1, duration: DUR.slow, ease: EASE.spring, delay: (opt && opt.stagger ? i * opt.stagger : 0) });
    });
  }

  // Ripple de position utilisateur (ondes concentriques).
  function ripple(sel) {
    var el = nodes(sel)[0]; if (!el || reduce()) return;
    G.fromTo(el, { scale: 0.5, opacity: 0.6 }, { scale: 2.4, opacity: 0, duration: 1.8, ease: "power2.out", repeat: -1 });
  }

  /* ── PROFONDEUR : LISTES, COFFRES, ITINÉRAIRES, PILES, UNDO ──────────────── */

  // Classement / liste qui se réordonne en place (Flip sur les enfants).
  // orderFn = comparateur appliqué aux noeuds enfants.
  function reorder(container, orderFn) {
    container = nodes(container)[0]; if (!container || !global.Flip) return;
    var items = [].slice.call(container.children);
    if (reduce()) { items.sort(orderFn).forEach(function (it) { container.appendChild(it); }); return; }
    var st = global.Flip.getState(items);
    items.sort(orderFn).forEach(function (it) { container.appendChild(it); });
    global.Flip.from(st, { duration: DUR.slow, ease: EASE.io, absolute: false, stagger: 0.04 });
  }

  // Coffre / récompense : secousse d'anticipation puis éclat (grand moment).
  function chest(sel) {
    var el = nodes(sel)[0]; if (!el) return; if (reduce()) { burst(el); return; }
    G.timeline()
      .to(el, { rotation: -7, duration: 0.07, repeat: 5, yoyo: true, ease: "sine.inOut" })
      .to(el, { rotation: 0, scale: 1.16, duration: 0.22, ease: EASE.springBig })
      .to(el, { scale: 1, duration: 0.3, ease: EASE.out })
      .add(function () { burst(el, { count: 34, rise: 300 }); shine(el); }, "-=0.25");
  }

  // Tracé d'itinéraire / trajectoire sur la carte (path SVG qui se dessine).
  function routeDraw(pathSel, opt) {
    var p = nodes(pathSel)[0]; if (!p || !p.getTotalLength) return; opt = opt || {};
    var len = p.getTotalLength();
    p.style.strokeDasharray = len; p.style.strokeDashoffset = len;
    if (reduce()) { p.style.strokeDashoffset = 0; return; }
    G.to(p, { strokeDashoffset: 0, duration: opt.duration || 1.1, ease: opt.ease || EASE.io, delay: opt.delay || 0 });
  }

  // Pile de notifications groupées qui se déploie.
  function notifStack(sel) {
    var els = nodes(sel); if (!els.length) return;
    if (reduce()) { G && G.set(els, { opacity: 1, y: 0, scale: 1 }); return; }
    G.fromTo(els, { y: function (i) { return -i * 7; }, scale: function (i) { return 1 - i * 0.05; }, opacity: 0 },
      { y: 0, scale: 1, opacity: 1, duration: DUR.slow, ease: EASE.spring, stagger: 0.07 });
  }

  // Toast UNDO avec compte à rebours (anneau SVG qui se vide pendant `hold`).
  function undo(toastEl, ringSel, opt) {
    opt = opt || {}; toast(toastEl, opt);
    var r = nodes(ringSel)[0]; if (!r || !r.getTotalLength || reduce()) return;
    var len = r.getTotalLength(); r.style.strokeDasharray = len;
    G.fromTo(r, { strokeDashoffset: 0 }, { strokeDashoffset: len, duration: opt.hold || 3, ease: "none" });
  }

  /* ── SIGNATURES PAR FEATURE (compositions « waouh ») ─────────────────────── */

  // CHECK-IN : pulse de validation → coche tracée → confettis → +points (countUp).
  function checkIn(opt) {
    opt = opt || {}; var origin = opt.origin, check = opt.check, points = opt.points, to = opt.to || 10;
    if (check) checkDraw(check);
    burst(origin, { count: 28, rise: 300 });
    if (points) countUp(points, to, { prefix: "+", suffix: opt.suffix || "", delay: 0.2 });
  }

  // SOS : anneau d'urgence qui pulse fort (signal de sécurité, rouge protégé).
  function sos(sel) {
    var el = nodes(sel)[0]; if (!el || reduce()) return;
    G.fromTo(el, { boxShadow: "0 0 0 0 rgba(240,56,78,.6)" },
      { boxShadow: "0 0 0 22px rgba(240,56,78,0)", duration: 1.2, ease: "power2.out", repeat: -1 });
  }

  // DÉBLOCAGE DE CONFIANCE : le sceau s'illumine (reflet) + le score s'incrémente.
  function trustReveal(sealSel, scoreSel, to) {
    var seal = nodes(sealSel)[0]; if (seal && !reduce()) { G.fromTo(seal, { scale: 0.8, opacity: 0 }, { scale: 1, opacity: 1, duration: DUR.grand, ease: EASE.celebrate }); shine(seal); }
    if (scoreSel != null) countUp(scoreSel, to, { delay: 0.25 });
  }

  /* ── EXPORT ──────────────────────────────────────────────────────────────── */
  global.SM_MOTION = {
    DUR: DUR, EASE: EASE, STAGGER: STAGGER, COLORS: COLORS, reduce: reduce,
    reveal: reveal, press: press, countUp: countUp, morph: morph,
    pop: pop, pulse: pulse, shake: shake, toast: toast, checkDraw: checkDraw,
    burst: burst, fillBar: fillBar, unlock: unlock, levelUp: levelUp, shine: shine,
    pinDrop: pinDrop, ripple: ripple,
    reorder: reorder, chest: chest, routeDraw: routeDraw, notifStack: notifStack, undo: undo,
    checkIn: checkIn, sos: sos, trustReveal: trustReveal,
  };
})(window);
