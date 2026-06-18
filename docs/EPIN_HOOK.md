# Hook marqueurs carte (epin) — prêt à coller pour `code`

Problème : les pins Leaflet (`.epin`) reçoivent leur couleur de fond en JS inline → ne suivent
pas la DA (confirmé en live : pins orange même en preset Neon).

Solution mini-invasive : faire lire une variable CSS `--epin` (posée par le loader par mode),
avec repli sur la couleur passée. Les pins « toi »/« quête » gardent leur couleur sémantique.

## 1) index.html — fonction epinIcon (~L15422)
Remplacer dans le template :
```
html: `<div class="epin ${extra||''}" style="background:${bg}">...`
```
par :
```
html: `<div class="epin ${extra||''}" style="background:var(--epin, ${bg})">...`
```
(une seule occurrence ; ne touche pas `.epin.me` / `.epin.quest` qui ont leur pulse propre).

## 2) sunmates-da-loader.js — poser --epin par mode (dans la boucle des modes, où on a `acc`)
Ajouter après la pose des variables-cœur :
```
css += sel + '{--epin:' + acc + ';}\n';
```
→ tous les marqueurs génériques prennent l'accent du mode ; repli automatique si non défini.

## 3) (option) clusters
`.epin-cluster` : même logique, ajouter `background:var(--epin, …)` sur leur fond inline.

Résultat : les pins de la carte suivent la DA dans les 6 modes, sans casser la sémantique
(toi = corail pulse, quête = ambre pulse). Aucun autre changement requis.
