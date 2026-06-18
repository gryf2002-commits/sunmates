# Réponse à code — quelles features tagger « beta » (et comment)

Principe : OFF = version lissée qui répond au cœur (Sécurité + Rencontres + Lieux). On part de
« celles du brief » + précisions. Deux mécanismes :
- **DOM** (bloc visible) → ajouter `data-beta` sur l'élément (caché par `body.sm-lite`).
- **Comportement JS** (eggs, FX, sons) → envelopper le déclencheur dans `if (betaOn()) { … }`
  (sinon CSS ne suffit pas à désactiver le code).

## ✅ Cœur — JAMAIS beta (toujours visible)
Accueil (carte, recherche, accès rapides), Lieux + check-ins, Sécurité (SOS, position, cercle,
contacts ICE), Mates (découverte, messages, demandes, fiche profil), Profil (édition, vérification),
Classement de base, Badges de base, vérification de confiance.

## 🧪 À tagger BETA
### A. DOM → `data-beta`
- **Boutique SunCoins** : `#jeuxShop` + l'entrée de nav `.cat-tile[data-jeuxnav="shop"]`.
- **Cadres d'avatar cosmétiques** : `#shopFrames` (et `#shopTitles` si tu veux).
- **Quêtes de groupe / défis reçus** : `#groupConfirmSection`, `#suggestionsSection`.
- **Bouton « 🧪 Ton avis compte »** : déjà tagué (garder, c'est la démo).
- (option) **Rituels / défis solo avancés** accueil-maison : `#soloRituals`, `#soloChallenges`.

### B. Comportement JS → `if (betaOn()) { … }`
- **Easter eggs avancés** : `eggKonami` + `_crtFx`/mode rétro 8-bit, `eggBalloons`, `eggPlane`,
  `eggGlobe`, `_eggTitanicCheck`, `_eggWhaleCheck`, `eggShake`, `eggMagicWords`
  (soleil/42/hakuna). → garder simples : anniversaire + confettis de célébration restent.
- **Scènes saisonnières** : pluie de saison + bonnets de Noël sur les pins (`renderSeasonFx`/xmas).
- **Vouch avancé** : la carte vouch sur la fiche mate (`#tpVouchCard`).
- **Sons d'ambiance** (`SMSound`) : OK de les couper en lissé.

## Reste hors-scope beta (décision produit, à toi de voir)
Gold/Premium, Espace Pro, mode rétro : je les laisse hors `data-beta` sauf si tu veux les cacher
au grand public. Dis-moi si tu veux les inclure.

## Récap pour code
« Tague A en `data-beta`, garde B derrière `betaOn()`, ne touche jamais au cœur. »
Défaut public = OFF (lissé) ; beta-testeurs = ON (via `profiles.beta`).
