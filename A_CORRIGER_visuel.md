# SunMates — petites corrections visuelles (repérées en revue live)

Mini-retouches (2-3 lignes chacune), à faire à l'occasion.

1. **Icône du bouton de thème en mode CLAIR = 🍌 banane** au lieu d'une lune 🌙.
   - En thème sombre l'icône est bien un soleil (pour repasser en clair).
   - En thème clair, remplacer l'emoji 🍌 par 🌙 (bouton à gauche de la cloche, en haut à droite).
   - Chercher dans `index.html` l'emoji banane / la logique du toggle de thème.

2. **Incohérence de libellé : « Accès rapide » vs « Accès rapides ».**
   - Accueil : « Accès rapide » (singulier).
   - Sécurité : « Accès rapides » (pluriel).
   - Uniformiser (choisir l'un des deux, ex. « Accès rapide » partout).

3. **(Optionnel — goût) Fond du thème clair multicolore.**
   - Le fond clair est un dégradé pêche → rose → bleu/menthe ; le coin froid (bleu/vert)
     s'éloigne de l'ADN « coucher de soleil » chaud.
   - Si tu veux rester raccord : dégradé chaud uniquement (ambre → corail → rose).
   - Chercher la variable `--bg-grad` (ou le `background` du `body`) dans `index.html`.

> Aucune autre coquille / désalignement repéré en revue live (thème clair + sombre,
> tous les onglets, fiche profil, matchmaking). Aucune erreur console.
