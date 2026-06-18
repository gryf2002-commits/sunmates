# SunMates — Idées & roadmap (vivant)

> Effort : 🟢 rapide · 🟠 moyen · 🔴 gros. Tout reste compatible : 1 `index.html` + Supabase + GitHub Pages, DA coucher de soleil.

## ✅ Déjà fait (ne pas reproposer)
Faux appel · parrainage (coupon 1er verre) · QR profil · i18n FR/EN · streak quotidien (+ joker hebdo, récap dimanche) · compression photo + cropper · service worker offline · signalements/blocages · réactions ❤️ messages + double-tap post · commentaires fil · notes vocales · traduction auto · poc/flammes · check-in festif · carte vivante (lieux/Mates/activités/quêtes) · mini-jeux · badges (prestige + secret) · recherche par portée · monitoring Sentry/PostHog · durcissement RLS + anti-XSS.

## ⭐ Signature (différenciantes)
- **« Mon voyage » — matching temps + lieu** 🟠🔴 — déclarer son itinéraire (ville+dates), voir qui sera là en même temps. Table `trips` + chevauchement. *La killer feature.*
- **Carnet / « Wrapped » partageable en image** 🟠 — recap check-ins+badges+Mates rendu canvas → story Insta. Croissance gratuite.
- **Vérification RÉELLE (selfie+doc)** 🔴 — Stripe Identity/Veriff via Edge Function. Le moat de confiance + exigé par les stores.

## 🟢 Sécurité (gratuit, ADN « sécurité d'abord »)
- **« Je suis bien arrivé·e » minuté** 🟢 — timer ; si non confirmé → alerte au cercle. Très demandé solo.
- **« Follow me home » live** 🟠 — partage de position live à un contact de confiance jusqu'au « je suis safe ».
- **Safety score / heatmap quartier** 🟠 — zones plus ou moins fréquentées/sûres.

## 🟢 Engagement / social (nouvelles, pas encore proposées)
- **« Dispo maintenant / ce soir »** 🟢 — flag d'intention sur ton point (remplace « Qui est là »).
- **Heatmap « où ça bouge »** 🟢 — `leaflet.heat` sur la carte actuelle.
- **Sondages dans le fil** 🟢 — posts à voter (« plage ou montagne ? »).
- **Mode découverte « cartes à swiper »** 🟠 — deck Tinder-like pour découvrir des voyageurs (Pointer Events).
- **Évènements avec RSVP** 🟠 — meetup daté dans un lieu sûr, « je viens » (table `events` + `event_rsvps`).
- **Groupes par destination** 🟠 — un fil/chat par ville (« Lisbonne »).
- **Échange linguistique** 🟢 — match « je parle X, j'apprends Y » (langues déjà au profil).
- **Recommander un lieu à un Mate** 🟢 — envoyer une épingle dans le chat.
- **Passeport de villes à tampons** 🟢 — collection de tampons par ville visitée.
- **Thème auto jour/nuit selon l'heure locale** 🟢 — bascule au coucher du soleil (raccord DA).
- **Rappel d'expiration de la flamme** 🟢 — notif « plus que 3h pour garder ta série ».

## 🔌 Plugins utiles (CDN + fallback)
PhotoSwipe (galerie plein écran 🟢) · Fuse.js (recherche tolérante aux fautes 🟢) · Day.js (dates légères 🟢) · leaflet.heat (heatmap 🟢) · DOMPurify (sécurité UGC, en complément de l'échappement maison 🟢).

## 🔔 Rétention n°1 : notifications push
Infra présente (table `push_subscriptions` + handler `push` dans le SW). **Reste à finaliser l'envoi** côté serveur (Edge Function ou OneSignal free) : nouveau message, demande, « un Mate arrive dans ta ville ». 🟠 — le plus gros levier de retour.

## ⚖️ Avant les stores (bloquant, pas une feature)
18+ + CGU · suppression de compte dans l'app (RGPD) · export de données · consentement analytics.

## 🏆 Top 3 si je dois choisir
1. **« Je suis bien arrivé·e »** (🟢, victoire immédiate, ADN sécurité).
2. **« Mon voyage »** (signature produit).
3. **Notifications push finalisées** (sans elles, pas de rétention).
