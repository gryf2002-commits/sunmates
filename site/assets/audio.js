/* SunMates — moteur audio GÉNÉRATIF (Web Audio). Zéro fichier, 100% unique.
   - Soundscape vivant : nappe chaude + "vagues" (bruit filtré) + carillons aléatoires (penta).
   - Sons d'interaction : pop / tick / whoosh (appelés par fx.js).
   - JAMAIS d'autoplay : le son ne démarre qu'au clic sur le bouton (geste utilisateur).
   - Bouton flottant façon « hold music ». Respecte un mute par défaut. */
(function () {
  'use strict';

  var AC = window.AudioContext || window.webkitAudioContext;
  var ctx = null, master = null, scape = null, chimeTimer = null;
  var enabled = false, supported = !!AC;

  function ensureCtx() {
    if (ctx) return ctx;
    try {
      ctx = new AC();
      master = ctx.createGain();
      master.gain.value = 0.0001;
      // Compresseur + makeup gain : son plein et fort, sans saturer
      var comp = ctx.createDynamicsCompressor();
      comp.threshold.value = -20; comp.ratio.value = 3; comp.attack.value = 0.008; comp.release.value = 0.25;
      var outGain = ctx.createGain(); outGain.gain.value = 1.5;
      master.connect(comp); comp.connect(outGain); outGain.connect(ctx.destination);
    } catch (e) { supported = false; }
    return ctx;
  }

  /* ---------- bruit blanc réutilisable ---------- */
  function noiseBuffer() {
    var len = ctx.sampleRate * 2;
    var buf = ctx.createBuffer(1, len, ctx.sampleRate);
    var d = buf.getChannelData(0);
    for (var i = 0; i < len; i++) d[i] = Math.random() * 2 - 1;
    return buf;
  }

  /* ---------- la nappe + les vagues ---------- */
  function startScape() {
    if (scape) return;
    var now = ctx.currentTime;
    scape = { nodes: [] };

    // Nappe : accord majeur chaud, oscillos doux à travers un lowpass + LFO lent
    var chord = [110, 164.81, 220, 277.18]; // A2 E3 A3 C#4
    var padGain = ctx.createGain(); padGain.gain.value = 0.0; padGain.connect(master);
    var lp = ctx.createBiquadFilter(); lp.type = 'lowpass'; lp.frequency.value = 1150; lp.Q.value = 0.7; lp.connect(padGain);
    var lfo = ctx.createOscillator(); lfo.frequency.value = 0.06;
    var lfoG = ctx.createGain(); lfoG.gain.value = 520; lfo.connect(lfoG); lfoG.connect(lp.frequency); lfo.start();
    chord.forEach(function (f, i) {
      var o = ctx.createOscillator(); o.type = i % 2 ? 'sine' : 'triangle';
      o.frequency.value = f; o.detune.value = (i - 1.5) * 6;
      var g = ctx.createGain(); g.gain.value = 0.30 / chord.length;
      o.connect(g); g.connect(lp); o.start();
      scape.nodes.push(o);
    });
    padGain.gain.setTargetAtTime(0.78, now, 2.5);
    scape.nodes.push(lfo);

    // Vagues : bruit filtré, amplitude qui respire
    var src = ctx.createBufferSource(); src.buffer = noiseBuffer(); src.loop = true;
    var bp = ctx.createBiquadFilter(); bp.type = 'lowpass'; bp.frequency.value = 480; bp.Q.value = 0.7;
    var wGain = ctx.createGain(); wGain.gain.value = 0.0;
    src.connect(bp); bp.connect(wGain); wGain.connect(master);
    var wlfo = ctx.createOscillator(); wlfo.frequency.value = 0.09;
    var wlfoG = ctx.createGain(); wlfoG.gain.value = 0.07; wlfo.connect(wlfoG); wlfoG.connect(wGain.gain); wlfo.start();
    wGain.gain.setTargetAtTime(0.12, now, 3.5);
    src.start();
    scape.nodes.push(src, wlfo);

    // Carillons : gamme pentatonique, déclenchés au hasard
    var penta = [440, 493.88, 554.37, 659.25, 739.99];
    function chime() {
      if (!enabled) return;
      var f = penta[Math.floor(Math.random() * penta.length)] * (Math.random() < 0.3 ? 2 : 1);
      var t = ctx.currentTime;
      var o = ctx.createOscillator(); o.type = 'sine'; o.frequency.value = f;
      var g = ctx.createGain(); g.gain.value = 0.0;
      var pan = ctx.createStereoPanner ? ctx.createStereoPanner() : null;
      if (pan) { pan.pan.value = Math.random() * 1.4 - 0.7; o.connect(g); g.connect(pan); pan.connect(master); }
      else { o.connect(g); g.connect(master); }
      g.gain.setValueAtTime(0.0, t);
      g.gain.linearRampToValueAtTime(0.17, t + 0.02);
      g.gain.exponentialRampToValueAtTime(0.0001, t + 2.6);
      o.start(t); o.stop(t + 2.8);
      chimeTimer = setTimeout(chime, 3500 + Math.random() * 6000);
    }
    chimeTimer = setTimeout(chime, 2500);
  }

  function on() {
    if (!supported) return;
    ensureCtx();
    if (!ctx) return;
    if (ctx.state === 'suspended') ctx.resume();
    enabled = true;
    startScape();
    master.gain.cancelScheduledValues(ctx.currentTime);
    master.gain.setTargetAtTime(0.62, ctx.currentTime, 1.0);
    updateBtn();
  }
  function off() {
    enabled = false;
    if (master && ctx) master.gain.setTargetAtTime(0.0001, ctx.currentTime, 0.6);
    if (chimeTimer) clearTimeout(chimeTimer);
    updateBtn();
  }
  function toggle() { enabled ? off() : on(); }

  /* ---------- sons d'interaction (uniquement si le son est activé) ---------- */
  function blip(type) {
    if (!enabled || !ctx) return;
    var t = ctx.currentTime, o = ctx.createOscillator(), g = ctx.createGain();
    o.connect(g); g.connect(master);
    if (type === 'pop') {
      o.type = 'sine'; o.frequency.setValueAtTime(640, t); o.frequency.exponentialRampToValueAtTime(180, t + 0.18);
      g.gain.setValueAtTime(0.18, t); g.gain.exponentialRampToValueAtTime(0.0001, t + 0.22); o.start(t); o.stop(t + 0.24);
    } else if (type === 'tick') {
      o.type = 'triangle'; o.frequency.value = 1180;
      g.gain.setValueAtTime(0.07, t); g.gain.exponentialRampToValueAtTime(0.0001, t + 0.06); o.start(t); o.stop(t + 0.07);
    } else { // whoosh
      var src = ctx.createBufferSource(); src.buffer = noiseBuffer();
      var bp = ctx.createBiquadFilter(); bp.type = 'bandpass'; bp.Q.value = 0.8;
      bp.frequency.setValueAtTime(300, t); bp.frequency.exponentialRampToValueAtTime(1800, t + 0.25);
      var ng = ctx.createGain(); ng.gain.setValueAtTime(0.12, t); ng.gain.exponentialRampToValueAtTime(0.0001, t + 0.32);
      src.connect(bp); bp.connect(ng); ng.connect(master); src.start(t); src.stop(t + 0.34);
      return;
    }
  }

  /* ---------- bouton flottant ---------- */
  var btn = null;
  function updateBtn() {
    if (!btn) return;
    btn.setAttribute('aria-pressed', String(enabled));
    btn.querySelector('[data-eq]').classList.toggle('playing', enabled);
    btn.querySelector('[data-label]').textContent = enabled ? 'Ambiance' : 'Son coupé';
  }
  function mountBtn() {
    btn = document.createElement('button');
    btn.id = 'sm-sound';
    btn.type = 'button';
    btn.setAttribute('aria-pressed', 'false');
    btn.setAttribute('aria-label', "Activer l'ambiance sonore");
    btn.innerHTML =
      '<span data-eq class="sm-eq"><i></i><i></i><i></i><i></i></span>' +
      '<span data-label>Son coupé</span>';
    btn.addEventListener('click', toggle);
    document.body.appendChild(btn);
    if (!supported) { btn.disabled = true; btn.querySelector('[data-label]').textContent = 'Son indispo'; }
  }

  // expose pour fx.js
  window.SunMatesAudio = { toggle: toggle, on: on, off: off, fx: blip, isOn: function () { return enabled; } };

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', mountBtn);
  else mountBtn();
})();
