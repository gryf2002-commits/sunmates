# Brief — Nettoyage, cohérence visuelle & idées pour SunMates

> À coller dans Claude Code. Travaille sur `index.html` (≈5 800 lignes, app web SunMates).
> **Contraintes à respecter absolument :**
> - Un **seul `index.html` déployable** (HTML/CSS/JS vanilla, pas de build, pas de framework).
> - Backend = **Supabase** côté client (ne casse aucun appel `db.from(...)`, ni les IDs utilisés par le JS).
> - Hébergement **GitHub Pages**. Ne touche pas aux clés ; la clé `anon` est publique par design.
> - **Ne change pas le comportement fonctionnel** sans le signaler. Surtout : ne renomme pas d'`id` HTML sans mettre à jour le JS.
> - À la fin, **liste précisément tout ce que tu as modifié** (fichier, lignes, avant/après résumé) pour que je puisse faire vérifier.

---

## 🔴 PRIORITÉ 1 — Coquilles à corriger (sûr, rapide)

1. **Supprimer le code mort `renderRecos()`** (~ligne 3498).
   Cette fonction n'est plus appelée nulle part et référence `#recoSection` / `#recoList`
   qui n'existent plus dans le HTML (elle planterait si on l'appelait).
   → Supprimer la fonction entière (et tout reliquat de markup `recoSection`/`recoList`/CSS `.reco*` devenu inutile, **seulement** s'il n'est plus utilisé — vérifie avant).

2. **Nettoyer le CSS mort / dupliqué :**
   - `@keyframes fadeUp` : défini mais jamais utilisé → supprimer.
   - `.search { … }` est déclaré **2 fois**, `.search-clear { … }` **3 fois** → fusionner en une seule déclaration chacune.
   - Deux règles identiques `.tab-panel:not(.hidden) { animation: tabFade … }` → n'en garder qu'une.

3. **Vérification finale** : après ces suppressions, confirme que :
   - aucun `id` référencé en JS (`$("…")`) n'est manquant dans le HTML
     (sauf `homeCafes` et `map`, déjà protégés par `if(!el) return`),
   - `node --check` (ou équivalent) sur le bloc `<script>` ne renvoie pas d'erreur de syntaxe.

---

## 🟠 PRIORITÉ 2 — Cohérence visuelle (gros gain, risque moyen)

4. **Consolider la palette chaude.** Il existe ~55 nuances orange/corail très proches en dur
   (`#ff6a5d`, `#ff6a6a`, `#ff6a78`, `#ff6b6b`, `#ff7e5f`, `#ff7e72`, `#ff9b7c`, `#ff9f6b`…),
   ce qui rend le rendu légèrement incohérent d'un écran à l'autre.
   → Définir un jeu réduit de variables dans `:root` et **remplacer les valeurs en dur** :
   ```
   --accent:#f4655e; --accent-2:#ff8a7d; --accent-3:#ffb274;
   --gold:#ffd15c; --violet:#7a5cff; --teal:#19b36b;
   ```
   Mappe chaque nuance proche vers la variable la plus proche. Objectif : ne plus avoir
   2 corails différents à 3 unités d'écart. **Garde le rendu globalement identique**, juste cohérent.

5. **Échelle de `z-index` nommée.** Aujourd'hui les valeurs vont de 1 à 6000 sans logique
   (pwa 400, alerte 1000, carte plein écran 3500, onboarding 4000, tour 4200, overlay 4300,
   démo 5000, confettis 6000). → Centraliser en variables et réordonner proprement :
   ```
   --z-nav:60; --z-banner:1000; --z-map-fs:3000; --z-overlay:4000;
   --z-tour:4200; --z-toast:5000; --z-confetti:6000;
   ```
   Vérifie qu'aucun overlay ne passe sous un autre.

6. **Alléger le thème sombre.** 86 `!important` (surtout `body.theme-dusk`). Migrer un maximum
   vers des **variables CSS** redéfinies sous `body.theme-dusk { --card:…; --paper:…; }` pour
   supprimer la plupart des `!important`. Ne casse pas le rendu sombre actuel.

7. **Barre de navigation à 6 onglets** (Accueil, Lieux, Jeux, Mates, Sécurité, Profil) :
   libellés à `.62rem`, trop serré sur petit écran. → Proposer une version à **5 entrées**
   (ex. fusionner « Lieux » dans l'accueil/carte, ou passer « Sécurité » en bouton flottant),
   OU icônes seules avec libellé visible uniquement sur l'onglet actif. Me proposer l'option avant d'appliquer.

8. **Typographie.** Fraunces (titres) + Manrope (UI) sont chargées : vérifier qu'elles sont
   **appliquées partout** (certains titres semblent rester en Poppins) pour une signature cohérente.

---

## 🟢 PRIORITÉ 3 — Idées d'amélioration (UX / produit / techno)

UX & produit :
- **Transparence du score de compatibilité** : afficher le détail (« +25 % même ville, +20 % 3 intérêts communs ») sur la fiche profil.
- **Onboarding → action** : finir l'onboarding sur un profil pré-rempli + checklist « complète ton profil (+points) ».
- **États vides actionnables** : chaque `.empty` doit avoir un bouton (« Trouve ton 1er Mate », « Ajoute une photo »).
- **Chat** : accusés de lecture / « en train d'écrire », regroupement des messages par jour.
- **Cohérence des icônes** : les emojis varient selon l'OS → envisager un set d'icônes SVG.

Accessibilité :
- Vérifier les **contrastes** (texte blanc sur dégradé clair `#ffb274` peut échouer au ratio AA).
- Ajouter des `aria-label` sur les boutons-icônes. `:focus-visible` est déjà géré 👍.

Technique :
- **Séparer `app.js` et `styles.css`** du `index.html` (autorisé sur GitHub Pages, la contrainte « 1 fichier » concerne le déploiement statique, pas l'interdiction de fichiers liés). Gain énorme en lisibilité sur 5 800 lignes.
- **Délégation d'événements** : 173 `addEventListener` souvent ré-attachés après `innerHTML` → un listener sur le conteneur + `data-*`. Réduit le code et les fuites mémoire.
- **Couche d'accès données** : regrouper les appels Supabase (`db.profiles.list()`, `db.messages.send()`…).
- **État réseau global** : afficher un bandeau « hors-ligne / erreur » quand Supabase ne répond pas.

Sécurité / données :
- Les comptes démo (`%@demo.sunmates`, `is_demo=true`) : prévoir un nettoyage avant prod.
- Bien marquer la vérification comme **simulée** côté produit (cœur de promesse « sécurité »).

---

## Format de compte rendu attendu
À la fin, renvoie :
1. La liste des fichiers modifiés.
2. Pour chaque changement : un titre + un résumé court (avant → après).
3. Ce que tu n'as pas fait (et pourquoi), notamment les points qui nécessitent mon avis (onglets de nav).
4. Confirmation que rien de fonctionnel (Supabase, navigation, IDs) n'est cassé.
