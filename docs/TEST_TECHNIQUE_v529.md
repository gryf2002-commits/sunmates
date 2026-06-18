# TEST TECHNIQUE — « Ce qui fonctionne » + CONTRAT ANTI-RÉGRESSION — SunMates v529 (16/06/2026)

> **Chantier D** du plan « tout pour SunMates ». Inventaire de ce qui marche réellement +
> **contrat anti-régression** = la liste à NE JAMAIS casser dans la refonte Lite (MVP).
> Compagnon : `AUDIT_APP_v529.md` (audit complet 7 dimensions).

## ⚠️ Nature de ce test
- C'est un **test technique STATIQUE du code** : on a tracé, fonctionnalité par fonctionnalité, le handler JS **et** son effet (écriture Supabase, RPC, localStorage/IndexedDB, DOM). « Câblé pour de vrai » ≠ « vérifié dans un navigateur connecté ».
- Ce qui exige un **vrai navigateur** (et souvent une migration Supabase lancée) est listé dans **§ À confirmer en live**.
- Conclusion d'ensemble : **l'app est très largement fonctionnelle, aucun bouton placebo notable.** Le principal facteur d'échec n'est pas du code mort mais la **dépendance aux migrations Supabase** (le code dégrade en silence si une RPC/table manque — pas de crash).

---

## ✅ Ce qui fonctionne (confirmé par lecture du code)

### Confiance HAUTE (lu et confirmé en direct)
| Fonctionnalité | Preuve |
|---|---|
| **Auth** : login / signup (pseudo en metadata) / resend mail / logout+reload / `onAuthStateChange` différé (anti-deadlock) | `index.html:8431-8488` |
| **Validation inscription** : mdp ≥ 8 + pseudo 2-20 car. | `index.html:8425,8428` |
| **Sécurité — partage position** (non urgent) : confirmation DA → `insert locations_realtime is_emergency=false` | `index.html:11708-11730` |
| **Sécurité — SOS / alerte urgence** : `smConfirm` → `sendLocation(true)` `is_emergency=true`, recharge carte, état alerte, verrou `once()` | `index.html:11719-11744` |
| **Mates — envoyer une connexion** : anti-doublon bidirectionnel `.or`, gestion unicité `23505`, verrou `once()` | `index.html:12424-12442` |
| **Fermeture overlays `popInfo`** : backdrop + croix + Échap + `closePopInfo` exposé | `index.html:17273-17285` |
| **Réglages — profil public** : `update profiles` avec rollback de la case sur erreur + toast | `index.html:20133-20134` |
| **Toggle Beta/Lite** : `betaToggle` → `setBeta()` (pose/retire `body.sm-lite`) + persistance + toast | `index.html:20136` |

### Confiance MOYENNE (inventorié, cohérent avec l'architecture vérifiée — à reconfirmer en live)
| Fonctionnalité | Preuve |
|---|---|
| **Recherche Accueil** (`homeSearch`) : vrai `<input>` debouncé, filtre lieux local + profils via RPC `search_profiles` (repli `ilike` puis cache) | `index.html:5188,15286,15302-15308` |
| **Recherche Mates** (`travSearch`) : vrai `<input>` + chips rapides + ~18 filtres avancés Gold + tri match/confiance | `index.html:5551,12318-12402` |
| **Lieux** : recherche/chips (dont « Près de moi »/géoloc), avis `upsert place_reviews`, check-in RPC `redeem_checkin` (anti-triche code) | `index.html:10146-10194` |
| **Jeux** : rejoindre (`upsert user_quests`) / quitter (`delete`) / valider (RPC `complete_quest`, justif anti-triche) + auto-post feed | `index.html:13432-13564` |
| **Messages 1:1** : `insert messages`, blocage si non connectés, bulle optimiste, file hors-ligne + retry au clic | `index.html:14393-14460` |
| **Profil** : `update profiles` + `upsert profiles_private` (téléphone) + `travel_styles` best-effort + vérif additive `+30` | `index.html:9711-9730` |
| **Réglages** : changer email/mdp via `auth.updateUser` (validation ≥8) + erreurs `errFr` | `index.html:17133-17144` |
| **Sécurité** : minuteur « Rentrée en sécurité » (localStorage + re-check visibilitychange), ICE (localStorage, max 3, `tel:`), faux appel + sonnerie (IndexedDB via SMSound) | `index.html:11756-11957` |
| Onboarding/visite guidée · QR profil+scan caméra · Réglages (langue/thème/haptique/son/présence) · Accueil (feed+dispo+carte) · chat de groupe · likes feed | voir `AUDIT_APP_v529.md §2` |

### Confiance BASSE (entièrement dépendant de migrations Supabase)
| Fonctionnalité | Preuve / dépendance |
|---|---|
| **RGPD** : export + suppression compte (RPC `sm_delete_my_account`) | `index.html:17080-17102` — RPC à confirmer en base |
| **Boutique / boosts / bonus quotidien** (RPC `sm_spend_coins`/`sm_buy_boost`/`sm_claim_daily_coins`) | `index.html:13287-13428` — migrations SunCoins |
| **Feed communautaire** — likes (RPC `toggle_feed_like`) + auto-post | `index.html:17504-17593` — migrations feed |

---

## 🚫 CONTRAT ANTI-RÉGRESSION — à ne JAMAIS casser dans la Lite

> Référence absolue de la refonte (chantier E). Chaque point a une raison technique précise.

### Auth
- **Ne jamais faire de `db.from(...)` dans le callback `onAuthStateChange`** — `render()` DOIT rester différé via `setTimeout(…,0)` (`index.html:8488`), sinon **deadlock du verrou Supabase** → plus rien ne charge au reload.
- **Logout = `signOut()` PUIS `location.reload()`** (`index.html:8482`) — repartir d'un état propre (abonnements temps réel, notifs). Pas un simple re-render.
- **Conserver la gestion `email_not_confirmed`** + bouton « Renvoyer le mail » + messages succès distincts (`index.html:8438-8457`).
- **Garder mdp ≥ 8 + pseudo 2-20** à l'inscription (`index.html:8425,8428`).

### Sécurité (règles produit CLAUDE.md)
- **Sécurité GRATUITE pour tous** — SOS, partage position, minuteur, ICE, faux appel ne doivent JAMAIS être gatés Gold ni `data-beta` dans la Lite.
- **Confirmation DA AVANT diffusion** (`smConfirm` SOS, `popInfo` partage, `index.html:11708-11723`) + verrou `once('loc:…')` anti double-envoi (`11727`).
- **Minuteur** : garder la ré-évaluation `visibilitychange`/`focus` + grâce 30 s (compense le gel des `setInterval` onglet caché) ; **ICE reste 100 % local** (jamais en ligne).

### Mates & Messages
- **Anti-doublon bidirectionnel de `sendConnection`** (`.or` two-way) + fallback `23505` + verrou `once('connect:…')` (`index.html:12424-12442`).
- **Messages** : garder le blocage d'envoi si non connectés + file hors-ligne + retry au clic sur bulle échouée.

### Overlays & navigation
- **Toute modale fermable par backdrop + croix + Échap** (`popInfo`, `index.html:17273-17274`) ; `goToTab` nettoie recherches/composers au changement d'onglet.

### Anti-triche & intégrité (règles produit)
- **Les quêtes ne donnent PAS de `trust_score`** (XP seulement).
- **Check-in & complétion** passent par RPC serveur (`redeem_checkin` / `complete_quest`).
- **Vérification = `+30` ADDITIF** (ne réécrase pas le `trust_score`).

### Robustesse
- **Défense anti-migration** : garder le pattern `try/catch` best-effort (ex. `travel_styles`, `grantBadgeServer`) — une RPC/table absente doit **dégrader en silence** (toast/no-op), jamais bloquer ni crasher.
- **Profil** : téléphone dans `profiles_private` (RLS propriétaire), **jamais dans `profiles` public**.
- **RGPD** : export + suppression (`sm_delete_my_account`) accessibles dans les Réglages.

### DA & stack
- **Indicateurs validé/en-ligne en tons sunset** (ambre/doré), **jamais de vert criard** ; scrollbar thémée ; **rouge réservé au danger/SOS**.
- **STACK** : la Lite reste **un seul `index.html` vanilla + Supabase CDN**, sans framework ni build. Ne pas imposer Tailwind/`sunmates-app.html` sans décision produit explicite.
- **Sons** : tout son passe par **SMSound** (banque + mute + admin), jamais en WebAudio direct.

---

## 🔬 À confirmer en live (test navigateur requis)
> Idéalement avec le compte de test (cf. mémoire) via Puppeteer, **sans toucher au Chrome de l'utilisateur**.

1. **Recherche Accueil** : la saisie filtre lieux ET personnes ; repli `ilike` quand `search_profiles` absente.
2. **Recherche Mates** : chaque chip/tri re-rend avec les bons prédicats.
3. **Lieux** : recherche, « Près de moi » (géoloc), avis (`place_reviews`), check-in code (`redeem_checkin`).
4. **Jeux** : rejoindre/quitter/valider une quête de bout en bout + auto-post feed.
5. **Messages** 1:1 et groupe : envoi réel, bulle optimiste, file/retry (groupe = migration `group_*` en attente).
6. **Profil** : enregistrement des ~30 champs, téléphone privé, vérif `+30`.
7. **RGPD** : export + suppression (`sm_delete_my_account` présente ?).
8. **Boutique/boosts/bonus** : RPC `sm_spend_coins`/`sm_buy_boost`/`sm_claim_daily_coins` présentes ?
9. **Feed** : likes (`toggle_feed_like`) + tables `feed_*`.
10. **QR + scan caméra** : génération (qrcodejs) + scan (jsQR/getUserMedia).
11. **Carte** (Accueil + Sécurité) : rendu + replis raster/OSM.
12. **🔴 SÉCURITÉ BACKEND CRITIQUE** : vérifier que le **trigger `sm_guard_privilege` existe** (sinon n'importe quel compte s'auto-attribue `is_admin/is_gold/banned` via la clé anon). **Avant tout déploiement.**
13. **Offline** : confirmer que le client Supabase CDN est pré-caché + version figée (sinon écran mort au 1er lancement hors-ligne).
14. **`openLiteBtn`** : confirmé qu'il ouvre `sunmates-app.html` (Tailwind séparé) — **décision produit à trancher** (`index.html:20137`).

---

## ⚠️ Trous connus — à NE PAS reproduire dans le MVP
1. **Anti-escalade de privilèges** : écriture directe non gardée de `is_admin/is_gold/banned` → dépend du trigger `sm_guard_privilege`. Ne pas reproduire d'écriture client non gardée de ces colonnes.
2. **`sm_grant_badge`** auto-attribue n'importe quel badge (secrets/prestige/eggs). Restreindre aux badges-jalons vérifiables serveur.
3. **Masquage Lite 100 % CSS** sans garde JS → sections beta tapent Supabase quand même. Gater le chargement (`if(!betaOn())return;`).
4. **2 Lite divergentes** (`index.html` sm-lite vanilla vs `sunmates-app.html` Tailwind hors-stack). Ne pas dupliquer cette divergence.
5. **Contraste** : accent corail `#FF5A4D` sur fond clair `#FFF4E6` ≈ 2,83:1 (échec AA). Texte/petites icônes → `--accent-ink`, pas `--accent` brut.
6. **~30 familles ambre figées en hex** (`.pcard-top/.vchip/.rate-top/.hud-bar`). Ne pas recoder de surface en dur → tokens.
7. **Supabase CDN non pré-caché + `@2` non pinné** → app morte au 1er lancement hors-ligne. Pinner + pré-cacher avant de s'appuyer dessus.
8. **Migrations potentiellement non lancées** (groupes, solo_tasks, suncoins, Pro, eggs, feed, admin_live). Ne pas classer ces features « cassées » sans confirmation backend, ni les considérer acquises.
9. `loadHome` retourne tôt si `#homeCafes` absent (`index.html:8702`) = **comportement volontaire**, pas un bug à corriger.
