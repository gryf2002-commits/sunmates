# SunMates — Kit DA (extrait de la session Stitch « Radiant Horizon »)
Relevé visuel direct depuis Stitch (board système + écrans nuit/clair). Sert de source de vérité
design pour `code` et pour la preview. ⚠️ On garde la cohérence DA sunset existante de l'app.

## 1) Palette (tokens exacts du board « Radiant Horizon »)
- **Primary**  `#FF3A2D`  — accent de marque, CTA, liens, états actifs (coral-red)
- **Secondary**`#FFD15C`  — or/ambre, accents chauds, highlights, XP
- **Tertiary** `#9B7BFF`  — lavande/violet, features ludiques (Coupons, Jeux), badges
- **Neutral**  `#190E2E`  — fond profond mode NUIT (prune/indigo très sombre)
- Dégradé marque (wordmark/anneaux) : or → coral → rose (`#FFD15C → #FF8A3D → #FF5C7A`)
- Chaque couleur a une échelle de nuances (50→900) sur le board.

## 2) Typo
- **Titres** : serif display (style Fraunces) — « Aa » en gros sur le board.
- **Body + Label** : **Manrope**.

## 3) Modes (cartes de DA vues)
- **NUIT — « Crépuscule »** : prune profonde teintée, accents chaleureux. Fond ≈ Neutral `#190E2E`.
- **HIVER — « Aube Glaciaire »** : clarté cristalline, mode clair, accents bleus froids, sérénité.
- (autres modes du projet : jour, tropiques, etc. — garder les 6.)

## 4) Composants premium repérés (à reprendre)
- **Tuiles « Accès Rapide »** (grille 2 col) — deux styles cohérents :
  - *feature* = tuile **dégradé plein** (Sécurité = orange→ambre, Jeux = rose, Coupons = violet)
  - *standard* = tuile **sombre** + **icône colorée** (Mes Mates, Lieux, Classement)
- **Segmented pill** : « ✈️ En voyage » (actif, dégradé) / « 🏠 À la maison ».
- **Barre de recherche** arrondie « Rechercher une ville, un mate… ».
- **Carte map** « Explorer Paris · 24 mates en ligne » avec pins coral.
- **Feed « 🔥 Autour de vous · Voir tout »** : lignes activité (avatar + « Léa a accompli la quête Tour Eiffel · il y a 10 min », cœur).
- **Boutons** : Primary (dégradé) · Secondary · Inverted · Outlined · icon-buttons ronds.
- **Chip Label** coral, **pastilles d'icônes** rondes colorées (outil/médaille/badge/ticket/corbeille).

## 5) Écran Sécurité (très abouti)
- **Bouton SOS** = grand **cercle rouge** plein « SOS — J'AI BESOIN D'AIDE ».
- **Circle of Trust** : rangée d'avatars (Ajouter +, Emma, Lucas…).
- Tuiles : **Faux appel**, **Signaler**, **Partager position**, **Aide à proximité**.
- Carte **« Numéros d'urgence »** : 112 · SAMU · Police.
- Rouge réservé au danger (cohérent avec notre règle).

## 6) À NE PAS copier
Max : « oublie celle qui ressemble vraiment trop à l'app complète ». → on **ne décalque pas**
l'écran le plus proche de l'app actuelle ; on s'inspire du **système** (Radiant Horizon) et des
écrans soignés, surtout pour la version **lissée** (plus simple).

## 7) Ce qu'on en fait
- Aligner la preview + `sunmates-lite.css` sur Primary `#FF3A2D` / Secondary `#FFD15C` /
  Tertiary `#9B7BFF` ; titres serif + Manrope.
- Reprendre : segmented « En voyage/À la maison », carte map, feed « Autour de vous »,
  Circle of Trust, Faux appel + Numéros d'urgence, tuiles dégradé vs sombre+icône.
- Pour `code` : ces tokens = base des presets DA (NUIT/Crépuscule, HIVER/Aube Glaciaire…).
