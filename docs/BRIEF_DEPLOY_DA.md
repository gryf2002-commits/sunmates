# DÉPLOIEMENT DA — état réel & ce que code doit pousser (DÉBLOQUE TOUT)

## Constat (sondé en live sur sunmatesapp.com)
- La page live ne charge QUE `sunmates-badges.js` + `sunmates-icons-v2.js?v=541`.
- **PAS de `sunmates-da-loader.js`** → `window.SMDA` = undefined, `#sm-da-vars` absent.
- Donc TOUT le système DA (loader, variables-cœur, presets, console) **n'est pas en ligne**.
- `window.goToTab` ✓ et `window.SMIcon` ✓ sont exposés (bon).

→ Rien de DA ne peut marcher tant que ce n'est pas déployé. Ce n'est pas un bug du code DA,
c'est qu'il n'est jamais arrivé sur le site.

## À pousser par `code` (ordre)
1. **Banque** : `sunmates-icons-v2.js` (v542, recolorable + SMIconize) → bumper le tag à `?v=542`.
2. **Loader** : déployer `sunmates-da-loader.js` ET ajouter le tag dans `index.html`
   APRÈS le gros script app (en fin de body) : `<script src="sunmates-da-loader.js?v=5"></script>`.
   (Le loader expose `window.SMDA` et applique les tokens.)
3. **Supabase** : `da_tokens` / `da_strings` déjà ok ; lancer `sunmates-da-history.sql` (versions).
4. **Exposer sur window** (pour la console admin) : `window.myProfile = myProfile;`
   `window.isAdmin = isAdmin;` (et garder `window.goToTab`). Une ligne chacun.
5. **Console overlay (admin)** : déployer `da-console-overlay.js` + tag admin-gated :
   `<script src="da-console-overlay.js?v=1"></script>` (il ne s'affiche que si `isAdmin()`).
   Le bouton flottant « ✦ DA » apparaît alors pour les admins ; panneau = édition live.
6. **SW** : bumper `VER` dans `sw.js`.

## Test
- Après déploiement + connexion ADMIN : le bouton ✦ DA apparaît bas-droite → panneau live.
- Test rapide sans attendre le câblage `isAdmin` : ouvrir `sunmatesapp.com/?daforce=1` (bypass de garde,
  à retirer en prod) pour voir l'overlay même non-admin.

## Pourquoi l'iframe (da-console-v2) ne marchait pas
Cross-origin / app non déployée / non connecté. L'overlay in-app (`da-console-overlay.js`) est la bonne
voie : même document, pas de blocage d'origine, admin-gated, édite la vraie app en live.
