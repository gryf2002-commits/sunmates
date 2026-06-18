# Intégration de la console DA dans SunMates

Objectif : piloter toute la DA (couleurs/modes/icônes/effets/logos/textes) depuis
l'onglet admin, en quasi temps réel, via une source de vérité Supabase.
Rien n'est appliqué au live tant que tu n'as pas fait ces étapes (à pousser avec `code`).

## Pièces livrées
- `sunmates-da-loader.js` — applique les tokens/strings à l'app au démarrage.
- `sunmates-da-schema.sql` — tables Supabase `da_tokens` / `da_strings` (config 1 ligne).
- `da-console.html` — la console (édition + export). Sert de base pour l'admin.

## Étape 1 — Supabase
Exécute `sunmates-da-schema.sql` dans le SQL Editor. Adapte la condition « admin »
(par défaut `profiles.is_admin`) à ton mécanisme si besoin.

## Étape 2 — Charger la DA AVANT le rendu (dans `index.html`)
Tout en haut du gros `<script>` de l'app (avant que `render()`/les loaders tournent),
récupère la config et expose-la pour le loader :

```js
try {
  const [tk, st] = await Promise.all([
    db.from('da_tokens').select('tokens').eq('id', 1).maybeSingle(),
    db.from('da_strings').select('strings').eq('id', 1).maybeSingle()
  ]);
  if (tk?.data?.tokens && Object.keys(tk.data.tokens).length) window.SM_DA_TOKENS = tk.data.tokens;
  if (st?.data?.strings && Object.keys(st.data.strings).length) window.SM_DA_STRINGS = st.data.strings;
} catch (e) {}
```

## Étape 3 — Inclure le loader (dans `<head>` d'`index.html`, après `sunmates-icons-v2.js`)
```html
<script src="sunmates-da-loader.js?v=1"></script>
```
Le loader applique : joyaux par mode, polices, tailles/effets (variables + classes
`sm-no-polish` / `sm-mirror` / `sm-no-shadow`), couleurs d'emblèmes (voir note ⚠️),
logos (`--sm-logo`), et override des textes via `i18nT`.

## Étape 4 — Brancher la sauvegarde dans l'onglet admin
Dans ton panneau `#daTokens`, ajoute les contrôles de `da-console.html`
(ou intègre la console en `<iframe>` au début, le temps de fusionner).
Quand l'admin valide, sauvegarde :

```js
async function saveDA(tokens, strings) {
  await db.from('da_tokens').upsert({ id: 1, tokens, updated_by: myUserId });
  if (strings) await db.from('da_strings').upsert({ id: 1, strings, updated_by: myUserId });
  SMDA.apply(tokens); SMDA.applyStrings(strings); // aperçu immédiat
}
```
Aperçu perso instantané sans publier : `SMDA.saveDraft(tokens, strings)` puis recharger
(le loader lit `localStorage 'sm_da_live'`). C'est ce que fait « Tester en live » de la console.

## ⚠️ Note couleur des emblèmes
Les couleurs d'icônes par catégorie (`--icc`) ne s'appliquent que si la banque
`sunmates-icons-v2.js` rend les glyphes en `currentColor`. La version « sticker »
actuelle **fige** les couleurs dans le SVG. Pour rendre les couleurs pilotables,
regénérer la banque en mode `currentColor` (drapeau prévu) — à faire dans un 2ᵉ temps.

## Reste à brancher plus tard (noté)
- recolor réel des emojis de la carte ; banque d'images (catégories → source) ;
- icône app / favicon / PWA (fichiers séparés `icon-*.png`) générés depuis l'icône choisie ;
- fusion complète des contrôles de la console dans `#daTokens` (vs iframe) ;
- versions/rollback (colonne `updated_at` déjà là).
