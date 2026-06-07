# Audit SunMates — coquilles, cohérence & axes d'amélioration

> Revue du `index.html` (≈ 5 821 lignes) + fichiers SQL, état actuel.
> Classé par priorité : 🔴 à corriger · 🟠 cohérence/finition · 🟢 idées (technique & UX).

---

## 🔴 1. Coquilles & bugs concrets (trouvés dans le code)

1. **Code mort qui planterait — `renderRecos()`** (≈ ligne 3498).
   La fonction fait `sec.style.display = …` sur `#recoSection`, mais cette section
   a été retirée du HTML (refonte « Pour toi »). Elle n'est plus appelée nulle part
   → pas de crash aujourd'hui, mais si on la rappelle, erreur `null`. À supprimer
   (avec `#recoList`) ou à re-brancher proprement.

2. **CSS en double / mort.**
   - `@keyframes fadeUp` est défini mais **jamais utilisé** (les onglets utilisent `tabFade`).
   - Le bloc `.search { … }` est défini **2 fois**, `.search-clear { … }` **3 fois** : règles qui se chevauchent, à fusionner.
   - Deux règles `.tab-panel:not(.hidden)` identiques (animation `tabFade`).

3. **Références d'ID robustes (RAS) :** `homeCafes` et `map` sont appelés en JS mais
   bien protégés par `if (!el) return;` — c'est propre, je le note pour rassurer.

*Aucun `console.log` oublié, aucun `TODO/FIXME`, aucun ID HTML en double : bon point.*

---

## 🟠 2. Cohérence visuelle & finition (le « pas net »)

4. **Palette chaude éclatée — priorité finition.**
   On compte **~55 nuances orange/corail très proches** (`#ff6a5d`, `#ff6a6a`,
   `#ff6a78`, `#ff6b6b`, `#ff7e5f`, `#ff7e72`, `#ff9b7c`, `#ff9f6b`…). Résultat :
   des dégradés et accents qui « jurent » légèrement d'un écran à l'autre.
   → **Consolider en 6–8 jetons** (`--accent`, `--accent-2`, `--accent-3`,
   `--gold`, `--violet`, `--teal`) et remplacer les valeurs en dur par ces variables.
   C'est le changement qui rendra l'app visuellement « propre » d'un coup.

5. **326 styles `inline` + 86 `!important`.**
   Beaucoup d'`!important` viennent du thème sombre (`theme-dusk`) qui ré-écrit les
   couleurs. C'est jouable, mais ça rend les retouches fragiles. → migrer le thème
   sombre vers des **variables CSS** (déjà commencé avec `:root` / `body.theme-dusk`)
   pour supprimer la majorité des `!important`.

6. **Échelle de `z-index` anarchique** : valeurs de 1 à 6000 sans logique d'ensemble
   (pwa 400, alerte 1000, carte plein écran 3500, onboarding 4000, tour 4200,
   overlay 4300, démo 5000, confettis 6000). → définir une **échelle nommée**
   (`--z-nav: 60; --z-overlay: 4000; --z-toast: 6000`…) pour éviter qu'un futur
   modal passe sous un autre.

7. **Barre de navigation à 6 onglets** (Accueil, Lieux, Jeux, Mates, Sécurité, Profil)
   avec libellés à `.62rem` : ça devient serré sur petit écran (« Sécurité » est long).
   → soit **5 onglets** (fusionner Lieux dans l'accueil/carte, ou Sécurité en bouton
   flottant), soit icônes seules + libellé de l'onglet actif uniquement.

---

## 🟢 3. Idées UI / UX

8. **Hiérarchie typographique** : tu as chargé Fraunces (titres) + Manrope (UI) — très
   bon choix éditorial. Vérifier qu'ils sont appliqués partout (certains titres restent
   en Poppins) pour une vraie signature visuelle cohérente.
9. **Onboarding → action** : à la fin de l'onboarding, déposer l'utilisateur sur un
   **profil pré-rempli à 40 %** avec une checklist « complète ton profil (+points) ».
10. **Vide = opportunité** : tes états vides `.empty` sont déjà soignés ; y ajouter
    systématiquement un bouton d'action (« Trouve ton 1er Mate », « Ajoute une photo »).
11. **Feedback de compatibilité** : sur la fiche, expliquer le score (« +25 % car même
    ville, +20 % 3 intérêts communs ») — la transparence rassure et gamifie.
12. **Cohérence des emojis** : tu utilises beaucoup d'emojis comme icônes ; envisager un
    set d'icônes vectorielles (cohérence multi-plateformes, l'emoji varie selon l'OS).
13. **Accessibilité** : `:focus-visible` est en place 👍. Vérifier les **contrastes**
    du texte clair sur dégradé corail (le blanc sur `#ffb274` peut passer sous le ratio
    AA) et ajouter des `aria-label` sur les boutons-icônes.
14. **Micro-confort** : sur le chat, accusés de lecture / « en train d'écrire », et
    regroupement des messages par jour.

---

## 🟢 4. Technique & architecture

15. **Monolithe de 5 821 lignes** (164 fonctions, 173 listeners dans un seul fichier).
    La contrainte projet impose un seul `index.html` *déployable* — mais tu peux garder
    cette contrainte tout en **séparant en plusieurs `<script>`/`<style>` thématiques**
    ou en extrayant `app.js` / `styles.css` (GitHub Pages sert très bien des fichiers
    séparés). Gain : lisibilité, moins de risques de régression.
16. **Délégation d'événements** : 173 `addEventListener` souvent re-attachés après chaque
    `innerHTML`. Passer à la **délégation** (un listener sur le conteneur + `data-*`)
    réduit le code et les fuites mémoire.
17. **Couche d'accès données** : centraliser les appels Supabase dans un petit module
    (`db.profiles.list()`, `db.messages.send()`) plutôt que des `db.from(...)` éparpillés
    → plus facile à faire évoluer et à corriger.
18. **Robustesse réseau** : afficher un état « hors-ligne / erreur » global quand Supabase
    ne répond pas (aujourd'hui surtout des messages locaux).

---

## 🟢 5. Sécurité & données

19. **Comptes démo dans `auth.users`** : pratiques pour la démo, mais ils existent comme
    vrais utilisateurs sans mot de passe. Pour une vraie mise en prod, prévoir un
    nettoyage (`delete … like '%@demo.sunmates'`) ou un flag clair `is_demo` (déjà ajouté 👍).
20. **RLS** : revérifier que les nouvelles colonnes sensibles (téléphone déjà isolé dans
    `profiles_private` 👍) ne fuitent pas via un `select *`. Le téléphone est bien séparé.
21. **Vérification simulée** : le badge « vérifié » donne +points sans contrôle réel.
    OK pour un MVP, mais à signaler comme « simulé » côté produit pour ne pas créer une
    fausse impression de sécurité (cœur de promesse de SunMates).

---

## Limite de cet audit & suite proposée

Cet audit est **basé sur le code**. Les défauts au pixel près que tu mentionnes
(« un encart décalé d'1 mm, un point mal placé, une couleur pas belle ») se voient
surtout **sur le rendu réel**. Deux options pour aller plus loin :

- Je peux **ouvrir le site en ligne dans un navigateur** et faire une revue visuelle
  écran par écran (limité aux écrans visibles sans login, ou avec un compte de test).
- Ou tu m'envoies **des captures** des écrans qui te chiffonnent, et je pointe
  précisément les corrections.

### Quick wins que je peux corriger tout de suite
- Supprimer le code mort (`renderRecos`, `@keyframes fadeUp`, blocs `.search` dupliqués).
- Consolider la palette chaude en jetons (gros gain visuel, faible risque).
- Mettre en place une échelle de `z-index` nommée.
