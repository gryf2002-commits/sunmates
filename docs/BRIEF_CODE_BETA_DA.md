# Brief code — Beta toggle + Version lissée + DA en preview
Réponse à ton dernier message (epin dormant OK ✅ · beta toggle v499 ✅ · « quelles features tagger ? »).
On reste **hors-prod** : tout en preview, on push en prod quand Max valide. ⚠️ Ne pas régresser sunmatesapp.com.

## 1) Réponse : quoi tagger beta (ta question)
Oui, « celles du brief » — voici la liste exacte et la méthode.

**Cœur produit = JAMAIS beta** (pas de `data-beta`, jamais derrière `betaOn()`) :
Accueil, Lieux + check-ins, Sécurité (SOS / partage position / cercle de confiance),
Mates (connexions), Profil, vérification, classement & badges de base.

**A. À tagger en `data-beta` (DOM, masqués si lissée)**
- Boutique : `#jeuxShop` **+** la nav `.cat-tile[data-jeuxnav="shop"]`
- Cadres d'avatar : `#shopFrames`
- Quêtes de groupe : `#groupConfirmSection` **+** `#suggestionsSection`
- Bloc « 🧪 Ton avis compte » (déjà fait)
- Option : `#soloRituals` / `#soloChallenges`

**B. À garder derrière `if(betaOn()){…}` (comportement, pas du DOM)**
- Easter eggs avancés : `eggKonami`/`_crtFx` (rétro), `eggBalloons`, `eggPlane`, `eggGlobe`,
  `_eggTitanicCheck`, `_eggWhaleCheck`, `eggShake`, `eggMagicWords`
- Scènes saisonnières (pluie / bonnets de Noël sur les pins)
- `#tpVouchCard` (vouch avancé)
- `SMSound` (sons d'ambiance)

Règle d'or : si un doute pourrait masquer du cœur → ne PAS tagger, demander.

## 2) IMPORTANT — la version lissée reste COLORÉE (correction)
La lissée n'est **pas** un thème gris/neutre. C'est **la même DA sunset**, juste **plus simple** :
moins de gamification visible, animations calmées, blocs beta masqués. Beauté conservée.

- Fichier `sunmates-lite.css` **réécrit** dans ce sens (garde couleurs/joyaux/dégradés ;
  calme les anims ; double-masque `[data-beta]` ; aère ; arrondis homogènes ; garde le rouge danger).
- `setBeta(v)` :
  ```js
  function setBeta(v){
    localStorage.setItem('sm_beta', v?'1':'0');
    document.body.classList.toggle('sm-lite', !v); // OFF => lissée (DA sunset simplifiée)
    /* + masquage data-beta déjà en place */
  }
  ```
- Inclure dans `index.html` (après les styles app) : `<link rel="stylesheet" href="sunmates-lite.css">`
- **Référence visuelle** : `sunmates-lite-preview.html` (5 écrans, DA sunset, nav qui marche) =
  la cible esthétique. Toggle « features beta » dedans pour voir l'écart lissée ↔ beta.

## 3) DA déployable EN PREVIEW (sans rien changer pour le public)
Le loader est **inerte sans données** (`getTokens()===null` → sort). Donc push sûr :
1. `index.html` inclut : `<script src="sunmates-da-loader.js?v=5"></script>` + le `<link>` lite.
2. **Aucun token DA publié en prod** pour l'instant → public identique à aujourd'hui.
3. Prévisualisation : console overlay **admin-only** (`?daforce=1` en test) ; version lissée via `?lite=1`.
4. Défaut public le temps du test : **beta ON pour tous** ; lite seulement sur `?lite=1`.
   Quand validé : 1 ligne pour passer le défaut public à lissée.
(Détails complets : `DA_PREVIEW.md`.)

## 4) Défaut par cohorte (quand on bascule en prod)
- Beta-testeurs : `profiles.beta = true` → beta ON.
- Grand public : OFF → lissée. Boot :
  `setBeta(force?false:(myProfile&&myProfile.beta!=null?myProfile.beta:true));` (true tant qu'on teste).

## 5) Fichiers à pousser (preview)
1. `index.html` (ajout des 2 lignes DA + toggle Réglages + setBeta/sm-lite)
2. `sunmates-da-loader.js`  3. `sunmates-lite.css`  4. `da-console.html`
5. `sunmates-icons-v2.js`   6. `sunmates-da-history.sql` (Supabase, non bloquant)
+ **bumper `VER` dans `sw.js`**.

## 6) Anti-troncature (checker AVANT commit)
- `index.html` finit par `getSession().then(...)` → `</script>` → lignes DA → `</body></html>`.
- `da-console.html` finit par `</body></html>`.
- `node --check` sur le **dernier** `<script>` de chaque fichier (pas un bloc antérieur).

## 7) Epin / carte
Ton choix de le laisser **dormant** (repli sans `--epin`) et de **ne pas aplatir** les couleurs
sémantiques de la carte = correct. Il s'activera seul quand la DA sera publiée. Rien à faire maintenant.

---
## Addendum — réponses à ton retour v500 ✅
Top, RAS sur tes choix. Trois précisions :

**SMSound (ta question) — oui, ambiance OFF en lissée, MAIS sans casser l'existant.**
Le toggle « Sons » de Réglages reste **maître**. Ne gate PAS tous les appels SMSound :
entoure seulement le **démarrage auto de l'ambiance** d'une condition, p.ex.
`if (betaOn() || sonsActivésParUser) { SMSound.startAmbient(); }`.
→ en lissée, pas d'ambiance par défaut ; si l'user l'active explicitement, on respecte. Zéro régression.

**Caveat localStorage `sm_da_live`** — noté, parfait. Si la DA réapparaît en preview chez moi :
console navigateur → `localStorage.removeItem('sm_da_live'); location.reload();`. Prod non concernée. 👍

**Bien vu de NE PAS faire** sw.js VER / migrations / défaut cohorte tant qu'on n'est pas en prod.
On les fera ensemble au moment du go « pour tout le monde ».

**Reload pour ré-armer les easter eggs** quand on rallume le beta : OK, comportement acceptable.

## Nouveau côté design (issu de la session Stitch « Radiant Horizon »)
Voir `SunMates-DA-Stitch-Kit.md` : palette exacte **Primary #FF3A2D · Secondary #FFD15C ·
Tertiary #9B7BFF · Neutral #190E2E**, titres serif + Manrope, et composants premium
(tuiles Accès Rapide dégradé/sombre, segmented En voyage/À la maison, carte map, feed
« Autour de vous », Circle of Trust, Faux appel, Numéros d'urgence, mode Nuit « Crépuscule »).
Cible visuelle : `sunmates-lite-preview.html` (mode Jour/Nuit + Lissée/Complète, interactif).
