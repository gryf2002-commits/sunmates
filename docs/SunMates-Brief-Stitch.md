# SunMates — brief produit & design complet (pour Stitch)

## 1. Concept & mission
SunMates est une application mobile sociale « sécurité d'abord » qui transforme les rencontres de
voyage éphémères en connexions sûres et validées. Ce n'est PAS une app de dating : c'est une app
d'appartenance et d'exploration pour voyageurs qui partent seul·e·s mais ne veulent pas le rester.
Baseline : « Seul·e au départ, jamais à l'arrivée. »

## 2. Public & persona
- Gen Z et Millennials, voyageurs solo, backpackers, nomades, étudiant·e·s en échange, digital nomads.
- Persona principale : « Chloé, l'exploratrice solo » — curieuse, sociable, prudente. Elle veut
  rencontrer des gens et découvrir une ville inconnue sans jamais sacrifier sa sécurité.
- Sensibilité : éco-responsabilité, authenticité, communauté, anti-superficialité.

## 3. Positionnement & promesse
- La sécurité est un droit, jamais un produit : toutes les fonctionnalités de sécurité sont GRATUITES.
- Confiance vérifiable plutôt que likes : on récompense les comportements sains, pas la popularité.
- Lieux réels, éco-responsables et validés plutôt que swipes anonymes.

## 4. Fonctionnalités cœur (MVP + extensions déjà pensées)
- Score de confiance & vérification : badge « profil vérifié », anti-faux-profils. Le trust ne monte
  QUE via des signaux non triviaux (vérification d'identité simulée, check-ins validés par code/RPC,
  recommandations entre membres « vouches »). Jamais par farming.
- Partage de position au cercle de confiance + bouton d'alerte d'urgence (SOS) très visible et pulsant.
- Check-ins gamifiés dans des lieux partenaires éco-responsables (cafés, co-livings) → rapportent de
  l'XP (monnaie de jeu), pas de trust (anti-triche).
- Carte & liste des lieux sûrs validés (cafés cosy, co-livings, espaces culture, nature, points d'eau…).
- Connexions sûres : mise en relation explicite et non ambiguë entre voyageurs (intention claire :
  boire un café, visiter, randonner — pas de drague déguisée).
- Quêtes & XP : quêtes solo + quêtes de groupe (nécessitent la confirmation d'un « mate » → bonus XP
  partagé, plus social). Auto-déclaration limitée (3/jour + cooldown) pour éviter l'abus.
- Badges façon jeu vidéo : badges verrouillés affichés en grisé/noir, badges « secrets » à condition
  cachée ; un compte admin voit les éléments cachés. Familles : Exploration, Social, Sécurité,
  Accomplissement.
- Classement multi-segments : par badges, par XP, par confiance, par check-ins.
- Fil social léger (posts courts, photos de lieux), messagerie 1:1, demandes de connexion.
- Profils voyageurs : pseudo, bio, ville actuelle, statut « dispo ☕ », dates de voyage, stats,
  badges, niveau, vérification, nombre de « mates ».
- Signalement & blocage : un seul signalement par compte (antispam) ; la personne signalée est
  auto-bloquée pour l'auteur jusqu'au traitement par la modération ; statut visible.
- Mode B2B « SunMates Pro » : espace pour les lieux partenaires (insigne doré « Pro », mise en avant).
- Récompenses : catalogue de récompenses/quêtes avec XP, état (débloqué/verrouillé/secret), icône.
- Multilingue FR/EN (dictionnaire complet, bascule de langue).
- PWA installable, notifications push, mode hors-ligne, carte interactive (Leaflet).

## 5. Économie & règles produit (à respecter dans l'UI)
- Sécurité jamais monnayée. XP = monnaie de jeu ludique ; Trust = capital sérieux séparé.
- Quêtes → XP uniquement ; jamais de trust (sinon farmable).
- Rappel par fonctionnalité : chaque feature indique discrètement ce qu'elle débloque.
- Indications visibles (toasts en haut / inline près de l'action) plutôt que messages collés en bas.

## 6. Direction artistique — « coucher de soleil »
- Identité chromatique signature : corail / ambre / doré (tons « sunset »). Chaleur, optimisme, soin.
- Statuts & validations (« en ligne », « validé », notes info) toujours en tons sunset raccord —
  JAMAIS de vert criard hors DA.
- Tuiles « joyau » : pastilles à dégradé doux + léger gloss/reflet, sur lesquelles repose un emblème.
  Principe clé : un seul joyau (couleur de tuile) par mode, et c'est l'EMBLÈME qui porte la couleur.
- Emblèmes dessinés main, style line-art / sticker (rempli + liseré clair), cohérents entre eux ;
  banque maison de ~289 emblèmes remplaçant les emojis natifs partout dans l'app.
- Badges : médaillons « joaillerie » dessinés main, une DA par famille (jamais doré par hasard).
- Logos maison déclinés par mode (soleil, lune, cristal d'hiver, palmier-lagon…).

## 7. Les 6 ambiances (modes) à décliner
- Jour (clair chaud), Nuit (sombre prune/violet), Hiver (bleu glacier), Hiver-nuit (bleu nuit polaire),
  Tropiques (vert lagon), Tropiques-nuit (jungle nocturne). Chaque écran doit exister en clair ET sombre.

## 8. Typographie & composants
- Titres : serif chaleureux et expressif (Fraunces). Interface : sans-serif moderne et lisible (Manrope).
- Composants : boutons pleins (CTA accent), boutons fantômes, chips/filtres (état actif accentué),
  pastille « en ligne », barres de progression, cartes de lieux à en-tête dégradé, cartes profil,
  cartes quête, médaillons de badges, tuiles d'accès rapide, segments de navigation, barre du bas,
  topbar avec logo + cloche notifications + bascule de thème, modales, toasts, états vides illustrés.
- Coins arrondis (squircle), ombres douces, micro-célébrations (confettis, pluie de saison),
  reflets « polish » subtils. Option effet miroir/sans-ombre selon la DA.

## 9. États & accessibilité
- Contraste AA visé partout (texte, accents, sur fond clair ET sombre).
- États : online/validé (sunset), alerte/SOS (rouge réservé au danger — sémantique), verrouillé (grisé),
  secret (mystère). Le rouge n'est utilisé QUE pour danger/urgence/blocage.
- Tailles de tuiles et d'emblèmes ajustables ; barre de défilement thémée (pas blanche).

## 10. Écrans à générer (mobile-first)
Onboarding (3-4 slides) · Connexion/Inscription · Accueil (salutation, accès rapides en tuiles-joyaux,
« explore autour de toi », carte) · Carte des lieux sûrs · Liste/recherche de lieux + filtres ·
Fiche lieu (en-tête dégradé, photo, check-in, infos sécurité) · Découverte de mates (cartes profil,
dispo, dates) · Profil voyageur (badges, stats, vérif, niveau) · Profil public d'un mate · Messagerie
(liste + conversation) · Quêtes/Jeux (quêtes solo & groupe, progression) · Classement multi-segments ·
Badges (galerie, verrouillés/secrets) · Récompenses · Panneau Sécurité/Urgence (SOS, cercle de confiance,
aide rapide : police/hôpital/contact) · Notifications · Paramètres (langue, thème, confidentialité) ·
Espace Pro (lieu partenaire). Prévoir chaque écran en clair et en sombre.

## 11. Ton & ressenti
Chaleureux, rassurant, inclusif, ludique mais premium. L'utilisateur doit ressentir immédiatement
confiance, chaleur et appartenance. Esthétique « golden hour » : lumineuse, douce, vivante.

## 12. Contexte technique (pour cohérence, pas pour l'UI)
App web mono-fichier (HTML/CSS/JS vanilla), backend Supabase (Auth + Postgres + RLS), hébergement
statique, PWA. Un système de « Design Aesthetic » pilotable (presets de DA) permet de changer
couleurs/polices/formes/icônes en quasi temps réel — donc l'UI doit être pensée en tokens
(couleurs, rayons, ombres, typo) facilement déclinables.
