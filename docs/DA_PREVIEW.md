# DA en PREVIEW — déployer sans toucher sunmatesapp.com

But : pousser le système DA + la version lissée **sans changer ce que voit le public**,
pour qu'on itère en parallèle (code ↔ console) en toute sécurité.

## Pourquoi c'est sûr par défaut
Le loader est **inerte sans données**. `sunmates-da-loader.js` → `getTokens()` renvoie `null`
s'il n'y a ni `window.SM_DA_TOKENS`, ni brouillon `localStorage('sm_da_live')`, ni `da_tokens`
publié → `applyTokens()` sort immédiatement, **aucune variable n'est posée**. Donc :
> Ajouter le `<script>` du loader = zéro changement visible tant qu'un admin n'a rien publié.

## Push minimal recommandé (preview)
1. `index.html` : inclure les deux fichiers, **après** le gros script app :
   ```html
   <script src="sunmates-da-loader.js?v=5"></script>
   <link  rel="stylesheet" href="sunmates-lite.css">   <!-- inerte sans body.sm-lite -->
   ```
2. **Ne PAS** publier de tokens DA en prod pour l'instant (la table reste vide côté public).
3. **Bumper `VER`** dans `sw.js` (coquille PWA).
Résultat : public = identique à aujourd'hui ; admin = peut tester via la console overlay.

## Gates de prévisualisation (pour voir sans exposer)
- **DA admin** : la console overlay est déjà **admin-only** (`isAdminApp()`), bypass test `?daforce=1`.
- **Version lissée** : tant qu'on valide, garder beta **ON par défaut pour tous**, et n'activer la
  lite qu'à la demande :
  ```js
  // boot
  var force = new URLSearchParams(location.search).has('lite');
  var beta  = force ? false
            : (myProfile && myProfile.beta!=null ? myProfile.beta : true); // public=ON le temps du test
  setBeta(beta);                       // pose/retire body.sm-lite
  ```
  → ouvrir `…/?lite=1` montre la DA lissée à la demande ; personne d'autre ne la voit.
- Quand on est satisfaits : passer le défaut public à `false` (lite) en une ligne.

## Aperçu hors-ligne (déjà livré)
`sunmates-lite-preview.html` rend la version lissée sur 5 écrans (autonome, double-clic).
C'est la **cible visuelle** de `sunmates-lite.css` — sert de référence à code.

## Check anti-troncature avant commit
- `index.html` finit par `getSession().then(...)` → `</script>` → les 2 lignes DA → `</body></html>`.
- `da-console.html` finit par `</body></html>`.
- `node --check` sur le DERNIER `<script>` de chaque fichier.
