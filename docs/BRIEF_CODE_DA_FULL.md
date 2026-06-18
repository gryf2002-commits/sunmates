# SunMates DA — BRIEF COMPLET pour `code` (déploiement + couverture 100% + console)

> Objectif : que TOUTE l'app suive la DA choisie dans la console (aucun élément figé), console
> pilotable in-app (admin only). Vérifié en live : le moteur recolore bien l'app via variables-cœur ;
> reste à (1) déployer, (2) convertir les couleurs encore en dur, (3) brancher la console admin.

## 0. ÉTAT RÉEL (sondé en live sur sunmatesapp.com)
- La prod ne charge que `sunmates-badges.js` + `sunmates-icons-v2.js?v=541`.
- **PAS de `sunmates-da-loader.js`** → `window.SMDA` undefined, `#sm-da-vars` absent.
- `window.goToTab` ✓, `window.SMIcon` ✓. `window.myProfile`/`window.isAdmin` = NON exposés (vars internes).
- ⇒ Rien de DA n'est en ligne. C'est le blocage n°1.

## 1. À DÉPLOYER (ordre)
1. `sunmates-icons-v2.js` (recolorable + SMIconize) → tag `?v=542`.
2. `sunmates-da-loader.js` + **ajouter le tag** en fin de `<body>` d'`index.html` (après le script app) :
   `<script src="sunmates-da-loader.js?v=5"></script>` (expose `window.SMDA`).
3. Exposer sur window : `window.myProfile = myProfile;` `window.isAdmin = isAdmin;` (garder `window.goToTab`).
4. `da-console-overlay.js` → tag admin-gated : `<script src="da-console-overlay.js?v=1"></script>`
   (bouton ✦ DA visible seulement si `isAdmin()`). Bouton « Ouvrir console » à laisser dans Profil→Admin→DA.
5. Supabase : lancer `sunmates-da-history.sql` (table `da_history` versions/rollback). RLS admin déjà OK.
6. **Bumper `VER` dans `sw.js`**.

## 2. ANTI-TRONCATURE (vérifier avant commit)
- `index.html` finit par `getSession().then(render)` → `</script>` → tag loader → `</body></html>`.
- `da-console.html` finit par `</body></html>` (pas en plein `function advRefresh(){var m=T.modes[curM`).
- `node --check` sur le DERNIER `<script>` de chaque fichier (pas un bloc antérieur).

## 3. CONTRAT DE TOKENS (T)
modes{j1,j2,j3,angle,page,ink,class,label,trigger} · iconColors · iconColorsByMode · glyph ·
icon{style,colorMode,mono,perMode} · sizes{tile,iconTile,inline} ·
effects{radius,shape,keyline,sheen,polish,mirror,shadow} · fonts{heading,body} ·
a11y{fontScale,reduceMotion} · texts[cat]{label,meta} · globalTexts · badges{4 familles[clair,foncé]} ·
logos · logoChoice · scenes{confetti,saison,accent} · rewards[] · typo{titleSize,titleColor,bodyColor,metaColor} ·
comp{btnText,chipText} · emoji{off,keepNative} · appIcon{c1,c2,glyph} · imgBank ·
**NOUVEAU** grads{accent,sunset} · overrides{ "mode||selector":{j1,j2,shape} } · device.

## 4. LOADER — ce qu'il applique déjà + EXTENSIONS à ajouter
Déjà : variables-cœur par mode (--bg,--ink,--text,--muted,--line,--card,--cream,--accent,--accent-2/3,
--accent-grad,--accent-soft,--ring), joyaux (--ic1/--ic2 sur cic/jo-ic/qm-ic/sc-ic/smgem/thumb),
emblèmes (--icc + colorMode natural/mono), style natif, tailles vars, polices, typo, effets, emoji.
À AJOUTER pour 100% :
- **--accent-grad / --sunset-grad** dérivés des joyaux (déjà partiel : confirmer --sunset-grad).
- **Badges** : poser les 4 dégradés (`.hex`, `.hex.grad-violet/.grad-gold/.grad-teal`, médaillons SMBadge)
  depuis `badges{}`.
- **comp.btnText/chipText**, **logos[mode]** (--sm-logo réellement consommé).
- **overrides ciblés** : injecter `body.<modeclass> <selector>{--ic1/--ic2/background-image}` depuis `overrides`.
- **epin (marqueurs carte)** : la couleur est posée en JS inline (pas var) → exposer un hook
  `window.SM_EPIN_COLOR(cat,mode)` lu par `epinIcon()` (L15422) au lieu du `bg` codé.

## 5. index.html — COULEURS ENCORE EN DUR à convertir (→ var) — observé EN LIVE + audit source
Avec un preset non-sunset, ces classes restent figées (occurrences live entre parenthèses) :
- **.vchip / .vchip.lg** (×34) L1488 → `var(--accent-grad)`.
- **.pcard-chip.pcard-top** (×8) L666, **.pcard-rate** (×8), **.pcard-eco** L663 → `var(--accent-grad)` / accent.
- **.epin / .epin.quest / .epin-cluster** (×8) L1398-1407 → hook JS (cf. §4).
- **.gp-tile / .gp-ic** (perks Gold ×6) + **.gold-hero / .gh-price / .gh-soon / .gh-crown** L3625-3643 → var(s).
- **.pf-pct.done / .wg-bar / .wg-goal.done** (jauges ×6) → `var(--accent)` / `var(--accent-grad)`.
- **.badge.ok** (×4) L962/2767/3090/3189 → `var(--ok)`/`var(--accent-soft)`.
- **.pc-stat / .stat / .ci-count / .pr-val / .pb-pill / .player-badge.player-hud / .ph-glow / .ph-lvl-ring**
  (HUD/stats) → var(--accent*) ou --ic1/--ic2.
- **.gplay-xp** L1628, **.xp-banner**, **.rate-top** L1684, **.rate-chip** L1681 → `var(--accent-grad)`.
- **.streak-chip / .sp-streak / .sp-next / .rit-cnt / .weather-chip / .mates-stat** → var(--accent*).
- **.tpa-btn.tpa-bff** → var(--accent-grad) ; **.su-btn.su-call** = garder rouge (sémantique 112).
- **.mark-pro** L391, **.avail-chip.on/.avail-badge** L585/587, **.homemap-filters .chip.cl-*** (5) L1392-1396,
  **#profSegNav [data-pseg]** L2872-2898, **.cic.c-* / .thumb.* / .gcard .ghead.* / .qm-coral / .sc-* / .jo-ic.c-purp**
  (paires --c1/--c2 en dur) → centraliser sur --ic1/--ic2 pilotés.
- Couche **POLISH/!important** (L3176+, 3216 bottom-nav `#fff7f2`, 3267-3281 surfaces nuit) : remplacer les
  valeurs en dur par var(--…) pour ne pas écraser le loader.
> Règle : danger/SOS/blocage restent rouges (sémantique) ; tout le reste suit la DA.

## 6. CONSOLE (overlay in-app, admin)
- `da-console-overlay.js` : bouton ✦ DA (admin), panneau live (presets, palette/mode, icônes style/couleur/
  forme, tailles, polices, typo/contraste, composants, badges, logo, effets, scènes, emojis, dégradés) +
  **clic-recolor** sur tout élément (écrit `overrides`).
- À RÉINTÉGRER ensuite (depuis l'ancienne console) : glyph-picker par catégorie (288), i18n FR/EN complet,
  inventaire emojis, récompenses, icône-app/PWA, banque d'images, auto-contraste WCAG.
- **Publier** : upsert `da_tokens` (RLS admin) + `da_history` (archive) ; live = `SMDA.apply` + localStorage.
- Test rapide avant câblage admin : `sunmatesapp.com/?daforce=1` (bypass garde — retirer en prod).

## 7. CHECKLIST TEST (après déploiement, connecté ADMIN)
- Bouton ✦ DA présent ; changer de preset → fonds/textes/accents/CTA/tuiles/sidebar suivent.
- Les classes du §5 suivent enfin la DA (plus de sunset figé en mode Neon/Lagon/Cosmique).
- Marqueurs carte recolorés (hook epin). Modes ×6 OK clair/sombre. Clic-recolor d'une tuile = effet ciblé.
- Publier → visible pour tous au reload ; live-push si Realtime activé.
