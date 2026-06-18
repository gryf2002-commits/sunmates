# Product

## Register

product

## Users

**Persona principal : « Chloé, l'exploratrice solo »** — voyageuse solo de 24 ans (Gen Z / jeunes Millennials).
Contexte d'usage : **sur téléphone, en voyage**, souvent dans un lieu inconnu, parfois seule le soir.
Elle alterne entre deux états d'esprit : l'**excitation de la découverte** (rencontrer, explorer, jouer)
et le **besoin de réassurance** (suis-je en sécurité ? puis-je faire confiance à cette personne / ce lieu ?).

Le job à accomplir : transformer une rencontre de voyage éphémère en **connexion sûre et validée**,
sans jamais transformer l'app en outil de surveillance anxiogène. Les utilisateurs actuels sont des
**bêta-testeurs** (tout est débloqué pour eux ; rien ne leur sera jamais facturé — règle produit actée).

## Product Purpose

SunMates est une app sociale **« sécurité d'abord »** pour voyageurs solo : score de confiance et
vérification, partage de position au cercle de confiance, check-ins gamifiés dans des lieux sûrs
partenaires, carte des lieux validés, mise en relation non ambiguë. Depuis juin 2026, c'est aussi un
**hub de jeu géolocalisé** (quêtes, missions XP, badges exclusifs, solo ou en groupe).

Succès = l'utilisatrice se sent **en sécurité ET sourit**. La sécurité est gratuite pour tous, toujours
(jamais monnayée). Le trust score ne se farme pas : il ne monte que via des signaux non triviaux
(vérification, check-ins validés par code, vouches) ; les quêtes rapportent de l'XP, monnaie séparée.

## Brand Personality

**Chaleureux · joueur · rassurant.**
Le ton est « vacances » : la chaleur d'une rencontre au coucher du soleil + la confiance d'un lieu sûr.
Jamais froid, jamais clinique, **jamais anxiogène** : la sécurité se dit avec des mots qui rassurent,
pas des mots qui font peur. L'app doit donner le sourire (logo soleil/lune, confettis-soleils,
easter eggs, clins d'œil partout). Niveau d'exigence visuelle : **« œuvre / badge d'arène »** — émaillé,
biseauté, pensé au pixel (identité « joaillerie », niveau Pokémon).

## Anti-references

- **L'UI « générée par IA » générique** : composants Tailwind par défaut, dégradés violets de SaaS,
  glassmorphism passe-partout. Si ça pourrait être n'importe quelle app, c'est raté.
- **Les banques d'icônes gratuites** (Lucide, Material Icons, Heroicons…) : rejetées en bloc
  (« on perd l'âme »). Tout pictogramme est une création maison.
- **Le vert criard SaaS** pour les états « validé / en ligne » : chez SunMates, la validation parle
  sunset (teal/ambre de la DA), pas Excel.
- **L'ivoire / crème en masse** : banni (« hors DA »). Le blanc pur n'existe qu'en reflet.
- **Le dark mode froid corporate** (gris bleutés) : la nuit SunMates est une prune chaude et violette.
- **Le langage sécurité anxiogène** (alarmes rouges, vocabulaire de danger) hors situation d'urgence réelle.

## Design Principles

1. **Aucun pixel générique.** Chaque visuel est une création maison reconnaissable au premier coup d'œil.
2. **Rassurer, jamais alarmer.** La sécurité s'exprime par la chaleur et la confiance, le rouge est
   réservé au danger réel.
3. **Niveau joaillerie, avec LOD.** Matières (or, émail, verre, galaxie) et lumière cohérente en grand ;
   version `lite` nette en petit. Le craft ne devient jamais de la bouillie.
4. **Lisible dans les 6 mondes.** Tout composant doit tenir dans les 6 modes (day, dusk, winter,
   winter-dusk, tropic, tropic-dusk) — thémé ET lisible, jamais l'un sans l'autre.
5. **Le délice ne se paie jamais en accessibilité.** Animations coupées par `prefers-reduced-motion`,
   contrastes audités jour + nuit, repli emoji systématique.

## Accessibility & Inclusion

- Objectif **WCAG AA** sur les contrastes, en restant dans la palette (vérifié jour + nuit).
- **`prefers-reduced-motion` respecté partout** (toutes les animations se coupent).
- **Cibles tactiles généreuses** : tuiles ≥ 60 px, boutons ≥ 44 px.
- **Repli emoji systématique** si un moteur SVG ne charge pas — jamais de carré vide.
- Public mobile d'abord (PWA installée), réseau parfois faible en voyage : offline réel via Service Worker.
- Genre des textes géré via le helper `_gw` (français inclusif sans alourdir).
