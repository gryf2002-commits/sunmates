# Brief code — Construire la VERSION LITE (grand public) de SunMates

But : une vraie app **lite** publique, **fonctionnelle de A à Z**, dans **une seule DA**
(celle du « Guide des ambiances »), reproduisant les écrans Stitch sélectionnés par Max.
Tout reste **en preview** (pas de prod tant que Max n'a pas validé). ⚠️ Ne pas régresser `index.html`/sunmatesapp.com.

## 0) Ce que j'ai déjà préparé (à réutiliser, pas à refaire)
- **Maquette/prototype de référence** : `sunmates-app.html` (racine). Vraie SPA vanilla (Tailwind CDN + Leaflet + Material Symbols). Tous les écrans du mix y sont, fidèles aux visuels. À prendre comme **référence visuelle + structurelle**. (Code peut repartir de zéro proprement, ou l'industrialiser — au choix.)
- **Design system source de vérité** : `KIT_DA_SunMates_v2026.md` + `sunmates-kit-da-v498.json`.
- **Vrais rendus Stitch (HTML) par écran** : `da-galerie/screens/*.html` (40 écrans, markup Tailwind exact).
- **Captures HD** : `da-galerie/img/*.png`. **Galerie** : `da-galerie/index.html`.
- **Exploration/specs** : `STITCH_EXPLORATION.md`.

## 1) DA UNIQUE = « Guide des ambiances » (claire/éditoriale)
Tokens exacts (Material-style, repris du screen `guide_des_ambiances_sunmates`) :
- background/surface `#faf8ff` · surface-container `#eaedff` · surface-container-lowest `#ffffff`
- on-surface `#161b29` · on-surface-variant `#5a403d` · secondary `#585f69`
- **primary `#b5241f`** · **primary-container `#ff5a4d`** · outline-variant `#e3beb9`
- **sunset-gradient (CTA)** : `linear-gradient(135deg,#ff5a4d,#b5241f)`
- Tuiles « joyaux » : un dégradé par catégorie (quest `#FF8A5C→#FF4F6D`, games `#A07BFF→#6638D6`,
  badges `#FFD15C→#FF8A3D`, coupons `#56C2F5→#2D7FE0`, rank `#43D6A0→#0E9E6B`, shop `#FF7FB0→#E0407A`).
- Typo : **Fraunces** (titres, 800-900, titres écran en `#b5241f`) + **Manrope** (interface).
- Rayons : carte/jewel `26-28px` · ombre douce `0 14px 38px rgba(45,38,52,.10)`.
- Icônes : **Material Symbols Outlined** (FILL 1 sur l'onglet actif).
> Pas de switch de modes dans la lite : UNE seule DA. (Le « Guide des ambiances » reste présent
> comme **page-showcase** des 6 mondes, mais ne change pas la DA de l'app.)

## 2) Écrans du mix (exact, validé par Max) — chacun basé sur un screen Stitch
1. **Onboarding** → `onboarding_nuit_tropicale_hd` (slides « Ta carte vivante »…, dots, Suivant/Passer).
2. **Connexion** → `connexion_nuit_tropicale_hd` (onglets Connexion/Inscription, email+mdp+œil, Google/Apple, baseline).
3. **Accueil** = **Hub Maison** `mode_maison_hub_solo` (De retour chez toi, progression solo, rituels du jour,
   défis solo de ta ville, « De passage chez toi ») **+ onglet « En voyage »** avec **carte interactive**
   (Leaflet, type app actuelle : pins lieux/mates/quêtes, « Autour de moi »).
4. **Lieux** → `lieux_s_rs_jour` (Mon spot actuel, recherche, filtres TOUS/ÉCO/PRÈS DE MOI, cartes photo
   avec note ★, cœur, tags, « Check-in ici », badge TOP CHOIX, « Voir les détails »).
5. **Jeux & Quêtes** → `hub_jeux_qu_tes_hd` (en **un peu plus classique/sobre**) : barre XP/niveau,
   6 tuiles joyaux, Quête du jour (spotlight photo), Ta progression.
6. **Mates — Découverte** → `d_couverte_de_mates_nuit_tropicale_hd` (recherche, Nearby/Global, Featured Mates,
   cartes mate « Elena 92% / Active now / tags / ✕·Connect·♡ », event « Sunset Yoga », David) **+ Messages** (liste convo).
7. **Chat** → `discussion_avec_lina_nuit` (avatar+typing+streak 🔥, séparateur « Aujourd'hui », bulles, composer mic+envoi).
8. **Sécurité** → `s_curit_nuit_tropicale` (alt, optimisée) : **gros SOS circulaire**, cercle de confiance (avatars + Ajouter),
   accès rapides 2×2 dégradés (Faux appel/Signal d'aide/Partager position/Aide à proximité), numéros d'urgence 112.
9. **Profil** → `profil_nuit_tropicale` (alt, optimisé) : avatar+👑, « Chloé, 26 » ✓ VÉRIFIÉ, **4 cartes stats**
   (Confiance/XP/Mates/Check-ins), « Profil complété 85% », « Mon Parcours » (3 badges ronds), Modifier.
10. **Guide des ambiances** (showcase) → `guide_des_ambiances_sunmates`, **à parfaire un peu** : présentation
    éditoriale des 6 mondes (cartes + swatches + bouton).
11. **Livre blanc** (public) → `console_admin_livre_blanc_d_mo` : hero « Visite guidée (A→Z) », recherche,
    chapitres 01-04, catalogue par zone (Découvrir), carte « Section réservée Admin » **verrouillée (teaser)**.
- **PAS de back-office** (membres/lieux/modération/dashboards) → **feature séparée ultérieure**, hors lite.
- Nav du bas : Accueil · Lieux · Jeux · Mates · Sécurité · Profil. Menu ☰ : Guide des ambiances · Livre blanc · onboarding · déconnexion.

## 3) Exigences FONCTIONNELLES (tout doit marcher de A→Z)
Audit du prototype (à ne PAS reproduire comme trous) — points à câbler proprement :
- **Champs réels** : toutes les barres de recherche et les champs de login doivent être de **vrais `<input>`**
  (le proto avait des `<div>` factices → corrigé, mais à refaire propre). Recherche Lieux/Mates = **filtrage réel**.
- **Tuiles Jeux** (6) : cliquables → ouvrir l'écran/section correspondant (ou au minimum action concrète).
- **Filtres Lieux** (TOUS/ÉCO/PRÈS DE MOI) : filtrent réellement la liste.
- **Segments** : Accueil (maison/voyage), Mates (découverte/messages), Nearby/Global → tous actifs.
- **Carte** : Leaflet interactif (pins, recentrage), comme l'app actuelle.
- **Chat** : envoi de message réel (+ accusé), retour arrière.
- **Sécurité** : SOS → confirmation ; accès rapides actifs ; appel 112.
- **Connexion** : onglets changent le formulaire ; œil révèle le mot de passe ; Google/Apple ; « Oublié ? ».
- **Onboarding** : slides + Passer + « revoir » depuis le menu.
- **Feedback visible systématique** (toasts) sur chaque action — ⚠️ **bug rencontré** : un toast dont la
  classe ne matchait pas la règle CSS → invisible → « rien ne marche » alors que le JS tournait. Vérifier
  que tout retour visuel s'affiche réellement (tester chaque interaction).
- Fermeture des overlays par le fond (sheet, modale SOS).

## 4) Robustesse / livraison
- Le proto dépend de **CDN** (Tailwind, Leaflet, Google Fonts, picsum). Pour une lite **ouvrable en local
  sans surprise**, code peut soit garder les CDN (OK en ligne), soit **inliner** (Tailwind compilé en CSS,
  Leaflet local, images locales) pour un fichier 100% autonome. Recommandé : version autonome pour la démo.
- **Tester réellement dans un navigateur** (le proto a souffert de bugs invisibles en analyse statique).
  Vérifier chaque écran + chaque bouton.

## 5) Intégration produit
- Cette lite = la **version grand public** (beta OFF). À relier au **toggle beta** déjà en place
  (`body.sm-lite`, cf. `BETA_TOGGLE.md`/`BRIEF_CODE_BETA_DA.md`) : public → lite, beta-testeurs → app complète.
- Garder **la sécurité gratuite pour tous**, le **rouge réservé au danger/SOS**.
- **Rien en prod** tant que Max ne valide pas hors preview. Bump `sw.js` VER au moment du push.

## 6) Fichiers de référence (repo)
`sunmates-app.html` · `KIT_DA_SunMates_v2026.md` · `sunmates-kit-da-v498.json` ·
`da-galerie/screens/*.html` (rendus Stitch) · `da-galerie/img/*.png` · `da-galerie/index.html` ·
`STITCH_EXPLORATION.md` · `BETA_TOGGLE.md` · `BRIEF_CODE_BETA_DA.md` · `DA_PREVIEW.md`.
