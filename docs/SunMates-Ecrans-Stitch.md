# SunMates — prompts Stitch écran par écran

> Style commun à rappeler dans CHAQUE prompt : app mobile « sécurité d'abord » pour voyageurs solo.
> DA « coucher de soleil » (corail/ambre/doré), tuiles-joyaux à dégradé doux + léger gloss portant des
> emblèmes line-art/sticker dessinés main, titres serif (Fraunces) + interface sans-serif (Manrope),
> coins squircle, ombres douces, AA contrast. Rouge réservé au danger/urgence. Générer en clair ET sombre.
> Mobile-first, barre de navigation basse persistante (Accueil · Lieux · Mates · Jeux · Profil).

---

## 1. Onboarding
But : présenter la promesse « Seul·e au départ, jamais à l'arrivée » et la sécurité d'abord.
Layout : 3-4 slides plein écran, illustration golden-hour en haut, titre serif, sous-texte, pagination
en points ambrés, CTA « Commencer », lien « J'ai déjà un compte ».
Slides : (1) Rencontre des voyageurs vérifiés. (2) Partage ta position à ton cercle de confiance.
(3) Check-in dans des lieux sûrs & éco. (4) Gagne XP, badges et grimpe au classement.
États : skip en haut à droite ; dernier slide → bouton plein.

## 2. Connexion / Inscription
But : auth e-mail (Supabase). Layout : logo soleil animé, titre « Pars solo, trouve ta bande »,
champs e-mail + mot de passe, bouton plein « Se connecter », bascule connexion/inscription, mot de
passe oublié, sélecteur de langue FR/EN. États : erreurs inline, chargement sur le bouton.

## 3. Accueil (Home)
But : point de départ quotidien. Layout : topbar (logo + cloche notifications + bascule thème) ;
salutation « Bonjour {prénom} » (serif) ; chip statut « Dispo ☕ » togglable ; rangée d'accès rapides
en tuiles-joyaux (Mates, Sécurité, Position, Jeux, Classement, Coupons, Profil) ; bloc « Explore autour
de toi » avec mini-carte ; bandeau quête du jour / streak (🔥 N jours) ; aperçu derniers mates / fil.
Fonctions : check-in rapide, accès SOS, suggestions de lieux. États : skeleton au chargement, vide illustré.

## 4. Carte des lieux sûrs
But : visualiser lieux validés + mates autour. Layout : carte plein écran (style clair/sombre raccord
DA), marqueurs = pastilles-joyaux à emblème (café, éco, nature, eau, culture, point de rencontre),
filtres en chips horizontales (Lieux · Mates · Activités · Check-ins · Quêtes), bouton recentrer,
bouton SOS flottant. Fonctions : tap marqueur → mini-fiche ; cluster ; ma position. États : permission
localisation, chargement.

## 5. Liste / Recherche de lieux
But : parcourir les lieux sûrs. Layout : barre de recherche, filtres (catégorie, éco, ouvert,
distance), liste de cartes-lieux (en-tête dégradé + emblème catégorie, nom, ville, tags, note,
badge « éco », badge « top noté »). Fonctions : tri, favoris. États : résultats vides illustrés.

## 6. Fiche lieu
But : détail + check-in. Layout : grande photo / en-tête dégradé, nom serif, catégorie, ville, tags,
note, description, infos sécurité, horaires, bouton « Check-in » (rapporte de l'XP), bouton « Y aller »,
mates présents, badge partenaire/éco. États : déjà check-in, fermé, cooldown check-in.

## 7. Découverte de Mates
But : trouver des voyageurs compatibles. Layout : segments (À proximité · Mêmes dates · Vérifiés),
cartes profil (avatar, pseudo, badge vérifié, ville, dates de voyage, statut « dispo », langues,
nombre de mates, chip d'intention : café/visite/rando). Fonctions : « Se connecter » (demande non
ambiguë), filtrer, bloquer/signaler. États : carte « Pro », profil vérifié mis en avant.

## 8. Profil voyageur (le mien)
But : identité + progression. Layout : en-tête (avatar, pseudo, badge vérifié, niveau, ville, bio,
QR de profil) ; rangée de stats (check-ins, quêtes, badges, XP, voyages) ; barre de progression de
niveau ; galerie de badges (débloqués colorés, verrouillés grisés, secrets « ??? ») ; bouton éditer ;
statut dispo ; déconnexion. Fonctions : vérification, partage QR.

## 9. Profil public d'un mate
But : voir un autre voyageur. Layout : identique en lecture seule + boutons « Se connecter »,
« Message », « Signaler » (un seul par compte → ensuite auto-bloqué jusqu'à modération, statut visible).

## 10. Messagerie
But : échanger en sécurité. Layout : liste de conversations (avatar, dernier message, badge non-lu),
écran conversation (bulles, champ d'envoi, indicateur en ligne en ton sunset). Fonctions : demande de
connexion à accepter avant de discuter, blocage. États : message échoué, conversation vide.

## 11. Jeux / Quêtes
But : engagement gamifié (XP, pas de trust). Layout : navigation interne (Quêtes · Défis · Classement ·
Coupons · Badges · Boutique) ; cartes quête (emblème, titre, description, récompense XP, état) ; quêtes
solo et quêtes de groupe (nécessitent la confirmation d'un mate → bonus XP partagé) ; progression.
Règles UI : auto-déclaration limitée (3/jour + cooldown). États : quête accomplie, verrouillée.

## 12. Classement (multi-segments)
But : compétition saine. Layout : onglet dans Jeux/Lieux, sélecteur de segment (Badges · XP · Confiance ·
Check-ins), podium top 3 (médaillons joaillerie), liste rang + avatar + valeur, ma position épinglée.

## 13. Badges
But : collection façon jeu vidéo. Layout : grille de médaillons par famille (Exploration, Social,
Sécurité, Accomplissement) ; débloqués = colorés, verrouillés = grisés/noirs, secrets = condition
cachée (« ??? »), un compte admin voit les conditions. Tap badge → détail + comment l'obtenir.

## 14. Récompenses
But : ce que l'XP débloque. Layout : liste de récompenses (emblème, nom, description, coût/seuil XP,
état débloqué/verrouillé/secret). Rappel : la sécurité reste gratuite, l'XP n'achète que du ludique.

## 15. Sécurité / Urgence
But : pilier sécurité. Layout : gros bouton SOS pulsant (rouge — danger), partage de position au cercle
de confiance (liste de contacts de confiance), aide rapide (Police, Hôpital, Contact d'urgence),
check-list de sécurité, statut « position partagée ». Fonctions : déclencher alerte → bannière diffusée
au cercle. États : alerte active, position en cours d'envoi.

## 16. Notifications
But : suivi. Layout : liste (connexions, messages, quêtes validées, alertes du cercle, badges
débloqués) avec emblèmes et horodatage ; marquer comme lu. États : vide illustré.

## 17. Paramètres
But : contrôle. Layout : sections (Compte, Confidentialité & cercle de confiance, Langue FR/EN,
Thème/ambiance, Notifications, Vérification, À propos, Déconnexion). Toggles thémés DA.

## 18. Espace Pro (lieu partenaire) — B2B
But : gérer un lieu partenaire. Layout : marque « SunMates Pro » (insigne doré), tableau de bord du
lieu (check-ins, visiteurs, mise en avant), édition de la fiche lieu, statut éco.

---
## Composants transverses à générer (design system)
Tuiles-joyaux (6 ambiances), emblèmes line-art, médaillons de badges, boutons plein/fantôme, chips
(filtre/actif), pastille « en ligne », barres de progression, cartes lieu/profil/quête, toasts (haut),
modales, états vides illustrés, barre de navigation basse, topbar, bandeau SOS, sélecteur d'ambiance.
Décliner chaque écran en : Jour, Nuit, Hiver, Hiver-nuit, Tropiques, Tropiques-nuit.

---

# Fonctionnalités cachées & « fancy » (easter eggs, micro-délices, cosmétiques)

> À donner à Stitch pour concevoir les overlays festifs, animations et écrans bonus. Tout est en DA
> sunset, dessiné main, respectant `prefers-reduced-motion`. Chaque easter egg débloque un **badge secret**.

## Easter eggs (déclencheurs → effet → badge)
- **Mot magique « soleil » / « sunshine » / « sunmates »** (barre de recherche accueil) : un soleil
  vectoriel traverse l'écran en arc, rayons qui tournent (badge ☀️ Sunword).
- **« 42 »** (recherche) : clin d'œil H2G2 « la réponse à la grande question » (badge 🛸).
- **« hakuna matata »** (recherche) : trois mascottes maison en SILHOUETTE (lion, phacochère,
  suricate) trottinent en file sur une savane au couchant (acacias, oiseaux, soleil), jingle original
  (badge 🦁 Hakuna).
- **Code Konami** ↑↑↓↓←→←→BA (clavier) ou la même séquence en swipes (mobile) : **mode rétro 8-bit**
  10 min (scanlines, pixels, police machine, boot CRT cathodique) ; le code à l'envers = retour 2026
  (badge 🎮 Konami).
- **5 taps sur la tuile « Maison »** : la tuile s'envole en grappe de **ballons** (revient 1 min après)
  (badge 🎈 Aventure).
- **5 taps sur la tuile « En voyage »** : un **avion en papier** décolle, fait un looping avec traînée
  pointillée, se pose sur l'onglet Jeux et y dépose **+5 XP** (1×/jour) (badge ✈️ Première classe).
- **Globe** : un globe dessiné main descend, tourne puis ralentit, un pin se plante sur un pays au
  hasard → « Et si c'était ta prochaine destination ? » (badge 🌍 Tour du monde).
- **Carte → coordonnées du Titanic** (41.73 N, 49.95 W) : un paquebot + iceberg vectoriels naviguent,
  mouette qui suit (badge 🚢).
- **Carte → large/océan (zoom dézoomé sur l'eau)** : une **baleine** apparaît.
- **Carte → Saint-Jacques-de-Compostelle** : easter egg pèlerin (badge 🐚 Pèlerin).
- **Secouer le téléphone (shake)** : tirage « magic 8-ball » voyage → réponse surprise (badge Shaker).
- **Ouvrir l'app entre 00:00 et 00:05** : pluie d'**étoiles filantes** (badge 🌠 Minuit pile).
- **Le 4 mai** : easter egg « May the 4th » (badge ⭐).
- **Le jour de ton anniversaire** : confettis + message doré personnalisé (badge 🎂).
Anti-spam : chaque egg a un cooldown ; l'admin a un cooldown réduit pour tester.

## Saison & ambiance vivante
- **Décembre** : les pastilles-marqueurs de la carte portent un petit **bonnet de Père Noël**.
- **Pluie de saison** plein écran (pétales/feuilles/flocons selon la saison) + **confettis** lors des
  célébrations (level-up, anniversaire, quête validée).
- Halos dorés, reflets « polish », dégradés radiaux d'arrière-plan (golden hour).

## Micro-interactions premium
- **Double-tap sur un post** = burst de cœur (façon Insta).
- **Pull-to-refresh** maison (« roulette ») qui ré-applique aussi la DA publiée.
- **Skeletons shimmer** au chargement ; **toasts** en haut ; **popInfo** (modale illustrée).
- **Chiffres tabulaires** pour compteurs/XP/streak/niveaux/prix (alignement premium).
- **Streak** 🔥 N jours mis en avant sur l'accueil.
- **Moteur de sons** (clics, succès, level-up, pièce, déverrouillage, notif, match, whoosh…) —
  discret, activable.
- **Effets CRT / 8-bit** dédiés au mode rétro.

## Profil, cosmétiques & boutique
- **Cadres d'avatar** déblocables (cosmétiques) : Sunset, Corail, Émeraude, Or, Royal, **Aurore animée**
  (halo qui pulse) — boutique d'XP.
- **QR de profil** généré 100% en local + **scan caméra** (jsQR) pour s'ajouter en personne.
- **Badges secrets** (~30) à condition cachée, visibles/explicables uniquement par un **compte admin** :
  premier check-in, première quête, quest-master, explorateur, gardien, polyglotte, légende, vérifié,
  social, reviewer… + tous ceux des easter eggs.

## Sécurité & social avancés
- **Vouch** (recommandations entre membres) qui nourrissent le score de confiance.
- **Présence** temps réel (« en ligne » en ton sunset), **alerte d'urgence diffusée** au cercle de
  confiance (bannière), partage de position temps réel.
- **Photo lightbox** plein écran (zoom sur les photos de lieux/profils).
- **Écran de bannissement** cinématique (si compte banni) couvrant tout l'écran.

## Internationalisation maligne
- Dictionnaire FR→EN complet **+ filet de traduction auto** (API) pour le texte non couvert, avec
  heuristique « ça ressemble à du français » pour ne PAS traduire les noms propres / pseudos. Cache local.

## Admin & DA pilotable (méta)
- **Console DA** dans l'onglet admin : presets d'ambiance, couleurs, polices, formes, icônes, emojis,
  badges, logos, récompenses, textes — appliqués en quasi temps réel (live-push), versions/rollback.
- L'admin voit les **éléments cachés** (badges secrets + conditions) et teste les eggs en accéléré.
