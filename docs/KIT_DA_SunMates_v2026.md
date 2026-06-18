# Kit de Direction Artistique SunMates — Signature "Radiant Horizon"

Ce document centralise l'intégralité des spécifications visuelles et techniques pour l'intégration de SunMates. Il remplace les versions précédentes pour une cohérence totale sur les 6 modes atmosphériques.

## 1. Identité de Marque
- **Nom :** SunMates
- **Baseline :** « Seul·e au départ, jamais à l'arrivée. »
- **Logo :** Solaire, dessiné main (variantes saisonnières : ☀️ Jour, 🌙 Nuit, ❄️ Cristal, 🌴 Palmier).
- **Vibe :** Warm, Reassuring, Playful, Premium.

## 2. Design Tokens (CSS Variables)

### Fondamentaux Transverses
```css
:root {
  /* Formes */
  --radius: 22px;
  --radius-sm: 14px;
  --radius-lg: 28px;
  --squircle: 28%; /* Courbure pour les masques */

  /* Ombres (Dérégies - Doctrine v2.2) */
  --shadow: 0 16px 38px rgba(45,38,52,.10), 0 3px 10px rgba(40,25,35,.05);
  --shadow-sm: 0 8px 18px rgba(45,38,52,.08);
  --shadow-pop: 0 22px 50px rgba(40,34,46,.22);
  
  /* Focus & Polish */
  --ring: 0 0 0 4px rgba(255,90,77,.16);
  --relief: drop-shadow(0 8px 14px rgba(45,38,52,.34)) drop-shadow(0 2px 3px rgba(0,0,0,.18));
}
```

### Palettes par Mode (Variables d'Ambiance)

| Mode | --bg | --card | --ink | --accent | --accent-grad (CTA) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **JOUR** | #FFF4E6 | #FFFFFF | #39203A | #FF5A4D | linear-gradient(135deg, #FFC93C 0%, #FF7A3D 20%, #FF4F6D 52%) |
| **NUIT** | #190E2E | #271641 | #FCEFE9 | #FF6A5D | linear-gradient(135deg, #FFD15C 0%, #FF8A45 20%, #FF5570 52%) |
| **HIVER** | #EAF3FB | #FFFFFF | #1E3A52 | #3A8FD9 | linear-gradient(135deg, #A8D8F5 0%, #6FB4E8 20%, #3A8FD9 52%) |
| **HIVER-NUIT** | #0F1B2B | #1A2B40 | #EAF3FB | #5FA8E8 | linear-gradient(135deg, #BFD9F0 0%, #8CC4F2 20%, #3A77B8 52%) |
| **TROPIQUES** | #F7F9EC | #FFFFFF | #1C3D2E | #0FA37C | linear-gradient(135deg, #FFC23D 0%, #36C495 22%, #0FA37C 52%) |
| **TROP-NUIT** | #0C1D17 | #163027 | #E9F7EF | #2BC48A | linear-gradient(135deg, #FFC23D 0%, #5CD8A8 22%, #1FA67A 52%) |

## 3. Typographie (Pairing Signature)
- **Titres (Display) :** **Fraunces** (Serif chaleureux). 700 à 900.
- **Interface (Corps) :** **Manrope** (Sans-serif). 400 (regular) à 800 (extra-bold).
- **Chiffres :** Toujours en `font-variant-numeric: tabular-nums` pour l'XP et les timers.

## 4. Composants "Joyaux" (Sticker-Style)
Les tuiles d'accès rapide et de sécurité suivent la logique **Emaillée** :
- **Rendu :** Dégradé 135° + Reflet haut (gloss) + Relief drop-shadow.
- **Couleurs :** Chaque catégorie possède son code couleur (ex: `quest` #FF7A4D, `games` #8A5CFF).
- **Emblèmes :** Banque de 289 icônes line-art dessinées main avec liseré clair.

## 5. Gamification (Badges & XP)
- **Exploration :** Corail (#FF8A3D → #FF5A4D)
- **Social :** Violet (#9B7BFF → #6638D6)
- **Sécurité :** Vert bijou (#34C98F → #0E9E6B)
- **Accomplissement :** Or (#FFD15C → #E0901E)

## 6. Micro-interactions Premium
- **Pull-to-refresh :** Roulette personnalisée "Soleil".
- **Match :** Pluie de confettis vectoriels (soleils, cœurs, étoiles).
- **Feedback :** Flash de succès (halo chaud) sur les éléments validés.
- **Sons :** Synthétisés en WebAudio (libre de droit, timbres marimba/cloche).

---
*Ce kit est conçu pour être la source unique de vérité. Toute modification technique doit impérativement respecter ces tokens.*
