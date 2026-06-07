# Brief — Corrections SunMates (retours utilisateurs + test sur mobile)

> À coller dans Claude Code. Cible : `index.html` (app vanilla + Supabase, GitHub Pages, PWA).
> **Contraintes :** un seul `index.html` déployable ; ne pas casser Supabase ni les `id` utilisés en JS ;
> rester dans la DA actuelle (corail/coucher de soleil, coins arrondis, thème jour/nuit) ;
> **lister toutes les modifs à la fin** (fichier, lignes, avant→après) ; confirmer que rien de fonctionnel n'est cassé.

---

## 🔴 P1 — Bugs

1. **Carte « Lieux » : plein écran bugué, zoom cassé.**
   - Le plein écran natif du navigateur est peu fiable (`toggleHomeFull` ~ligne 5331, `document.fullscreenElement`).
   - → Utiliser le **plein écran CSS** déjà présent (`.homemap-card.fs`) au lieu du natif, et **appeler `leafMap.invalidateSize()`** APRÈS le changement de taille (dans un `setTimeout` ~150 ms) + recadrer (`fitBounds`/`setView`).
   - Vérifier aussi le bouton « voir sur la carte » depuis l'onglet Lieux : il doit ouvrir une carte correctement dimensionnée (tuiles non coupées, bon zoom).

2. **Doublon « Revoir la présentation » sur le profil.**
   - Deux boutons identiques : `#replayOnbBtn2` (~ligne 2062) et `#replayOnbBtn` (~ligne 2386).
   - → N'en garder **qu'un** (le mieux placé), supprimer l'autre et le JS associé devenu inutile.

3. **Toggle thème jour/nuit : emoji + fiabilité + bande rose en PWA.**
   - En thème clair l'icône est une **🍌 banane** au lieu d'une **🌙 lune** (ligne ~1513 zone logo / bouton thème) → corriger l'emoji.
   - Le basculement jour/nuit « bug » par moments → fiabiliser (état persistant, classe `theme-dusk` appliquée de façon cohérente au chargement).
   - **Bande rose en haut, SURTOUT en mode nuit (app installée)** — CAUSE RACINE confirmée : `<meta name="theme-color" content="#FF5A4D">` (ligne 13) est **fixe** et n'est jamais mise à jour. En mode nuit, la zone de status bar reste donc corail/rose.
     → Mettre à jour `theme-color` **dynamiquement** en JS au basculement de thème (valeur sombre en nuit, ex. `#171026`), au chargement aussi.
     → Ajouter `viewport-fit=cover` au `<meta name="viewport">` (ligne 5) et gérer `env(safe-area-inset-top)` sur la `.topbar`/`.app-shell` (aujourd'hui **aucun** `safe-area-inset-top` dans le fichier).
     → Vérifier `apple-mobile-web-app-status-bar-style` (mettre `black-translucent` pour laisser le fond de l'app passer sous la status bar).

4. **Pseudos longs → chevauchement avec les réglages (⚙️) et le badge** *(c'est LE sujet)*.
   - Un pseudo long (ex. « pierreantoine.bernard ») pousse le nom dans le bouton ⚙️ et le badge « NON VÉRIFIÉ » de la carte profil, et déborde aussi sur l'accueil (« Bonjour … »).
   - → Mettre le nom dans un conteneur **flex** avec `min-width:0` + `white-space:nowrap` + `text-overflow:ellipsis` (troncature « pierreantoi… »), et **réserver** la place du ⚙️ et du badge (`flex-shrink:0`).
   - → Tester avec un pseudo très long : ⚙️ et badge ne doivent **jamais** bouger ni se faire chevaucher. (Idéalement : limiter la longueur du pseudo à la saisie, ou afficher le prénom plutôt que le pseudo — cf. 6b.)

5. **Bannière d'installation PWA disparaît trop vite et ne revient pas.**
   - → La rendre **persistante** tant que non installée (ne pas l'auto-masquer en quelques secondes), permettre de la **redéclencher**, et afficher des **instructions manuelles** : Android (⋮ → « Ajouter à l'écran d'accueil »), iOS Safari (Partager → « Sur l'écran d'accueil »).

6. **« Virgule colorée » : le dégradé de titre déborde sur la ponctuation.**
   - Sur « Salut, {Prénom} ! » / « Bonjour {Prénom} », le `background-clip:text` s'applique aussi à la virgule/espace.
   - → N'appliquer le dégradé **qu'au prénom** (envelopper le prénom dans un `<span>` dégradé), garder la ponctuation en couleur de texte normale.

6b. **Le « Bonjour » affiche le pseudo au lieu du prénom.**
   - ~ligne 2952 : `"Bonjour " + uname` utilise le **pseudo** → « Bonjour pierreantoine.bernard » au lieu de « Roronoa ».
   - → Afficher le **prénom** (`first_name`) s'il est renseigné, sinon le pseudo. (Cohérent avec l'onboarding qui dit déjà « Salut, Roronoa ! ».)

---

## 🟠 P2 — Ergonomie & DA (rester raccord)

7. **Visite guidée / onboarding : bouton « Précédent ».**
   - Ajouter un vrai bouton **Précédent** (revenir à l'étape d'avant).
   - Le screenshot montre un texte « precedent » qui **chevauche « Quitter »** (rouge) → corriger ce chevauchement (alignement des contrôles : Précédent · Quitter · Suivant).

8. **Ordre des étapes de la visite guidée peu intuitif.**
   - Les surbrillances ne suivent pas un ordre naturel (saut gauche↔droite).
   - → Réordonner pour suivre la **barre de nav de gauche à droite** (Accueil → Lieux → Jeux → Mates → Sécurité → Profil) ou un déroulé logique simple.

9. **Espacement en-tête : le « s » de SunMates colle au bouton thème.**
   - → Ajouter une marge/gap entre le wordmark `.brand` et le groupe d'actions (thème/cloche/déconnexion). Garantir un espace constant.

10. **Bouton(s) carré(s) dans Sécurité / Besoin d'aide.**
    - Concerné : écran « Besoin d'aide », boutons **~lignes 1989-1993** (« ☎️ Appeler les secours (112) », « 📍 Ma position », « 🚨 Alerte ») — coins trop carrés par rapport à la DA arrondie.
    - → Uniformiser le `border-radius` (arrondi/pilule cohérent) sur **tous** les boutons de Sécurité ; vérifier aussi l'icône/tuile SOS.

11. **Bloc carte surchargé (légende + chips).**
    - Légende : emoji **+** pastille colorée **+** texte, ×5 (Lieux sûrs, Mates, Activités, Check-ins, Partagées).
    - En plus, les chips au-dessus (Lieux 8 / Mates 15 / Activités 8 / Check-ins 6) cumulent emoji + compteur + couleur → **double signalétique** avec la légende.
    - → Garder **un seul repère visuel par item** et alléger l'ensemble (chips + légende). Vérifier aussi le fil « Ton fil / feedbacks récents » qui peut être trop chargé.

11b. **Profil : règles de sélection à définir intelligemment PAR catégorie** *(pas tout en multi).**
    - Le but n'est PAS de tout rendre multi-sélectionnable, mais d'avoir une **règle cohérente et adaptée à chaque catégorie**, clairement indiquée à l'utilisateur :
      - **choix unique** (radio) là où ça a du sens : genre, orientation, (éventuellement style de voyage) ;
      - **multi avec plafond** : « Je suis ici pour » (≈3 max), centres d'intérêt (≈5 max) ;
      - **multi libre** : langues parlées.
    - Aujourd'hui « Style de voyage » est le seul en sélection unique (`buildChips("styleChips", …, true)`, ~ligne 2940) **sans que ce soit indiqué** → perçu comme un bug.
    - → Choisir la règle par groupe, **l'afficher dans l'UI** (« Choisis-en un », « 3 max »), bloquer proprement au-delà du plafond, et adapter le style visuel (radio vs chips) en conséquence.

---

## 🟢 P3 — Produit / stratégie (important pour l'identité)

12. **Ne JAMAIS monnayer la sécurité.**
    - Le comparatif Gratuit/Gold contient `["Sécurité", "112 seul", "Complète"]` (~ligne 5723) : des features de sécurité sont derrière le paywall.
    - → **Toutes les features de sécurité gratuites pour tous.** Retirer la sécurité du comparatif (ou la marquer « incluse pour tous »). Monétiser plutôt : filtres avancés, boost de profil, cosmétique, badge Gold, coupons exclusifs.

13. **Clarifier le numéro de téléphone.**
    - S'il n'est « visible que par toi », son intérêt n'est pas clair.
    - → Soit expliquer son usage (ex. « utilisé uniquement pour l'**alerte d'urgence** / la vérification »), soit le retirer du formulaire.

14. **Valeur en solo (sans Mates).**
    - L'app doit être utile dès l'inscription, réseau vide : explorer les lieux, faire des quêtes en solo, voir la carte, contenu de démo visible.
    - → Vérifier que chaque écran a un **état solo** utile (pas que des « connecte-toi à quelqu'un d'abord »).

---

---

## 📱 P4 — Robustesse multi-OS / responsive (là où ça coince)

15. **Status bar / encoche (le « top » de l'app).**
    - Ajouter `viewport-fit=cover` au viewport, gérer `env(safe-area-inset-top)` sur `.topbar`/`.app-shell` (absent aujourd'hui), et `theme-color` dynamique (cf. #3). C'est la combinaison qui supprime la bande rose en nuit ET les chevauchements avec l'heure/la batterie sur iPhone à encoche.

16. **Zoom accessibilité (iOS).**
    - Le viewport (ligne 5) contient `maximum-scale=1.0` → **empêche le pinch-to-zoom** (anti-pattern d'accessibilité, surtout iOS). → le retirer.

17. **Bas d'écran / barre de nav.**
    - `env(safe-area-inset-bottom)` est déjà géré sur la nav 👍. Vérifier que **toutes** les overlays/feuilles (modales, démo, picker) respectent aussi le bas (barre gestuelle iOS) et le haut.

18. **Plein écran natif (Leaflet).**
    - `document.fullscreenElement` / `webkitFullscreenElement` est **inégal selon les navigateurs** (souvent KO sur iOS Safari) → privilégier le plein écran **CSS** (cf. #1), plus fiable cross-OS.

19. **Petits écrans / textes longs.**
    - 6 onglets + libellés : vérifier sur largeur ~320 px (vieux/petits Android). Appliquer une **troncature générale** des textes dynamiques (pseudos, villes, titres) pour éviter tout débordement.
    - Champs `date` (anniversaire) et emojis : le rendu varie selon l'OS — accepter ces différences mineures.

> Réalité : en PWA (pas natif), viser le « pixel-perfect » sur tous les OS est illusoire. L'objectif = **aucun débordement ni élément illisible** sur iPhone (à encoche) et 2-3 Android, en clair ET en nuit.

## 🌱 Autres pistes d'amélioration (hors correctifs — à explorer)
- **Avis & plans alimentés par les users** (inspi Mapster/Strava) : avis sur les lieux + plans/sorties à rejoindre — réutilisent cartes lieux, avatars et pins existants.
- **Cohérence des emojis-icônes** : beaucoup d'emojis servent d'icônes (rendu variable selon l'OS) → envisager un set SVG unifié pour les éléments clés (nav, actions).
- **Hiérarchie de l'accueil** : le bloc carte concentre énormément (titre, recherche, chips, carte, outils, légende, fil) → envisager de prioriser/condenser pour réduire la charge visuelle au premier coup d'œil.
- **Réglages (⚙️)** : centraliser thème, langue, confidentialité, compte dans un vrai panneau Réglages (allège l'en-tête et les écrans).

## Compte rendu attendu
Fichiers modifiés ; pour chaque correctif : titre + avant→après ; ce qui reste à valider (ordre de la visite, règles de sélection par catégorie, choix du bouton replay conservé) ; confirmation que Supabase / navigation / IDs sont intacts.

## Compte rendu attendu
Fichiers modifiés ; pour chaque correctif : titre + avant→après ; ce qui reste à valider (ordre de la visite, choix du bouton replay conservé) ; confirmation que Supabase / navigation / IDs sont intacts.
