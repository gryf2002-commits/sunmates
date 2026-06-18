# SunMates — banque visuelle (design tokens à copier dans Stitch)

Valeurs réelles de l'app. DA « coucher de soleil » : chaleureuse, premium, dessinée main.
Le rouge est réservé au danger/urgence. Tout existe en clair ET sombre (6 ambiances).

## Marque
- Nom : SunMates · Baseline : « Seul·e au départ, jamais à l'arrivée. »
- Logo : soleil dessiné main (variantes par saison : soleil, lune, cristal d'hiver, palmier-lagon).
- Mots-clés visuels : golden hour, tuiles-joyaux, emblèmes line-art/sticker, gloss doux, squircle.

## Typographie
- Titres / display : **Fraunces** (serif chaleureux, 700–900, italique 500 possible).
- Interface / corps : **Manrope** (sans-serif, 400–800).
- Échelle indicative : H1 28 · H2 22 · H3 18 · corps 15–16 · meta 12–13 · micro 11.
- Chiffres tabulaires pour XP / compteurs / streak / prix / niveaux.

## Rayons / ombres / divers
- Rayons : `--radius 22px` · `--radius-sm 14px` · `--radius-lg 28px` · tuiles squircle ~28%.
- Ombres : douce `0 14px 40px rgba(45,38,52,.10)` · petite `0 6px 18px rgba(20,20,40,.06)` ·
  pop `0 18px 50px rgba(40,34,46,.20)`.
- Focus ring : `0 0 0 4px rgba(255,90,77,.16)`. Gloss tuile : reflet blanc translucide en haut.

## Palette — 6 ambiances (mode : fond / carte / encre / texte / secondaire / ligne / accent / accent-2 / accent-3 / accent-soft)
- **JOUR** : `#fbeee9` / `#ffffff` / `#1d2230` / `#454b59` / `#9aa0ac` / `#f0e6e4` /
  `#FF5A4D` / `#FF8A3D` / `#FFC93C` / `#fdeceb`. (ok `#1E7A5A`, danger `#ef4444`)
- **NUIT** : `#171026` / `#221a33` / `#f3ecf6` / `#ded3e6` / `#a99fbe` / `rgba(255,255,255,.10)` /
  `#ff7e72` / `#ff9a8d` / `#ffc07a` / `rgba(255,126,114,.16)`. (cream `#2b2240`)
- **HIVER** : `#EAF3FB` / `#FFFFFF` / `#1E3A52` / `#2C4862` / `#4F6B84` / `#DDE9F3` /
  `#3A8FD9` / `#6FB4E8` / `#A8D8F5` / `#E3F1FB`. (cream `#F2F8FD`)
- **HIVER-NUIT** : `#0E2036` / `#16263E` / `#EAF6FF` / `#CFE0F0` / `#9DB6CE` / `rgba(255,255,255,.10)` /
  `#5FA8E8` / `#3E84C4` / `#A8D8F5` / `rgba(95,168,232,.16)`.
- **TROPIQUES** : `#F7F9EC` / `#FFFFFF` / `#1C3D2E` / `#2A4A3A` / `#53705F` / `#E2EDD9` /
  `#0FA37C` / `#36C495` / `#FFC23D` / `#E2F4EC`. (cream `#F8FBEE`)
- **TROPIQUES-NUIT** : `#06231B` / `#0E3326` / `#DFFAEF` / `#BFE9D6` / `#8FC2AC` / `rgba(255,255,255,.10)` /
  `#16C896` / `#0E8E68` / `#FFC23D` / `rgba(22,200,150,.16)`.

## Dégradés signatures
- Accent / CTA (jour) : `linear-gradient(135deg,#FFC93C 0%,#FF8A3D 45%,#FF5A4D 100%)`.
- Fond de page (golden hour) : `radial-gradient(125% 85% at 50% -12%,#ffe6d2,#fdeee7,#fbe9e4)`.
- Tuile-joyau = dégradé doux à 160deg de 2 teintes (j1→j2) + léger gloss ; une seule teinte par mode.

## Tuiles-joyaux par catégorie (couples j1 / j2 d'emblèmes, ambiance jour)
quest `#FF7A4D/#FF5238` · games `#8a5cff/#6638d6` · medal `#E8A33A/#D07F10` · coupon `#FF6FA5/#E84D86` ·
rank `#5E74E8/#3641B8` · shop `#FF5A8A/#C43A8A` · coffee `#E89A4E/#C26A1E` · eco `#34C98F/#0E9E6B` ·
near `#FF9A3D/#FF6A1F` · rating `#FFB23D/#E07E12` · popular `#FF5A4D/#E83247` · trip `#FF8A4D/#FF5A4D` ·
users `#9b7bff/#6a4fe0` · usersolo `#FF9A5C/#E8631F` · crown `#8a5cff/#5028b0` · phone `#2BC48A/#15897A` ·
signal `#FFC04E/#E8901F` · alert `#FF4D4D/#D81E2A` · aid `#FF7A4D/#FF9A3D` · chat `#7a8cff/#5560f0` ·
shieldsafe `#1FB38C/#0C7E6E`.
(Note DA : dans l'app les tuiles peuvent passer en « un seul joyau par mode » + emblème crème dessus.)

## Emblèmes (iconographie)
- Style : **line-art / sticker dessiné main** (forme pleine + liseré clair), coins doux, cohérents.
- Banque de ~289 emblèmes maison (remplacent les emojis) : near/pin, quest/target, games/gamepad,
  medal, crown, rank/trophy, coupon/ticket, shop/bag, coffee, eco/leaf, rating/star, popular/fire,
  trip/luggage, users/people, usersolo, phone, signal, alert/siren, aid/firstaid, chat, shield, bell,
  search, mail, clock, calendar, gift, compass, map, camera, music, settings, heart, sun, moon,
  snowflake, palm, globe, rocket, bolt, lock, check, plane… + mascottes (lion, phacochère, suricate).

## Badges (médaillons « joaillerie », 4 familles → dégradés)
- Exploration `#FF8A3D → #FF5A4D` (corail) · Social `#9B7BFF → #6638D6` (violet) ·
  Sécurité `#34C98F → #0E9E6B` (vert bijou) · Accomplissement `#FFD15C → #E0901E` (or).
- États : débloqué (coloré + gloss) · verrouillé (grisé/noir) · secret (« ??? », visible admin).

## Cadres d'avatar (boutique cosmétique XP)
Sunset · Corail · Émeraude · Or · Royal · **Aurore (halo animé qui pulse)**.

## Composants (specs)
- Bouton plein : fond `--accent-grad`, texte clair, radius 12–14, padding 10×16, ombre douce.
- Bouton fantôme : bord 1px `--line`/encre, fond transparent, texte `--ink`.
- Chip : pilule, bord `--line` ; chip active : fond accent, texte clair.
- Pastille « en ligne » : point ton sunset (jamais vert criard).
- Carte lieu : en-tête dégradé (60–84px) + emblème, corps `--card`, ombre douce, tags pilules.
- Carte profil : avatar (option cadre), pseudo + badge vérifié, ville, dates, chips d'intention.
- Tuile d'accès rapide : carré squircle joyau + emblème crème + libellé dessous.
- Barre du bas : 5 onglets (Accueil · Lieux · Mates · Jeux · Profil), actif accentué.
- Topbar : logo + cloche notifications + bascule thème.
- Toast (haut), modale, états vides illustrés, barre de progression, médaillon de badge.

## États & feedback
- Validé / en ligne : tons sunset. Danger / SOS / blocage : rouge (`#ef4444` / `#FF4D4D`).
- Verrouillé : grisé. Secret : mystère. Skeletons : shimmer. Célébration : confettis + son.

## Effets d'ambiance
- Halos dorés, reflets « polish », pluie de saison (pétales/feuilles/flocons), bonnets de Noël en
  décembre sur les pins, mode rétro 8-bit (scanlines/CRT) en easter egg, cadres animés (aurora).
