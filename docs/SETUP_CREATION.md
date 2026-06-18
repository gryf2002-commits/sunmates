# SunMates — Plan de création : agents, stores, scaling, boîte à outils

## 1. Tes agents Claude Code (mis en place ✅)

Trois agents spécialisés sont prêts dans `claude-agents/`. Claude Code lit les agents
du projet dans `.claude/agents/` → **une commande pour les activer** (dans le dossier
du projet) :

```
mkdir -p .claude/agents && mv claude-agents/*.md .claude/agents/
```
(Windows cmd : `mkdir .claude\agents` puis `move claude-agents\*.md .claude\agents\`)

| Agent | Rôle | Quand l'utiliser |
|---|---|---|
| `sunmates-design` | Designer DA coucher de soleil (lit `DESIGN_SYSTEM.md`) | tout travail visuel — c'est ton « Claude Design » |
| `sunmates-backend` | Supabase : tables, RLS, migrations, perfs | backer chaque fonctionnalité |
| `sunmates-qa` | Contrôle qualité avant commit | après chaque lot de modifs |
| `sunmates-marketing` | ASO stores, posts réseaux, landing, pitch lancement | tout contenu de promo |

Usage dans Claude Code : `/agents` pour les voir, ou directement
« *Utilise l'agent sunmates-design pour embellir l'écran profil* ». Ils travaillent
« de concert » : design → backend → qa, et tous respectent `DESIGN_SYSTEM.md` + `CLAUDE.md`.

> « API Claude Design » : ça n'existe pas en tant que tel — l'agent `sunmates-design`
> joue ce rôle, gratuitement via ton abonnement Claude Code. L'API Claude (payante au
> token) ne te servira que si un jour l'APP elle-même appelle l'IA (ex. icebreakers générés).

## 2. Chemin vers les stores (avec ta stack actuelle)

Ta base PWA (manifest + service worker) est déjà le bon socle. Deux voies :

**Android / Play Store — la voie rapide ✅**
- Empaqueter la PWA en **TWA** avec **PWABuilder** (pwabuilder.com, gratuit) ou Bubblewrap.
- Prérequis : score Lighthouse ≥ 80, Digital Asset Links (vérif du domaine), manifest propre.
- Coût : **25 $ une seule fois** (compte Google Play Developer).

**iOS / App Store — plus exigeant**
- Apple n'accepte pas les TWA → envelopper l'app avec **Capacitor** (capacitorjs.com).
- Prérequis : compte Apple Developer (**99 $/an**), un Mac avec Xcode pour builder,
  et surtout : Apple rejette les apps « juste un site » → mettre en avant ce qui est
  « app-like » (offline, notifications push, géoloc, gamification).
- Conseil d'ordre : lancer **Android d'abord** (rapide, pas cher), iOS ensuite.

**À préparer avant soumission (les 2 stores)**
- Icônes toutes tailles + splash screens (PWABuilder/Capacitor les génèrent).
- Captures d'écran stores (utilise tes écrans réels, en clair ET nuit).
- Politique de confidentialité (obligatoire — page web simple) + RGPD (suppression de compte dans l'app).
- Modération : signalement + blocage déjà prévus dans tes règles produit → indispensable
  pour une app sociale sur les stores (Apple y est très attentif).

## 3. Supporter une grosse base de joueurs (Supabase)

Plan gratuit actuel : **500 Mo de base, 50 000 utilisateurs actifs/mois, 200 connexions
realtime simultanées (2M messages/mois), 1 Go de stockage fichiers, pause après 1 semaine
d'inactivité, 2 projets max**. → Largement assez pour lancer et tester.

Seuils de passage au plan **Pro (25 $/mois)** : base > 500 Mo, > 200 utilisateurs
connectés en même temps (chat/positions temps réel), photos > 1 Go, ou besoin de
sauvegardes/pas de pause.

Bonnes pratiques dès maintenant (l'agent backend les applique) : index sur les colonnes
filtrées, pagination, `select` ciblés, realtime limité au chat/alertes, images
compressées avant upload.

## 4. Boîte à outils gratuite (recos)

**Design / UI**
- Figma (gratuit) — tes maquettes, à garder comme source d'inspiration DA
- Tabler Icons / Lucide (icônes SVG cohérentes — remplaceront les emojis-icônes)
- Coolors.co (vérifier l'harmonie palette) · Realtime Colors (tester palette+typo)
- Unsplash / Pexels (photos libres pour les visuels lieux/quêtes)
- WebAIM Contrast Checker (contraste AA)

**UX / qualité**
- Lighthouse (dans Chrome DevTools) — obligatoire pour la TWA, vise ≥ 90
- PostHog (free tier) ou Umami — analytics produit (quels écrans sont utilisés)
- Sentry (free tier) — remonter les erreurs JS des vrais utilisateurs
- BrowserStack a un essai limité ; sinon tester sur 2-3 vrais téléphones (ton réseau de potes 😄)

**Marketing / lancement**
- Canva (gratuit) — visuels stores, posts réseaux (réutilise la DA corail)
- Une landing page simple (GitHub Pages aussi !) avec lien d'install + captures
- Play Console « internal testing » + TestFlight (iOS) — bêta avec tes potes
- ASO de base : nom + sous-titre avec mots-clés (« voyage solo », « rencontre amicale »,
  « sécurité »), captures localisées FR/EN
- Communautés où montrer l'app : r/solotravel, groupes FB voyage solo, Product Hunt au lancement

## 5. Ordre de marche conseillé
1. Activer les agents (commande ci-dessus) + corriger le brief en cours (`BRIEF_CORRECTIONS_retours.md`).
2. Backer les features encore « démo » (quêtes/badges/coupons réels) avec `sunmates-backend`.
3. Lighthouse ≥ 80-90 + politique de confidentialité + suppression de compte.
4. Play Store via PWABuilder (TWA) → bêta interne avec tes amis.
5. Analytics + Sentry → corriger ce qui remonte.
6. iOS via Capacitor quand Android est stable.
