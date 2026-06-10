# 🔍 Audit complet SunMates — 10 juin 2026

> Audit 360° : sécurité/RGPD · architecture/scalabilité · UI/UX/DA · fonctionnalités.
> Snapshot : `index.html` 14 675 lignes (1,21 Mo / 342 Ko gzip), v371, 32 tables Supabase, 103 policies RLS.
> Objectif : monétisation + base d'utilisateurs mondiale.

---

## Verdict en une phrase

**Le produit est bien au-delà d'un MVP et le rendu est professionnel** (DA tenue à ~90 %, mode nuit excellent, RLS mûres, XSS maîtrisé avec 216 usages d'`escapeHtml`) — mais **4 risques sérieux** (relais e-mail ouvert, rétention GPS illimitée, consentement RGPD absent, requêtes full-table) et **une dette structurelle** (monofichier qui a doublé en 6 jours) doivent être traités **avant** tout scaling.

---

## 🔴 P0 — à corriger immédiatement

| # | Problème | Où | Statut |
|---|---|---|---|
| 1 | **Edge Functions exposées.** (a) `send-email` acceptait `{to, subject, html}` arbitraires = relais e-mail ouvert — mais **jamais déployée** (risque théorique) : code du repo sécurisé pour plus tard. (b) `send-push` **est déployée** sans Verify JWT (requis pour les webhooks) → n'importe qui pouvait pousser des notifs arbitraires à n'importe quel utilisateur. | `supabase/functions/send-email/index.ts` · `send-push/index.ts` | ✅ `send-push` sécurisée par secret partagé (`x-webhook-secret`) — **à redéployer + configurer le secret** (voir ci-dessous) |
| 2 | **Positions GPS conservées à vie** : l'UI affiche « expire dans X min » mais aucune purge/TTL serveur. Pour une app de voyageuses solo = risque vie privée majeur + violation minimisation RGPD. | `locations_realtime` | ✅ Migration prête : `supabase_migration_audit_p0.sql` — **à exécuter dans le SQL Editor** |
| 3 | **PostHog démarre sans consentement** (autocapture dès le chargement) → non conforme RGPD/CNIL pour des utilisateurs UE. | `index.html` l.28-44 | ✅ Corrigé : bannière de consentement, PostHog ne démarre qu'après opt-in |
| 4 | **Full table scans** : `loadConnections()` chargeait TOUTE la table `profiles` + TOUTE `matches_connections` à chaque ouverture de Mates ET à chaque message reçu. À 10k profils ≈ 10 Mo de JSON par appel → mur d'egress Supabase. | `index.html` ~l.7717 | ✅ Corrigé : requêtes filtrées sur `myUserId` |
| 5 | **Realtime non filtré** : `messages-rt` écoutait tous les INSERT de `messages` (coût RLS × tous les abonnés = goulot connu Supabase). | `index.html` ~l.9785 | ✅ Corrigé : `filter: recipient_id=eq.<moi>` |
| 6 | **Aucun index DB** sur les colonnes les plus requêtées (`messages`, `matches_connections`, `user_quests`, `checkpoints`) → seq scans dès 100k lignes. | SQL | ✅ Dans `supabase_migration_audit_p0.sql` |
| 7 | **Suppression de compte incomplète** : `sm_delete_my_account` avale les erreurs en silence et oublie des tables (`feed_likes`, `user_coupons`, `user_badges`, `quote_requests`, logs XP/coins…). | SQL | ✅ Dans `supabase_migration_audit_p0.sql` |
| 8 | **Historique de chat sans limite** : tout l'historique chargé d'un coup. | `index.html` ~l.9491 | ✅ Corrigé : `.limit(100)` |
| 9 | **Mot de passe sans minimum au signup** (seul le changement imposait 6 caractères). | `index.html` ~l.4820 | ✅ Corrigé : min 8 caractères au signup (+ règle à durcir dans le dashboard Supabase Auth) |
| 10 | **3 z-index hors-échelle** (100010, 100000, 99999) qui cassent l'échelle nommée `--z-*` (plafond confettis 6000). | `index.html` l.800/2913/2950 | ✅ Corrigé : tokens `--z-popinfo/--z-signal/--z-sheet` |

### Actions manuelles côté dashboard Supabase (5 min)
1. **SQL Editor** → exécuter `supabase_migration_audit_p0.sql` (inclut désormais les limites Storage : taille + MIME des buckets `avatars`/`voicenotes`).
2. **`send-push`** (la seule fonction réellement déployée) : générer un secret aléatoire → l'ajouter dans Edge Functions > send-push > Secrets sous `WEBHOOK_SECRET` → ajouter le header `x-webhook-secret` aux 3 webhooks (Database > Webhooks) → redéployer `supabase functions deploy send-push --no-verify-jwt`. ⚠️ Tant que ce n'est pas fait, la nouvelle version refuse tout (fail-safe) : les push cesseront après redéploiement si le secret manque.
3. **Auth → Settings** : longueur minimale du mot de passe ≥ 8.
4. **Database → Extensions** : activer `pg_cron` si tu veux la purge GPS automatique (sinon la policy temporelle suffit pour la lecture).
5. `send-email` : rien à faire (jamais déployée) — le code sécurisé reste dans le repo pour le jour où tu en auras besoin.

---

## 🟠 P1 — ce mois-ci (avant d'accélérer l'acquisition)

**Sécurité / RGPD**
- **Politique de confidentialité + mentions légales formelles** (page dédiée : responsable de traitement, base légale, durées de conservation, contact). Le pop actuel est un bon début mais insuffisant juridiquement — surtout avec géoloc + données sensibles (orientation, opinions affichées sur profil public).
- Rate-limiting sur les INSERT anonymes (`app_feedback`, `quote_requests`) : captcha (Turnstile gratuit) ou passage par Edge Function.
- Échapper `error.message` dans les `toast()` (innerHTML) — risque faible mais principe de défense.

**Performance / coût**
- **Service worker : passer la navigation en stale-while-revalidate** + bandeau « nouvelle version dispo » (le canal `skipWaiting` existe déjà, sw.js l.114). Aujourd'hui les 342 Ko sont re-téléchargés à CHAQUE ouverture → le soft-limit GitHub Pages (100 Go/mois) explose vers ~5k utilisateurs actifs/jour. Cette seule correction divise la bande passante par ~10.
- `supabase-js` en `defer` dans le `<head>` (actuellement bloquant en plein body l.4650) ; `defer` sur `sunmates-badges.js`/`sunmates-icons.js` ; réduire les graisses de polices (2-3 suffisent).
- Présence : `touch_presence` écrit en DB toutes les 60 s par utilisateur (170 writes/s à 10k connectés) → passer à Supabase Realtime Presence (en RAM, gratuit).
- Pagination : `.range()` est utilisé 0 fois ; 31 `select("*")`. Ajouter limites + « charger plus » sur les listes longues (admin, feed).

**Dette CSS / DA**
- **Purger les couches `:root` mortes** (l.2293-2700 : thèmes « rétro » et « ivoire-espresso » avec ivoire `#F4EDE0` et terracotta — littéralement ce que la DA bannit), fusionner la couche v3 dans le `:root` de base → supprime la majorité des 191 `!important`.
- Consolider les ~15 corails/oranges parallèles (`#ff7e5f`, `#ff6f3d`, `#ff7a4d`, `#ff9f1c`…) vers les tokens. Statuer sur le rose `#ff4f6d` entré dans `--accent-grad` v3 (le documenter ou revenir au `#FF5A4D` canonique).
- Token `--cream #FFF1E0` utilisé 50× en masse de fond : contradiction avec « pas de crème en masse » → renommer/documenter ou réchauffer.
- Dernier vert criard : `.thumb.lime` (l.2776). ✅ corrigé (passé en ambre DA).

**UX / finition**
- **Accueil jour trop dense** (1er écran vu !) : hero coupé par les chips « Étape 1 », 7 contrôles flottants sur 300 px autour de la carte → regrouper les 3 boutons flottants, chips sur leur propre ligne.
- Bannière PWA qui **recouvre** les titres (login, Jeux) au lieu de pousser le layout.
- Contraste : `--muted #AC93A3` sur fond clair ≈ 2,6:1 (échec AA) ; bouton « Premium » blanc sur ambre clair < 3:1.
- ~30 boutons icône-seule sans `aria-label` (✕, rouage, clear…) — 343 boutons pour 29 aria-label.
- État vide brandé sur Messages déconnecté (actuellement pilule blanche vide).
- `manifest.json` : ajouter `screenshots` (installation PWA premium, 10 min avec les PNG existants) + champ `id`.

**Outillage**
- Migrer les 62 fichiers SQL de la racine vers `supabase/migrations/` horodatés (CLI Supabase) — aujourd'hui impossible de reconstruire la base de façon fiable.
- CI GitHub Actions minimale : `_smoke_alltabs.js` headless à chaque push.
- Sentry : `release` figée à v273 alors que l'app est en v371 → bumper automatiquement.

---

## 🟢 P2 — trajectoire de scalabilité (3 étapes, sans réécriture)

**La stack tient-elle ?** 1k ✅ (avec les P0 + Supabase Pro 25 $/mois) · 10k ⚠️ (après P1 + étape 2) · 100k ❌ en l'état.

**Étape 1 — Assainir (1-2 semaines, fait en grande partie aujourd'hui).** P0 appliqués, Supabase Pro. Capacité : ~1-5k utilisateurs.

**Étape 2 — Découper, pas réécrire (1-2 mois).** Introduire **Vite** en gardant 100 % du JS vanilla : extraire `styles.css` + ~10 modules ES (`auth.js`, `chat.js`, `map.js`, `quests.js`, `i18n.js`, couche `data/` centralisant les 134 appels Supabase). C'est du copier-coller progressif — les commentaires `// ======` sont déjà la table des matières. Bénéfices : fichiers avec hash → SW cache-first (fini les 342 Ko/visite), code splitting (Leaflet à la demande), lint/CI. Déménager vers **Cloudflare Pages** (gratuit, bande passante non plafonnée, mêmes push-deploys). Capacité : ~10-30k.

**Étape 3 — Monétiser et durcir (3-6 mois, quand la traction est là).** Logique sensible (paiements Stripe, quotas, modération) en Edge Functions ; vérification d'identité réelle (Stripe Identity/Veriff) — c'est le cœur de la promesse et elle est aujourd'hui simulée ; images via transformations Supabase/Cloudflare ; landing SEO séparée de l'app ; Google Play via TWA (la PWA suffit), iOS via Capacitor si besoin. **Aucune réécriture React nécessaire** : le levier est la couche données + l'hébergement, pas le framework.

**i18n** : le FR/EN actuel fonctionne (≈1 600 paires) mais repose sur une correspondance exacte des chaînes FR (+ MutationObserver coûteux) → toute reformulation FR casse silencieusement l'EN. Pour ES/IT/PT : migrer vers des clés (i18next).

---

## ✅ Ce qui est déjà très bien (à préserver)

- **RLS mûres** : GPS lisible par le cercle de confiance uniquement, téléphone isolé dans `profiles_private`, messages restreints aux connexions acceptées, `SECURITY DEFINER` avec `search_path` fixé partout, anti-triche XP/coins/badges par triggers et RPC atomiques.
- **XSS maîtrisé** : `escapeHtml` utilisé 216 fois, `_safeImgUrl` pour les avatars, zones sensibles (feed, chat, avis, profils, popups carte) toutes échappées.
- **Aucun secret commité** ; `.gitignore` propre ; les 85 PNG de debug ne partent pas en prod.
- **SW soigné** : pas de cache de réponses authentifiées, LRU média borné, offline réel.
- **RGPD partiel mais réel** : export JSON des données + hard delete du compte (désormais complet).
- **DA tenue à ~90 %**, mode nuit excellent, icônes/badges 100 % maison, toasts en haut, reduced-motion, skeletons, file offline de feedback rejouée au retour réseau.
- Push Web réel (VAPID), présence, vouch, parrainage, sondages, vocaux, streak, admin — bien au-delà du MVP.

---

*Audit réalisé par 3 passes parallèles (sécurité/RGPD, architecture, UI/UX) sur le code, les 62 SQL, les Edge Functions, le SW et les screenshots récents. Corrections P0 appliquées le 10 juin 2026 — détail dans le tableau ci-dessus.*
