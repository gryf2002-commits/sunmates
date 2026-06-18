# Console DA v2 (live, iframe = vraie app) — brief pour `code`

## Principe
`da-console-v2.html` + `da-console-v2.js` : la console charge l'app réelle dans un `<iframe src="index.html">`
et lui applique la DA en live (`SMDA.apply`), navigue (`goToTab`), bascule les 6 modes (classes thème),
desktop/mobile (largeur iframe), et permet le **clic-recolor** sur de vrais éléments (override CSS injecté
dans l'app, scopé par mode). → fidélité 100% (c'est l'app).

## Contrainte d'origine (obligatoire)
Doit être servie **même origine que l'app** (sunmatesapp.com) pour accéder au contenu de l'iframe.
- Déployer `da-console-v2.html` + `da-console-v2.js` à la racine (GitHub Pages) → `https://sunmatesapp.com/da-console-v2.html`.
- En `file://`/cross-origin : l'accès iframe est bloqué (la console affiche un avertissement).

## Accès EXCLUSIF admin (demandé)
- La console contient déjà une **garde** : elle lit `iframe.window.isAdmin()` / `myProfile.is_admin` ;
  si non-admin → verrouillée (message + contrôles off).
- Côté app : n'exposer le **bouton « Ouvrir la console DA v2 »** que dans Profil → Admin → DA
  (à côté de l'ancien). Ex : `window.open('da-console-v2.html')`.
- Publication : garder la **RLS Supabase** (`da_tokens` admin-only) comme verrou serveur réel.

## Pré-requis côté app (vérifier qu'ils sont exposés globalement sur window)
- `window.SMDA` (déjà : loader) · `window.goToTab(tab)` (routeur, ~L8484) ·
  `window.myProfile` et/ou `window.isAdmin()` (auth admin) · `window.SM_DA_TOKENS` / `localStorage 'sm_da_live'`.
- Si `goToTab`/`isAdmin`/`myProfile` ne sont pas sur `window`, les exposer (`window.goToTab = goToTab;` etc.).

## Override ciblé (clic) — pour aller plus loin avec code
- La console injecte dans l'app un `<style id="sm-da-ovr">` : `body.<themeclass> <selector>{--ic1/--ic2/bg}`.
- Sélecteur = classes de l'élément cliqué. Pour de l'override **par instance** (et pas par classe),
  prévoir côté app un `data-da-id` stable par élément (optionnel, amélioration).
- Persistance/publication des overrides : à brancher dans le flux admin (upsert `da_tokens.overrides`).

## Statut
- `node --check` OK (html + js). Non testable hors-ligne (besoin même origine + session admin).
- Paquet suivant : réintégrer les 22 sections de contrôle de l'ancienne console (glyphes, i18n, badges,
  logos, scènes, récompenses, icône-app, banque d'images) dans le panneau v2.
