---
name: SunMates
description: App sociale « sécurité d'abord » pour voyageurs solo — DA coucher de soleil, niveau joaillerie
colors:
  corail: "#FF5A4D"
  orange-chaud: "#FF8A3D"
  ambre-dore: "#FFC93C"
  corail-pale: "#FFE6DC"
  or-badge: "#FFD15C"
  teal-securite: "#11B5A0"
  violet-social: "#7A5CFF"
  sable-leve: "#FFF4E6"
  carte: "#FFFFFF"
  encre-aubergine: "#39203A"
  texte-prune: "#5B4455"
  mauve-discret: "#AC93A3"
  ligne-sable: "#F6E3D6"
  danger: "#F0384E"
  prune-nuit: "#190E2E"
  carte-nuit: "#271641"
  encre-nuit: "#FCEFE9"
typography:
  display:
    fontFamily: "Fraunces, Georgia, serif"
    fontWeight: 800
    lineHeight: 1.15
  body:
    fontFamily: "Manrope, system-ui, sans-serif"
    fontWeight: 500
    lineHeight: 1.5
  label:
    fontFamily: "Manrope, system-ui, sans-serif"
    fontWeight: 700
rounded:
  sm: "14px"
  md: "22px"
  lg: "28px"
  pill: "999px"
components:
  button-primary:
    backgroundColor: "linear-gradient(135deg, #FFC93C 0%, #FF7A3D 46%, #FF4F6D 100%)"
    textColor: "#FFFFFF"
    rounded: "{rounded.pill}"
  button-accent:
    backgroundColor: "{colors.corail-pale}"
    textColor: "{colors.corail}"
    rounded: "{rounded.pill}"
  button-ghost:
    backgroundColor: "{colors.carte}"
    textColor: "{colors.encre-aubergine}"
    rounded: "{rounded.pill}"
  chip:
    backgroundColor: "#FFF1E0"
    textColor: "{colors.texte-prune}"
    rounded: "{rounded.pill}"
  chip-active:
    backgroundColor: "linear-gradient(135deg, #FFC93C 0%, #FF7A3D 46%, #FF4F6D 100%)"
    textColor: "#FFFFFF"
    rounded: "{rounded.pill}"
  card:
    backgroundColor: "{colors.carte}"
    textColor: "{colors.texte-prune}"
    rounded: "{rounded.md}"
  sceau-verifie:
    backgroundColor: "linear-gradient(135deg, #FFC93C, #FF8A3D 60%, #17A99B)"
    textColor: "#FFFFFF"
    rounded: "{rounded.pill}"
  compteur-notifs:
    backgroundColor: "{colors.corail}"
    textColor: "#FFFFFF"
    rounded: "{rounded.pill}"
---

# Design System: SunMates

> **Sources normatives, dans l'ordre :** `sunmates-kit-da-v445.json` (tokens sondés en direct sur
> l'app, 6 modes complets) → ce fichier → `DESIGN_SYSTEM.md` (le dossier d'âme : moteurs de badges,
> loi de contraste, gouvernance). En cas de divergence, le kit exporté fait foi.
> ⚠️ Les ombres corail de `DESIGN_SYSTEM.md` §5 sont **périmées** : doctrine v444+ = gris chaud (voir Elevation).

## 1. Overview

**Creative North Star : « La joaillerie du couchant »**

SunMates traduit visuellement un mélange unique : **la chaleur d'une rencontre au coucher du soleil
+ la confiance d'un lieu sûr**. La DA est chaude, vibrante, généreuse — jamais froide ni clinique.
Le niveau d'exigence est celui d'un **badge d'arène de jeu vidéo** : matières (or, émail, verre,
galaxie), lumière haut-gauche cohérente, rim-light, ombre de contact. Règle d'or : *« aucun pixel
générique »* — si un visuel pourrait venir d'une banque d'icônes gratuite, il n'a pas sa place ici.

Le système vit dans **6 mondes** (`day`, `dusk`, `winter`, `winter-dusk`, `tropic`, `tropic-dusk`),
chacun avec ses tokens complets dans le kit v445. Tout composant doit être lisible dans les six.
Ce que le système rejette explicitement : l'UI « générée par IA » générique, les icônes Lucide/Material,
le vert criard SaaS, l'ivoire en masse, le dark mode froid corporate (voir PRODUCT.md, Anti-references).

**Key Characteristics:**
- Palette sunset : corail → orange → ambre → or, accents teal (sécurité) et violet (social/nuit)
- Dégradé signature « Soleil couchant » : `135deg #FFC93C → #FF7A3D 46% → #FF4F6D`
- Matières radiales (lumière à ~36% 28%), jamais d'aplats pour les visuels « joyau »
- 6 modes cohérents, nuit = prune chaude violette (jamais gris bleuté)
- Typo bicéphale : Fraunces pour l'émotion, Manrope pour l'information
- Architecture : un seul `index.html` vanilla, tokens CSS sur `:root`, thèmes redéfinis sur `body.theme-*`

## 2. Colors: la lumière du couchant

Une palette de coucher de soleil ponctuée de deux accents froids maîtrisés ; les neutres sont des
sables et des prunes, jamais des gris.

### Primary
- **Corail** (#FF5A4D, `--accent`) : LA couleur SunMates — CTA, compteur de notifs, liens d'action.
- **Orange chaud** (#FF8A3D, `--accent-2`) et **Ambre doré** (#FFC93C, `--accent-3`) : compagnons du
  corail dans le dégradé signature ; l'ambre porte les états « série / présence » (texte #B5740E sur
  fond ambré translucide).
- **Corail pâle** (#FFE6DC, `--accent-soft`) : fonds de chips, boutons accent, étiquettes de post.

### Secondary
- **Teal sécurité** (#11B5A0, `--ok`) : validation, éco, « lieu sûr » — c'est LE « vert » autorisé,
  et il tire vers le turquoise. Présent dans le sceau vérifié.
- **Violet social** (#7A5CFF) : social, nuit, mystère (famille Social des badges, accents nocturnes).
- **Or badge** (#FFD15C / #E8961F) : accomplissement, métal des badges. Jamais deux tuiles dorées
  côte à côte (règle v444).

### Neutral
- **Sable levé** (#FFF4E6, `--bg` jour) : fond de page jour — chaud, jamais ivoire.
- **Carte** (#FFFFFF, `--card`) : surfaces posées (cartes, feuilles, boutons fantômes).
- **Encre aubergine** (#39203A, `--ink`) : titres et texte fort — une encre TEINTÉE, pas un noir.
- **Texte prune** (#5B4455, `--text`) et **Mauve discret** (#AC93A3, `--muted`) : hiérarchie de texte.
- **Ligne sable** (#F6E3D6, `--line`) : bordures et séparateurs.
- **Nuit** : fond #190E2E (prune profonde), carte #271641, encre #FCEFE9 — les accents s'éclaircissent
  (corail #FF6A5D, teal #2BE0B0) pour garder le contraste.

### Named Rules
**The No-Green Rule.** Aucun vert criard, jamais (#22c55e décoratif interdit). Le « validé / en ligne /
éco » parle teal #11B5A0 ou ambre — le rouge système et le vert système sont réservés aux états
fonctionnels réels (danger, succès système), jamais à la décoration.
**The No-Ivory Rule.** Le blanc pur n'existe qu'en reflet, rim-light ou highlight. Jamais en masse de
remplissage, et aucun fond crème/ivoire (« hors DA »).
**La Loi de contraste.** Trois leviers pour que rien ne se noie, dans les 6 modes : température opposée
(objet chaud sur fond froid), contraste de valeur (highlight clair vs bord sombre), et couture
(ombre de contact + rim-light). C'est cette loi, pas le hasard, qui garantit la lisibilité jour et nuit.

## 3. Typography

**Display Font:** Fraunces (serif optique, 400-900, italique 500) — avec repli Georgia, serif
**Body Font:** Manrope (sans géométrique, 400-800) — avec repli system-ui, sans-serif

**Character:** chaleur éditoriale + clarté moderne. Fraunces apporte l'âme (titres, gros chiffres,
moments d'émotion) ; Manrope porte l'information (UI, corps, labels) sans jamais se faire remarquer.

### Hierarchy
- **Display** (Fraunces 800-900) : titres d'écran, chiffres héros (XP, niveaux, stats).
- **Headline** (Fraunces 700-800) : titres de cartes et de feuilles.
- **Body** (Manrope 400-600) : texte courant — couleur `--text`, jamais `--ink` (réservé au fort).
- **Label** (Manrope 700-800) : boutons, chips, badges de texte, compteurs.

### Named Rules
**The Émotion/Information Rule.** Fraunces pour l'émotion, Manrope pour l'information. Un texte
fonctionnel en Fraunces ou un titre héros en Manrope est une faute de DA.

## 4. Elevation

Système **posé et chaud** : les surfaces vivent sur des ombres douces et larges, pas sur des bordures
dures. **Doctrine v444+ (remplace les ombres corail historiques de DESIGN_SYSTEM.md §5) : les ombres
sont en GRIS CHAUD NEUTRE — base `rgba(45,38,52)` — ni rouges, ni marron.** Les ombres corail viraient
« sale », les brunes faisaient « terre » : les deux sont mortes, officiellement. Opacités plafonnées
basses (≤ .16 pour les teintées).

### Shadow Vocabulary
- **Repos** : ombre large diffuse gris chaud, à peine visible — la carte « flotte » sans salir le sable.
- **Pop** (feuilles, modales) : plus profonde, toujours gris chaud.
- **Ring focus/sélection** : anneau corail translucide (`0 0 0 4px rgba(255,90,77,.16)`).
- **Anneaux d'attention** (pinPulse, SOS, flamme de série) : les SEULS halos colorés vifs autorisés —
  protégés, ne pas dé-rougir.

### Named Rules
**The Warm-Gray Shadow Rule.** Toute nouvelle ombre = gris chaud neutre base rgba(45,38,52). Une ombre
rouge ou marron est un bug de DA, pas un choix.
**The Z-Token Rule.** Jamais de z-index brut : utiliser l'échelle nommée `--z-*` (`--z-header` 50 →
`--z-confetti` 6000).

## 5. Components

Valeurs jour ci-dessous ; les 6 modes complets (composant par composant) sont dans
`sunmates-kit-da-v445.json` → `modes.<mode>.composants`.

### Buttons
- **Shape:** pilule (999px), retour tactile `:active { transform: scale(.97) }`.
- **Primary** (`.btn-primary`) : dégradé signature « Soleil couchant », texte blanc.
- **Accent** (`.btn-accent`) : fond corail pâle #FFE6DC, texte et bordure corail — l'action secondaire chaude.
- **Ghost** (`.btn-ghost`) : fond carte, texte encre, bordure ligne sable — l'action discrète.

### Chips
- **Repos** (`.chip`) : fond #FFF1E0, texte prune, bordure ligne sable.
- **Active** (`.chip.active`) : dégradé signature, texte blanc — l'état sélectionné EST un coucher de soleil.
- **Série de jours** (`.streak-chip`) et **Présence** (`.presence-pill`) : ambre translucide, texte #B5740E.

### Cards / Containers
- **Corner Style:** 22px (cartes), 28px (grandes feuilles), 14px (petits éléments).
- **Background:** `--card` du mode (blanc le jour, #271641 la nuit — avec déclinaisons `--dcard*`).
- **Shadow Strategy:** gris chaud, voir Elevation.
- **Tuile-joyau** (signature) : dégradé bombé `--c1/--c2` par tuile + gloss + rim-light + ombre chaude ;
  couleur par sémantique (corail = énergie, violet = social, teal = sécurité, bronze = achievement).

### Badges & sceaux (signature)
- **Sceau vérifié** (`.vchip`) : dégradé ambre → orange → teal, texte blanc — la confiance en un pictogramme.
- **Médaillons de badges** : cercle dégradé + emoji, couleur par FAMILLE (exploration corail · social
  violet · sécurité teal · accomplissement or) ; verrouillé = grisé façon jeu vidéo ; secret = « ? ».
- **Compteur de notifs** (`.nbadge`) : pastille corail pleine, chiffre blanc, liseré blanc.

### Navigation
- 5 icônes SVG **au trait, monochromes**, teintées par l'état actif — jamais d'emoji dans la barre du
  bas (lisibilité d'abord). Le logo du header (6 logos SVG dessinés main) change seul avec le mode.

### Feedbacks
- **Toasts EN HAUT**, près de l'action — jamais collés en bas (invisibles).
- **États vides brandés** : médaillon dégradé + visuel maison + CTA. Jamais un texte triste seul.
- **Bulles de chat** : arrondies asymétriques ; « moi » = dégradé accent, « l'autre » = carte du thème.
- **Barre de défilement thémée** corail — jamais blanche système.

## 6. Do's and Don'ts

### Do:
- **Do** tirer toute couleur/valeur de `sunmates-kit-da-v445.json` (le mode concerné), jamais de tête.
- **Do** vérifier chaque changement visuel dans les **6 modes** — thémé ET lisible, jamais l'un sans l'autre.
- **Do** appliquer la Loi de contraste (température opposée, valeur, couture) à tout nouvel objet posé.
- **Do** mettre les retours utilisateur en toast EN HAUT, près de l'action.
- **Do** annoncer explicitement tout changement de teinte/fond (règle actée avec l'auteur — jamais en douce).
- **Do** garder les anneaux d'attention (pinPulse, SOS, flamme) vifs : ce sont des signaux de sécurité.

### Don't:
- **Don't** utiliser de vert criard ni d'indicateur vert hors DA — « validé / en ligne » = teal #11B5A0 ou ambre.
- **Don't** créer une ombre rouge ou marron : gris chaud rgba(45,38,52) uniquement (doctrine v444).
- **Don't** utiliser l'ivoire/crème en masse ni le blanc pur en remplissage (reflets seulement).
- **Don't** introduire d'icône de banque générique (Lucide, Material, Heroicons) : « on perd l'âme ».
- **Don't** laisser une scrollbar blanche système : elle est thémée corail.
- **Don't** écrire un z-index brut (tokens `--z-*` obligatoires) ni une nouvelle couleur hors kit.
- **Don't** poser deux tuiles dorées côte à côte (l'or se noie dans l'or).
- **Don't** utiliser le tiret cadratin « — » dans les textes de l'app (règle de soin éditoriale) ;
  genre des textes via le helper `_gw`.
- **Don't** toucher au style des écussons routiers de la carte (sprite blanc + `{ref}`) lors d'une
  retouche maplibre, ni sacrifier la lisibilité de la carte à son thème (ou l'inverse).
