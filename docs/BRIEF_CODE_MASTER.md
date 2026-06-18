# SunMates DA — BRIEF MASTER pour `code` (unique, à jour, complet)

> ⚠️ **MODE PREVIEW-FIRST (règle en vigueur depuis le 15/06/2026)** ⚠️
> On travaille **UNIQUEMENT dans `preview.html`** pour les prochaines sessions.
> - Aucune modif directe sur `index.html` (la prod). Tout passe d'abord par `preview.html`.
> - **Aucun `git push`** tant que Maxime n'a pas dit « OK pour tout le monde ». On pousse seulement quand il est satisfait.
> - Là où ce brief dit « déployer / pousser », lire « appliquer dans preview.html et faire valider ».
> - **Décompte des versions maintenu même en preview** (le n° visible = `sunmates-badges.js?v=NNN`).
> - **Snapshots `releases/` : un seul tous les 30** (jalons). Derniers gardés : …450, **480**, prochain à garder = **510**. Les intermédiaires (481→497) ont été supprimés le 15/06 (récupérables via git si besoin).

> Tout pour : déployer la DA, faire que 100% de l'app suive le preset choisi, et brancher la
> console pilotable in-app (admin only). Basé sur l'audit du code + un scan EN LIVE de l'app.
> Fichiers concernés : index.html, sunmates-da-loader.js, sunmates-icons-v2.js, da-console-overlay.js,
> da-console.html (ancienne console), sunmates-da-history.sql, sw.js.

====================================================================
## 0. ÉTAT RÉEL (sondé en live sur sunmatesapp.com)
- La prod ne charge que `sunmates-badges.js` + `sunmates-icons-v2.js?v=541`.
- **PAS de `sunmates-da-loader.js`** → `window.SMDA` undefined, `#sm-da-vars` absent.
- `window.goToTab` ✓, `window.SMIcon` ✓. `window.myProfile`/`window.isAdmin` NON exposés (vars internes).
- ⇒ Rien de la DA n'est en ligne : c'est LE blocage n°1. Tant que ce n'est pas déployé, la console
  et le pilotage ne peuvent rien faire.
- Vérifié : en injectant le moteur en live, l'app SE recolore bien via les variables-cœur (accent,
  CTA, nav active, titres) → l'architecture est bonne ; il manque le déploiement + la couverture.

====================================================================
## 1. À DÉPLOYER (dans cet ordre)
1. `sunmates-icons-v2.js` (recolorable + SMIconize emojis) → tag `?v=542` dans index.html.
2. `sunmates-da-loader.js` + AJOUTER le tag en fin de `<body>` (après le gros script app) :
   `<script src="sunmates-da-loader.js?v=5"></script>`  (expose `window.SMDA`, applique les tokens).
3. Exposer sur window (1 ligne chacun) : `window.myProfile = myProfile;` `window.isAdmin = isAdmin;`
   (garder `window.goToTab`). Nécessaire pour la garde admin de la console.
4. `da-console-overlay.js` → tag admin-gated : `<script src="da-console-overlay.js?v=1"></script>`
   (bouton flottant ✦ DA visible seulement si `isAdmin()`). Garder aussi un point d'entrée dans Profil→Admin→DA.
5. Supabase : exécuter `sunmates-da-history.sql` (table `da_history`, versions/rollback ; RLS admin).
   Activer **Realtime** sur `da_tokens`/`da_strings` si on veut le live-push.
6. **Bumper `VER` dans `sw.js`** (coquille PWA) à chaque push.

====================================================================
## 2. ANTI-TRONCATURE (vérifier AVANT commit — déjà arrivé)
- `index.html` doit finir par `db.auth.getSession().then(...render...)` → `</script>` → tag loader → `</body></html>`.
- `da-console.html` doit finir par `</body></html>` (jamais en plein `function advRefresh(){var m=T.modes[curM`).
- `node --check` sur le DERNIER `<script>` de chaque fichier (un bloc antérieur peut masquer une fin coupée).

====================================================================
## 3. CONTRAT DE TOKENS (T) — source de vérité da_tokens.tokens
modes{j1,j2,j3,angle,page,ink,class,label,trigger} · iconColors · iconColorsByMode · glyph ·
icon{style,colorMode,mono,perMode} · sizes{tile,iconTile,inline} ·
effects{radius,shape,keyline,sheen,polish,mirror,shadow} · fonts{heading,body} ·
a11y{fontScale,reduceMotion} · texts[cat]{label,meta} · globalTexts · badges{4 familles [clair,foncé]} ·
logos · logoChoice · scenes{confetti,saison,accent} · rewards[] ·
typo{titleSize,titleColor,bodyColor,metaColor} · comp{btnText,chipText} · emoji{off,keepNative} ·
appIcon{c1,c2,glyph} · imgBank ·
**NOUVEAU** : grads{accent,sunset} · overrides{ "mode||selector":{j1,j2,shape} } · device.

====================================================================
## 4. LOADER — déjà appliqué + EXTENSIONS à ajouter pour le 100%
Déjà : variables-cœur par mode (--bg,--ink,--text,--muted,--line,--card,--cream,--accent,--accent-2/3,
--accent-grad,--accent-soft,--ring) ; joyaux (--ic1/--ic2 sur cic/jo-ic/qm-ic/sc-ic/smgem/thumb) ;
emblèmes (--icc + colorMode natural/mono) ; style natif (SMIconize off) ; tailles vars ; polices
(+Google Fonts) ; typo (titre/corps/méta) ; effets (sm-no-polish/mirror/no-shadow) ; emoji off/keepNative.
À AJOUTER :
- **--sunset-grad** (confirmer) dérivé des joyaux, + garder --accent-grad.
- **badges{}** : poser les 4 dégradés (.hex, .hex.grad-violet/.grad-gold/.grad-teal, médaillons SMBadge).
- **comp.btnText/chipText** (texte bouton/chip), **logos[mode]** réellement consommé (--sm-logo).
- **overrides ciblés** : injecter `body.<modeclass> <selector>{--ic1/--ic2/background-image}` depuis `overrides`.
- **epin (marqueurs carte)** : couleur posée en JS inline (pas var). Exposer `window.SM_EPIN_COLOR(cat,mode)`
  lu par `epinIcon()` (~L15422) à la place du `bg` codé en dur, pour que les pins suivent la DA.

====================================================================
## 5. index.html — COULEURS ENCORE EN DUR à convertir → var (preuves LIVE, preset Neon)
Occurrences réellement observées figées en mode non-sunset (×N) :
- **.vchip / .vchip.lg** (×34) L1488 → `var(--accent-grad)`.
- **.pcard-chip.pcard-top** (×8) L666 · **.pcard-rate** (×8) · **.pcard-eco** L663 → `var(--accent-grad)`/accent.
- **.epin / .epin.quest / .epin-cluster** (×8) L1398-1407 → hook JS (cf. §4).
- **.gp-tile / .gp-ic** (perks Gold ×6) + **.gold-hero/.gh-price/.gh-soon/.gh-crown** L3625-3643.
- **.pf-pct.done / .wg-bar / .wg-goal.done** (jauges ×6) → `var(--accent)`/`var(--accent-grad)`.
- **.badge.ok** (×4) L962/2767/3090/3189 → `var(--ok)`/`var(--accent-soft)`.
- **.pc-stat/.stat/.ci-count/.pr-val/.pb-pill/.player-badge.player-hud/.ph-glow/.ph-lvl-ring** (HUD/stats).
- **.gplay-xp** L1628 · **.xp-banner** · **.rate-top** L1684 · **.rate-chip** L1681 → `var(--accent-grad)`.
- **.streak-chip/.sp-streak/.sp-next/.rit-cnt/.weather-chip/.mates-stat** → var(--accent*).
- **.tpa-btn.tpa-bff** → var(--accent-grad).
- **.mark-pro** L391 · **.avail-chip.on/.avail-badge** L585/587 · **.homemap-filters .chip.cl-*** (5) L1392-1396 ·
  **#profSegNav [data-pseg]** L2872-2898.
- **Paires --c1/--c2 en dur** (à centraliser sur --ic1/--ic2 pilotés) : `.cic.c-*` L488-492,
  `.thumb.*` L3198-3207, `.gcard .ghead.*` L1545-1554, `.qm-coral/.qm-*` L2068-2070, `.sc-*` L2117,
  `.jo-ic.c-purp` L1636, `.hex.grad-*`/.locked/.secret L1842-1851.
- Couche **POLISH / !important** : `.bottom-nav` `#fff7f2` L3216 · surfaces nuit L3267-3281 ·
  `.btn-primary` grad L3176 → remplacer les valeurs figées par var(--…) pour ne pas écraser le loader.
> RÈGLE : danger/SOS/blocage restent ROUGES (sémantique) — `.su-call/.su-sos`, `.act-block`. Tout le reste suit la DA.

====================================================================
## 6. CONSOLE (overlay in-app, ADMIN)
- `da-console-overlay.js` : bouton ✦ DA (admin only). Panneau LIVE : presets, palette/mode, icônes
  (style/couleur/forme), tailles, polices, typo/contraste, composants, badges (4), logo du mode, effets,
  scènes, emojis, dégradés + **clic-recolor** sur tout élément réel (écrit `overrides`).
- Architecture validée : même page que l'app (pas d'iframe) → aucun souci d'origine, édite la vraie app.
  (Les fichiers `da-console-v2.html/.js` iframe sont abandonnés : bloqués cross-origin.)
- Publier : upsert `da_tokens` (RLS admin) + insert `da_history` ; aperçu live = `SMDA.apply` + localStorage `sm_da_live`.
- Test rapide avant câblage admin : `sunmatesapp.com/?daforce=1` (bypass garde — RETIRER en prod).
- À RÉINTÉGRER ensuite dans l'overlay (présent dans l'ancienne console da-console.html) : glyph-picker par
  catégorie (288), i18n FR/EN complet, inventaire emojis, récompenses, icône-app/PWA, banque d'images,
  auto-contraste WCAG.

====================================================================
## 7. CHECKLIST DE TEST (après déploiement, connecté ADMIN)
- [ ] Bouton ✦ DA présent (et seulement en admin).
- [ ] Changer de preset → fonds/textes/accents/CTA/tuiles/sidebar/cartes suivent dans les 6 modes (clair+sombre).
- [ ] Les classes du §5 ne restent plus « sunset » en preset Neon/Lagon/Cosmique.
- [ ] Marqueurs carte recolorés (hook epin). Clic-recolor d'une tuile = effet ciblé (mode+écran).
- [ ] colorMode naturelle↔unie recolore les icônes ; style natif = emojis natifs.
- [ ] Publier → visible pour tous au reload ; live-push sans reload si Realtime activé.
- [ ] Versions : publier 2-3 fois → liste + restauration OK.

====================================================================
## 8. FICHIERS À POUSSER (récap)
index.html · sunmates-da-loader.js · sunmates-icons-v2.js · da-console-overlay.js ·
sunmates-da-history.sql · (+ da-console.html si tu gardes l'ancienne) · bump sw.js VER.
NE PAS pousser : sunmates-icons.js (stub legacy) · da-console-v2.html/.js (approche iframe abandonnée).
