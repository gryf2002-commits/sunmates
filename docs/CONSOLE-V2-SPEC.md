# Console DA v2 — SPEC maître (reproduction 100% de l'app + tout modifiable)

But : une console qui reproduit fidèlement CHAQUE écran de SunMates (desktop ET mobile),
navigable comme l'app, où l'on voit la DA changer en live, avec édition globale (presets,
palettes) ET édition au clic, tuile par tuile. Source : index.html (≈20 400 l.) + da-console.html.

## 0. Cadre
- **Toggle Desktop / Mobile** : desktop = sidebar gauche + grandes cartes bannière ; mobile = topbar
  + bottom-nav + tuiles. Globalement même contenu, layout différent. Démarrer du desktop, décliner mobile.
- **6 modes** : jour, nuit (theme-dusk), hiver (theme-winter), hiver-nuit, tropiques (theme-tropic),
  tropiques-nuit. Chaque écran rendu dans le mode courant.
- **Édition au clic** : tout élément coloré porte un data-id → popover (joyau1/2, forme, taille, couleur
  texte) → override `overrides[mode.ecran.id]`. + un bouton « réinitialiser cette tuile ».

## 1. Écrans à reproduire (nav principale : Accueil · Lieux · Jeux · Mates · Sécurité · Profil)

### Accueil (mode Voyage + mode Maison)
- Topbar : logo saisonnier + thème + cloche(+badge) + déconnexion.
- Salutation #homeHello + chip dispo + chip streak 🔥.
- Bascule mode-switch (Voyage/Maison) + recherche + scopes.
- MAISON : hero retour, solo-prog (jauge), souvenirs/mates, défis solo (sc-grid), rituels, inspo,
  prochain voyage, wishlist, visiteurs, hôte.
- VOYAGE : carte « explore autour de toi » (Leaflet + filtres chips cl-*), day-session, météo.
- Commun bas : badge-rail, fil (composer + posts), mes voyages, **grille accès rapides (8 tuiles `.tile`)**.

### Lieux sûrs
- Spot du jour (#spotCard), favoris, recherche, filtres `.cat-tile` (all/eco/near) + tris,
  liste de **cartes lieu `.pcard`** (photo, chips eco/top/rate/new, titre, stats, actions check-in).

### Jeux & Quêtes (sous-vues : Home, Détail, Badges, Coupons, Classement, Boutique)
- Home : plaque niveau (player-hud), nav `.cat-tile`, quête du jour (spotlight), progression
  (4 prog-row), défis reçus, quêtes de groupe à confirmer.
- Feuille quêtes/jeux (`.qrow`, grille jeux).
- Détail quête (hero, étapes, récompenses, code).
- Badges (médaillons `.sm-badge`, grisés/secret).
- Coupons (`.coupon`).
- **Classement** (`renderLeaderboard`) : segments XP/checkins/trust/badges, podium, `.lb-row`.
- Boutique : titres + **cadres `.frame-*`** (dont Aurore animé), boosts.

### Mates (sous-vues : Home, Profil mate, Chat)
- Home : stat, invite, segments (Messages/Découvrir/Demandes).
  - Messages : groupes + `.conv-row`.
  - Découvrir : mate du jour, recherche, filtres, tri, **cartes mate `.tcard`**.
  - Demandes : liste.
- Profil mate : hero, stats, actions (connecter/message/défi/bff/signaler), à propos, vouch, infos, badges.
- Chat : header + flamme, bulles `.msg-row/.bubble`, barre d'envoi (+ vocal).

### Sécurité (sous-vues : Home, Aide)
- Home : **gros SOS** (sos-logo + btn-danger), safety-check, conseil du jour, **grille 8 tuiles**.
- Aide : urgence (su-call 112 + su-sos), contacts ICE, cercle de confiance, **grille aide 6 tuiles**,
  rangées conseils/confidentialité (`.qrow`).

### Profil (vue + segments : Édition, Check-ins, Premium, Pro, Admin, Réglages)
- Vue : prof-head (avatar, nom, vérif, ville, confiance), stats (3 stat-box), complétion, segments,
  badges, parcours.
- Édition : 7 sections repliables `.pf-section` (photo, voyage/affinités chips, identité, travail,
  style de vie, plus, prompts).
- Premium : gold-hero + perks + comparatif.
- Pro (B2B) : panneau partenaire.
- Admin : sous-onglets (demo, dash, users, places, reports, quotes, feedback, sounds, **DA**, data, system).
- Réglages : toggles (thème, haptique, son, présence, public), langue, QR, aide, compte, RGPD.

## 2. Composants transverses (un rendu réutilisable chacun, tous éditables au clic)
tile/thumb · cat-tile/cic · pcard (lieu) · tcard (mate) · gcard/ghead (jeu) · qrow (quête/ligne) ·
sm-badge (médaillon) · lb-row (classement) · msg bubble · conv-row · coupon/cico · avatar(+présence) ·
stat-box/dstat · set-toggle · chips · pf-section · act-overlay (modale) · backbtn · skeletons ·
feature/feature-rating · fpost/feed-card · reco · qm-card · sc-card · epin (marqueur carte) ·
frame-* (cadres avatar) · gold-hero · hex (badge hexa).

## 3. Contrôles à exposer (toutes les sections de l'ancienne console + manques)
A. Mode courant : joyau1/2, 3e teinte, angle, fond page, encre, trigger.
B. Icônes : style (plein/trait/duo/natif), couleur (naturelle/unie/thémée), couleur unie, par-mode, forme.
C. Effets : polish, miroir, ombre, liséré, reflet %, arrondi.
D. Tailles & a11y : tuile, icône, échelle police %, réduire animations.
E. Polices : titres + interface (7 familles).
F. Couleurs icônes : une par catégorie (ou par mode).
G. Glyphes : picker d'emblème par catégorie (288) + reset.
H. Textes tuiles : label + meta par catégorie.
I. Textes globaux : tagline, greeting, quick, explore, cta.
J. Badges : 4 familles (clair/foncé).
K. Logos par mode (couleur) + logos maison (choix glyphe + couleur par mode).
L. Scènes : confettis, pluie saison, accent.
M. Emojis : SVG/natif global + liste garder-natif.
N. Récompenses : liste éditable (nom/desc/xp/icône/état/couleur).
O. Inventaire emojis (recolor direct) + i18n complet FR/EN (édition + export).
P. Typo & contraste : couleur titres/corps/méta + taille + pastilles WCAG.
Q. Composants : couleur texte bouton/chip + aperçu contraste.
R. Icône app / PWA / login : c1, c2, glyphe.
S. Banque d'images (lieux) : terme par catégorie.
T. **NOUVEAU — à exposer (en dur aujourd'hui)** : `--accent-grad`, `--sunset-grad`, `--cream/--paper`,
   paires emblèmes `--c1/--c2` / `--ic1/--ic2` éditables, badges d'état (badge.ok, vchip, mark-pro,
   rate-top, avail-*), filtres carte cl-* (5), segments profil (premium/admin/pro), gold-hero,
   pcard-eco/top, reco, bottom-nav fond, epin (hook JS).

## 4. Presets (21) — repris tels quels
☀️ Sunset · 🌅 Aurore pêche · 🪸 Corail récif · 🍊 Agrumes · 🔥 Braise ardente · 🌷 Rose poudré ·
🌸 Pastel doux · 🍬 Stickers pop · 🌿 Menthe fraîche · 🌊 Bleu cobalt · 🌴 Lagon tropical ·
🍋 Citron givré · 🌫️ Brume nordique · 🍇 Cassis nuit · ✨ Crépuscule cosmique · 🌌 Néon nuit ·
💎 Joaillerie · 📖 Duotone éditorial · 📱 Natif chaleur · ⚫ Encre & or · ⚪ Minimal mono.

## 5. Token T (cible)
modes{j1,j2,j3,angle,page,ink,trigger,label,class} · iconColors · iconColorsByMode · glyph ·
icon{style,colorMode,mono,perMode} · sizes{tile,iconTile,inline} · effects{radius,shape,keyline,
sheen,polish,mirror,shadow} · fonts{heading,body} · a11y{fontScale,reduceMotion} · texts[cat]{label,meta} ·
globalTexts · badges{4} · logos · logoChoice · scenes{confetti,saison,accent} · rewards[] ·
typo{titleSize,titleColor,bodyColor,metaColor} · comp{btnText,chipText} · emoji{off,keepNative} ·
appIcon{c1,c2,glyph} · imgBank · **overrides{ "mode.ecran.id":{j1,j2,shape,size,text} }** (NOUVEAU) ·
**grads{accent,sunset}** (NOUVEAU) · **device:'desktop|mobile'** (NOUVEAU, vue console).

## 6. Technique (avec code, sans casser l'existant)
- La console réutilise `sunmates-icons-v2.js` (emblèmes) + le même modèle de tokens que le loader.
- Le loader devra appliquer en plus : `--accent-grad`/`--sunset-grad`, les overrides ciblés par
  sélecteur/élément, et exposer `--c1/--c2` éditables. Brief séparé pour code.
- Export JSON + postMessage vers l'admin (déjà en place).
