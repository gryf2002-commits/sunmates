# Brief pour `code` — DA SunMates (consolidé, à jour)

But : la table DA pilote toute l'app + console DA utilisable. Tout vérifié `node --check`
(y compris le DERNIER `<script>` de chaque fichier, pas un bloc antérieur).

## ⚠️ Anti-troncature (à checker AVANT commit)
- `index.html` doit finir par : `db.auth.getSession().then(...render...)` → `</script>`
  → `<script src="sunmates-da-loader.js?v=5"></script>` → `</body></html>`.
- `da-console.html` doit finir par `</body></html>` (PAS par `function advRefresh(){var m=T.modes[curM`).
  Le transfert coupe les lignes très longues : la fin de la console a été réécrite en lignes courtes.
- Historique : git HEAD avait la console tronquée → ce push la répare.

## Fichiers à pousser
1. `index.html`
2. `sunmates-da-loader.js`
3. `sunmates-icons-v2.js`
4. `da-console.html`
5. `sunmates-da-history.sql` (à exécuter dans Supabase)

## Supabase
- Lancer `sunmates-da-history.sql` (table `da_history` + RLS) — pour Versions/rollback (sinon « indisponible », non bloquant).
- Activer **Realtime** sur `da_tokens` et `da_strings` — pour le live-push (sinon inerte, non bloquant).
- `da_tokens` / `da_strings` déjà en place.

## Caches
- Dans `index.html` déjà : `sunmates-icons-v2.js?v=542`, `sunmates-da-loader.js?v=5`.
- **Bumper `VER` dans `sw.js`** à chaque push (coquille PWA).

## Ce que la DA pilote (loader)
- Variables-cœur par mode dérivées de `{page,ink,j1,j2,angle}` :
  `--bg,--ink,--text,--muted,--line,--card,--cream,--accent,--accent-2/3,--accent-grad,--accent-soft,--ring`.
- Forme des tuiles (`effects.shape` → border-radius), tailles (`sizes.tile/iconTile` → tuiles d'accueil),
  logos header (`--sm-logo`).
- **Couleur des icônes (`icon.colorMode`)** : `natural` = couleurs designées de la banque (cohérentes,
  pas d'override) ; `mono` = UNE couleur (`icon.mono`) → contraste icône/tuile pilotable.
- **Style d'icônes (`icon.style`)** : `native` → `SM_NO_EMOJIZE` + classe `sm-native`, la banque
  arrête de peindre (emojis natifs). `fill/line/duo` = banque.
- Emojis : `emoji.off` (global) + `emoji.keepNative[]` (garder natifs précis) → `SM_NO_EMOJIZE`/`SM_EMOJI_KEEP`.
- Couleurs de police (`typo.titleColor/bodyColor/metaColor`), polices (+Google Fonts), effets, a11y, textes (i18n).
- Banque d'images : `window.SM_IMGBANK` + `window.SMImg(key,seed)` (URL configurée sinon repli picsum).

## Banque (`sunmates-icons-v2.js`)
- SMIconize : convertit les emojis bruts en emblèmes SVG (skip contenu utilisateur), respecte
  `SM_EMOJI_KEEP` + `SM_NO_EMOJIZE` ; emblèmes emoji centrés. Kill-switch `window.SM_NO_EMOJIZE=true`.

## `index.html` (tuiles → DA)
- Suivent la DA : `.thumb/.cic/.smgem/.jo-ic` (joyaux+forme+taille), en-têtes lieux `.gh-*`/`.ghead.green`,
  `.pcard-eco`, `.vchip`, `.avail-*`, `.trip-dates`, `.rate-top`, `.gplay-xp`, `.qm-coral`,
  `.act-challenge/.act-bff/.act-map/.act-teal`, surfaces nuit `theme-dusk` (→ `var(--card)/--cream)`).
- Gardés rouges (sémantique danger) : `.su-call/.su-sos`, `.act-block`.
- Marqueurs carte (`epinIcon`) : emblème SVG en **auto-contraste** (plus « toujours blanc »).
- Hooks DA : `subscribeDA` (live-push), archive `da_history` au publish, bouton « Versions »,
  listener `postMessage` (console → `#daLiveJson`).

## `da-console.html` (refonte)
- 21 presets (11 d'origine retravaillés + 10) ; chaque preset restyle tout (modes/police/icônes/effets/accent/pages).
- `colorMode` calé par preset : vibes tonales = `mono` (couleur cohérente), vibes fun = `natural`, Natif = `native`.
- **Refonte ergonomie** : barre d'onglets (Couleurs · Icônes · Typo · Contenu · Avancé) + **recherche** en tête.
- Cases couleurs rapides sous chaque picker (preset + 8 récentes), y compris couleurs de police.
- Section Emojis (toggle global + garder-natif). Aperçu interactif (clic mode = focus).
- Panneau Avancé (Typo/contraste, Composants, Logos maison, Icône-app, Banque d'images) — RÉPARÉ
  (il était tronqué et planté → contraste/police/logos remarchent).
- Envoi vers admin via `postMessage(opener)`.

## À tester après push (pas de navigateur côté cowork)
- Changer `colorMode` natural↔mono → icônes recolorent ; native → emojis natifs (au reload).
- Forme/taille tuiles bougent ; logos recolorent ; couleurs de police + contraste réglables (panneau Avancé).
- Marqueurs carte lisibles jour/nuit. Presets cohérents (plus de « random »).
- Console : onglets + recherche OK ; publier → app suit ; live-push si Realtime activé.
