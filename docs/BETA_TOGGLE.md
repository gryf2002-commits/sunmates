# Toggle Beta-testeurs / version « lissée » — prêt à coller pour `code`

But : laisser l'utilisateur activer/désactiver les fonctionnalités beta. OFF = version épurée
qui répond à la problématique cœur (sécurité + rencontres + lieux), sans les features expérimentales.

## Principe
- Un flag `beta` (localStorage `sm_beta` + colonne profil optionnelle `profiles.beta`).
- Classe sur `<body>` : `sm-lite` quand beta OFF.
- Tout élément/feature beta porte `data-beta` (ou classe `.beta-only`) → masqué en mode lissé via CSS.
- Les écrans cœur (Accueil, Lieux, Sécurité, Mates, Profil) restent toujours visibles.

## 1) CSS (dans index.html <style>)
```
body.sm-lite [data-beta],
body.sm-lite .beta-only { display:none !important; }
body.sm-lite .beta-badge { display:none !important; }
```

## 2) JS (init, après le profil chargé)
```
function setBeta(on){
  try{ localStorage.setItem('sm_beta', on?'1':'0'); }catch(e){}
  document.body.classList.toggle('sm-lite', !on);
}
function betaOn(){ try{ return localStorage.getItem('sm_beta')!=='0'; }catch(e){ return true; } }
setBeta(betaOn());            // applique au boot
window.setBeta = setBeta;     // pour le toggle réglages
```

## 3) UI — un toggle dans Réglages (groupe « Expérimental »)
```
<label class="set-toggle"><span>Fonctionnalités beta</span>
  <input type="checkbox" id="betaToggle"></label>
```
```
var bt=document.getElementById('betaToggle');
if(bt){ bt.checked=betaOn(); bt.onchange=function(){ setBeta(bt.checked); }; }
```

## 4) Marquer les features beta
Ajouter `data-beta` sur les blocs expérimentaux (ex. easter eggs avancés, jeux de groupe,
boutique, mode rétro, scènes saisonnières, vouch avancé…). Le cœur produit reste sans `data-beta`.

## 5) (option) défaut par cohorte
- Beta-testeurs : `beta` ON par défaut (depuis `profiles.beta`).
- Grand public : OFF par défaut → version lissée.
Au boot : `setBeta(myProfile && myProfile.beta != null ? myProfile.beta : false_pour_public);`

Aucune dépendance ; réversible ; n'enlève jamais les piliers sécurité.

## 6) Version lissée = DA neutre/sobre (NOUVEAU)
La version lissée (beta OFF) ne se contente pas de masquer les features beta : elle bascule
sur une **DA neutre, sobre et fonctionnelle** (esprit Stitch) via `sunmates-lite.css`.

- Inclure dans `index.html` (après les styles app) :
  `<link rel="stylesheet" href="sunmates-lite.css">`
- `setBeta(v)` pose/retire la classe sur `<body>` :
  ```
  function setBeta(v){ localStorage.setItem('sm_beta', v?'1':'0');
    document.body.classList.toggle('sm-lite', !v);   // beta OFF => DA lissée neutre
    /* …reste inchangé (data-beta hidden, etc.) */ }
  ```
- Effet de `body.sm-lite` (déjà écrit dans `sunmates-lite.css`) : un seul accent retenu,
  surfaces plates, zéro gloss/dégradé décoratif, animations réduites, coins sobres,
  surfaces nuit ramenées en clair neutre. **Danger/SOS gardent le rouge sémantique.**
- Côté console : preset **« ⚪ Lite / Neutre »** ajouté → on peut prévisualiser/éditer cette
  DA comme les autres. (La lite publique = `sunmates-lite.css`, indépendante de la DA admin,
  donc robuste même DA non déployée.)
