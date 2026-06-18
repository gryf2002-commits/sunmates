# BRIEF DESIGN — Refonte Lite (MVP de lancement) — SunMates

> Produit par `/impeccable shape lite` le 16/06/2026. **Design planning — aucun code écrit.**
> S'appuie sur : `AUDIT_APP_v529.md`, `TEST_TECHNIQUE_v529.md` (contrat anti-régression), PRODUCT.md, DESIGN.md.
> Décisions actées avec Maxime : base = `index.html` + `body.sm-lite` raffiné · DA = sunset préservée · périmètre = mix par vagues.

## 1. Résumé
La « Lite » devient la **vraie première impression publique** de SunMates : le mode `sm-lite` du fichier existant, élevé au rang d'expérience de lancement — débarrassé du bruit beta, l'âme « sécurité d'abord » au premier plan, l'identité joaillerie présente mais **calme** (LOD : net, jamais de la soupe). Même monde sunset, juste désencombré et rassurant. Pour Chloé (voyageuse solo, mobile, parfois seule le soir), qui doit **se sentir rassurée ET sourire en quelques secondes**, sans être submergée.

## 2. Action primaire
**Comprendre en un coup d'œil qu'elle est en sécurité et qu'il se passe quelque chose autour d'elle** — puis agir vite si besoin (SOS / partage position toujours à portée). Tout le reste (jouer, rencontrer, explorer) est secondaire à cette réassurance immédiate.

## 3. Direction de design
- **Stratégie couleur : Committed** (avec discipline produit). Le monde sunset chaud *porte* la surface (c'est l'identité), mais l'accent corail est réservé aux actions/états (pas décoratif), neutres chauds pour les surfaces. Pas de Restrained timide : SunMates est identity-driven.
- **Phrase de scène** : *« Chloé, seule dans un café d'une ville inconnue au coucher du soleil, ouvre l'app entre deux moments : elle veut être rassurée et sourire en quelques secondes, sans rien chercher. »* → impose le mode clair chaud par défaut + le mode nuit prune (les deux existent déjà), et impose le **calme** (peu de mouvement au repos).
- **Références ancres** (produits, pas adjectifs) :
  1. **Duolingo** — gamification joyeuse et *rassurante*, badges/médaillons « joaillerie », personnalité sans puérilité.
  2. **Citymapper** — utilité voyage mobile ultra-claire, carte + listes lisibles, zéro friction.
  3. **Pokémon GO** — monde géolocalisé, pins de quêtes/lieux vivants autour de soi.
- **DA = source de vérité** : `DESIGN.md` + kit (corail `#FF5A4D`, or `#FFD15C`, teal sécurité `#11B5A0`, violet `#7A5CFF`, prune-nuit `#190E2E` ; Fraunces + Manrope). Aucune nouvelle couleur/typo.
- **Override de surface** : le bloc SOS/Sécurité peut monter en intensité (rouge sémantique réservé au danger) ; l'onboarding peut être plus *drenched* (écran d'accueil immersif). Le reste reste Committed-discipliné.

## 4. Périmètre (le « mix des trois » → plan par vagues)
**Fidélité : production-ready** (c'est le MVP qu'on lance). **Largeur : toute la surface**, livrée **par vagues priorisées**. **Interactivité : shipped-quality.** **Intention : peaufiner jusqu'au lançable.**

- **Vague 0 — Fondation Lite (socle invisible).** Faire de `sm-lite` un mode de premier rang : **défaut public = Lite** (beta-testeurs opt-in), **gating JS du chargement beta** (pas seulement CSS), garde-fous a11y/contraste/zoom, séparation `sunmates-lite.css` (« features lite » vs « DA calme »), pré-cache + pin Supabase. *(= solidité option 1 + contrat anti-régression)*
- **Vague 1 — Cœur « sécurité d'abord » (priorité).** Onboarding + Connexion + **Accueil** + **Sécurité** impeccables. *(= sous-ensemble prioritaire option 3)*
- **Vague 2 — Les piliers restants.** **Lieux**, **Mates + Messages**, **Jeux**, **Profil** épurés, production-ready. *(= les 6 piliers option 1)*
- **Vague 3 — Enrichissements.** Chat dédié soigné, showcase « Guide des ambiances », Livre blanc public. *(= écrans en plus option 2)*

## 5. Stratégie de layout
- **Mobile-first PWA**, structure inchangée (anti-régression) : barre de nav basse + panneaux d'onglet. Densité confortable, rythme 4/8 px, plus d'air qu'en mode complet (déjà amorcé par `lite.css`).
- **Hiérarchie par onglet** : un titre Fraunces, un état/CTA dominant, le reste subordonné. Sécurité = le SOS est l'élément le plus lourd visuellement de son écran.
- **Calme au repos** : zéro animation infinie sur l'accueil au repos ; le mouvement sert l'état (feedback, transition), pas la déco.
- **Nav (DÉCIDÉ)** : **Sécurité quitte la barre basse et passe en ACCÈS PERMANENT en haut à droite** (bouclier/SOS visible sur TOUS les écrans, pas seulement sur son onglet) → renforce « sécurité d'abord / toujours à portée ». Barre basse = **5 onglets : Accueil · Lieux · Jeux · Mates · Profil** (respecte la reco mobile ≤ 5). L'accès haut-droite ouvre le panneau Sécurité complet (SOS, partage position, ICE, minuteur, numéros). Migration nav à faire avec soin (anti-régression `goToTab` + état actif).

## 6. États clés (par écran + globaux)
- **Premier lancement** : onboarding (slides « Ta carte vivante… », Passer, revoir depuis le menu).
- **Vide** : aucun lieu/mate/quête autour → message chaleureux qui *enseigne* + 1 action (« Élargis ta portée », « Découvre un lieu »), jamais « rien ici ».
- **Chargement** : **skeletons** sunset (pas de spinner central), >300 ms.
- **Erreur / hors-ligne** : bandeau hors-ligne (déjà câblé) + repli ; toute action ratée = toast récupérable + retry (jamais d'écran figé). *(corrige le risque `render()` sans try/catch.)*
- **Sécurité — repos (par défaut)** : rassurant, SOS bien visible mais pas alarmant.
- **Sécurité — alerte active** : état clair « alerte envoyée à ton cercle », annulable.
- **Connecté vs non connecté** ; **Gold vs gratuit** (mais sécurité jamais gatée) ; **beta-testeur vs public** (public ne voit jamais les blocs beta, et ils ne se chargent pas).

## 7. Modèle d'interaction
- **Feedback systématique et VISIBLE** sur chaque action (toast en haut / inline) — l'audit rappelle le bug « toast invisible = on croit que rien ne marche ». Vérifier chaque interaction en navigateur.
- **Overlays** : fermables backdrop + croix + Échap (déjà câblé `popInfo`) ; ajouter `role=dialog`/`aria-modal` + piège de focus.
- **SOS / partage position** : confirmation DA avant diffusion (anti-miss-click), verrou anti double-envoi — **à préserver tel quel**.
- **Navigation** : `goToTab` nettoie recherches/composers ; transitions calmes 150-250 ms.
- **Onboarding** : Suivant/Passer ; **ne pas piloter dans des sections beta** (gater les étapes par `betaOn()`).
- **Cibles tactiles ≥44 px**, libellés sous les icônes de la tabbar (déjà en lite).

## 8. Contenu & exigences
- **Copie** : ton « vacances » — chaleureux, joueur, rassurant, **jamais anxiogène** (sécurité dite avec des mots qui rassurent). Genre via `_gw`.
- **i18n FR/EN** : promouvoir les chaînes Lite récurrentes dans `I18N_DICT` (EN maîtrisé, hors-ligne) plutôt que le filet MyMemory ; traduire les `alt`.
- **Messages d'état** : empty states qui enseignent ; erreurs avec chemin de récupération (« Réessayer »).
- **Assets réels** : carte interactive (Leaflet/MapLibre), pins lieux/mates/quêtes, badges/emblèmes joaillerie (SVG maison, repli emoji systématique), photos de lieux. **Aucune banque d'icônes générique** (anti-référence PRODUCT.md).
- **Micro-règles DA** : statuts validé/en-ligne en ambre/doré (jamais vert criard), rouge=danger uniquement.

## 9. Références impeccable recommandées (pour l'implémentation)
- `harden.md` — défaut public, gating beta, états d'erreur, offline, edge cases (cœur de la Vague 0).
- `onboard.md` — onboarding + empty states + activation (Vague 1).
- `clarify.md` — copie UX rassurante, libellés, messages d'erreur.
- `layout.md` — rythme/hiérarchie des piliers, question barre de nav.
- `audit.md` (technique) + corrections a11y : contraste `--accent-ink`, `aria-label` ✕, `role=dialog`, zoom.
- `animate.md` — calmer le mouvement, transitions d'état (avec `prefers-reduced-motion`).

## 10. Décisions actées (16/06, avec Maxime)
1. ✅ **Brief validé** dans son cadre (base sm-lite, DA sunset, vagues V0→V3, contrat anti-régression).
2. ✅ **Défaut public = Lite** : les nouveaux/non-marqués arrivent en Lite épurée ; les beta-testeurs sont marqués (flag Supabase ou opt-in). Inverse le défaut actuel (beta ON).
3. ✅ **Nav = 5 onglets** (Accueil · Lieux · Jeux · Mates · Profil) + **Sécurité en accès permanent haut-droite**.
4. ▶️ **Ordre d'exécution** : commencer par **Vague 0 + Vague 1** (socle + cœur sécurité) en **preview**, faire valider par Maxime, puis Vagues 2-3. Aucun push sans son feu vert.
