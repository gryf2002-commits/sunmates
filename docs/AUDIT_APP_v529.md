# AUDIT APP — SunMates v529 (16/06/2026)

> **Chantier C** du plan « tout pour SunMates ». Audit technique complet de `index.html`
> (20 540 lignes, ~1,75 Mo, vanilla mono-fichier + Supabase CDN, GitHub Pages, SW v529).
> Produit par un workflow multi-agents (1 cartographe + 7 auditeurs + 1 contrat, ~639K tokens).
> **Lecture seule — aucun fichier modifié.** Compagnon : `TEST_TECHNIQUE_v529.md` (ce qui marche + contrat anti-régression).

## Méthode & portée
- Audit **statique du code** (Grep + Read ciblés, preuves `index.html:LIGNE`). Ce qui exige un navigateur réel est listé dans `TEST_TECHNIQUE_v529.md › À confirmer en live`.
- L'**état réel de Supabase** (migrations lancées ou non) n'est pas vérifiable depuis le repo → marqué `depends-migration`.
- Statuts : `works` (câblé+effet) · `partial` · `stub` · `broken` · `depends-migration` · `risk` · `missing`.

---

## 🔴 Synthèse exécutive — à traiter en priorité

### P0 (bloquant / sécurité)
1. **Anti-escalade de privilèges non garantie** — la policy `UPDATE profiles` ne filtre pas les colonnes. **Sans le trigger `sm_guard_privilege`** (`supabase_migration_hardening.sql`), n'importe quel compte peut, avec la clé anon publique, faire `update profiles set is_admin=true / is_gold=true / banned=false`. **À confirmer/lancer en base AVANT tout lancement.** Le panneau diagnostics ne sonde même pas ce trigger.

### P1 (important)
2. **Décision produit « Lite » à trancher** — le bouton « version lite » ouvre `sunmates-app.html` (app **Tailwind séparée**, palette `#b5241f/#faf8ff` divergente), PAS `index.html` en `sm-lite`. **Deux Lite coexistent et divergent.** CLAUDE.md impose la stack vanilla mono-fichier → `sunmates-app.html` sort du cadre. **Ceci gate la refonte Lite (chantier E).**
3. **`sm_grant_badge` permet l'auto-attribution de n'importe quel badge** (secrets/prestige/eggs) sans vérifier la condition → casse l'intégrité du classement par badges.
4. **Client Supabase non pré-caché + version `@2` non figée** — `createClient` indispensable à tout le JS, ni dans `SHELL` ni dans `CDN_PRECACHE` du SW → 1er lancement hors-ligne = app morte. Et `@2` peut servir une nouvelle mineure à tout moment (régression non maîtrisée).
5. **Masquage Lite 100 % CSS, aucune garde JS** — `renderSoloChallenges/Rituals/Shop/suggestions/vouch` s'exécutent quand même et tapent Supabase en mode lite (réseau gaspillé).
6. **Contraste AA** — accent corail `#FF5A4D` sur fond sunset `#FFF4E6` ≈ **2,83:1** (échec AA texte) ; blanc sur CTA corail plein ≈ 3,08:1 (AA-large seulement).
7. **Ambre figé en dur sur ~30 familles** (`.pcard-top`, `.vchip`, `.rate-top`, `.hud-bar`…) — juste en sunset, mais ne suivra aucun autre preset DA.

### Ce qui est SAIN et rassurant
- ✅ **Pas de troncature** (finit par `</script></body></html>`, 18 `<script>` équilibrés).
- ✅ **Fix « chargement infini » (v468) confirmé** : navigation réseau-d'abord, timeout 6 s (AbortController), repli coquille.
- ✅ **Aucun secret sensible exposé** (clé anon publique conforme ; aucune service_role/JWT/token GitHub/Stripe).
- ✅ **App très largement câblée pour de vrai** : aucun bouton placebo notable détecté.
- ✅ **Base a11y/i18n au-dessus de la moyenne** (focus-visible, shim clavier, shim aria-label, reduce-motion, toast aria-live, moteur i18n FR/EN).
- ✅ **Doctrine DA respectée** : statuts en ambre/doré (pas de vert criard), rouge réservé au danger/SOS, surfaces nuit homogènes prune/violet, scrollbar thémée.

---

## Carte de l'app (repères)
- **Scripts** : Sentry (l.10, async), Leaflet/markercluster/MapLibre/qrcode/jsQR (defer, l.181-198), `sunmates-badges.js?v=529` (l.200), `sunmates-icons-v2.js?v=541` (l.201), Supabase v2 (l.6718), `sunmates-da-loader.js?v=11` (l.20534), `da-console-overlay.js?v=23` (l.20538). `sunmates-lite.css` (l.4635).
- **CSS** : bloc principal l.250-4351 ; `<style id=sm2026>` l.4400-4633 (règle Lite l.889).
- **JS** (tout dans un `<script>` non-module après Supabase) : init `db` l.6724 ; `render(session)` l.8491 ; routeur `goToTab` l.8672 ; Accueil `loadHome` l.8701 ; Lieux `renderCafesList` l.10020 ; Jeux `renderJeux` l.13012 ; Mates `renderTravelers` l.12318, chat l.14017+ ; Sécurité `renderIce`/SOS l.11719-11894 ; Profil l.9590+ ; beta/Lite l.20096-20215.
- **Nav** : `data-tab` l.6647-6652 (Accueil · Lieux · Jeux · Mates · Sécurité · Profil).
- **SW** (`sw.js` v529) : navigation timeout 6 s, même-origine no-store+repli `ignoreSearch`, médias cache-first (LRU 350, non versionné), CDN SWR, **Supabase REST/Auth jamais caché**, push VAPID public.
- **Tables Supabase** (~40) : `profiles`, `profiles_private`, `partner_cafes`, `cafe_codes`, `checkpoints`, `place_reviews`, `trips`, `quote_requests`, `matches_connections`, `blocks`, `messages`, `message_reactions`, `group_*`, `quests`, `user_quests`, `quest_*`, `user_badges`, `badges_catalog`, `user_coupons`, `feed_*`, `reports`, `app_feedback`, `locations_realtime`, `map_activities`, `solo_tasks`, `user_solo_log`, `vouches`, `push_subscriptions`.
- **RPC** (~29) : `redeem_checkin`, `complete_quest`, `search_profiles`, `sm_spend_coins`, `sm_claim_daily_coins`, `sm_buy_boost`, `sm_delete_my_account`, `toggle_feed_like`, `report_user`, `grant_solo_xp`, `sm_grant_badge`, `admin_*`, `leaderboard`, etc.

---

## 1) Architecture & qualité de code
> SPA vanilla mono-fichier cohérente avec la stack imposée. Points critiques sains (pas de troncature, ordre scripts correct, SW v529 aligné, fix chargement infini présent). Code étonnamment propre (449 try/catch, 0 console.log). Faiblesses surtout structurelles & non bloquantes.

| Sév. | Statut | Constat | Preuve | Reco |
|---|---|---|---|---|
| P3 | works | Pas de troncature, fin propre | `index.html:20531-20540` | Garder le garde-fou « finit par `</html>` ». |
| P3 | works | SW : garde-fou AbortController 6 s (fix v468) | `sw.js:84-98` | RAS. Cache média non versionné = acceptable (LRU 350). |
| **P2** | risk | `index.html` et `preview.html` **byte-identiques** (md5 identiques) | `cmp` IDENTICAL | Recréer un écart contrôlé (modifs d'abord en preview). Plus de filet de test isolé. |
| **P2** | risk | **153 fichiers debug/jetables** à la racine (`_diag_*`, `_shot_*`, `_live_index.html` 1,73 Mo…) | `ls _*.js _*.html`=153 | Déplacer dans `_scratch/` gitignoré ou supprimer. Vérifier 0 secret avant (publiés sur Pages). |
| **P2** | partial | `render()` async **sans try/catch englobant** + dépend d'un probe bloquant ~3,2 s | `index.html:8491,8502,8570-8577` | Envelopper `render()` (toast + « Réessayer »). Borner `ensureAuthedSession`. |
| P3 | works | Beta/Lite câblé (data-beta + body.sm-lite) | `index.html:889,20098-20105` | RAS (détaillé §7). |
| P3 | works | Outils admin (DA loader/console) gatés & inertes en prod | `da-loader.js:10-13`, `overlay.js:430-431` | Décider à terme si la console reste livrée en prod (poids). |
| P3 | partial | Pas de `'use strict'` ni handler d'erreur global (mais code défensif + Sentry) | grep=0 ; 449 try/catch | Ajouter `unhandledrejection`/`error` minimal (repli « Recharge l'app »). |
| P3 | risk | Tout le JS (~13 000 l.) dans un seul `<script>` non-modulaire (TDZ déjà corrigé en hoistant) | `index.html:6728` | Inhérent à la stack. Documenter les zones sensibles à l'ordre. Pas de refonte. |

## 2) Inventaire fonctionnel (le test « ce qui marche ») → voir `TEST_TECHNIQUE_v529.md`
> L'app est **très largement câblée pour de vrai**. Les 2 barres de recherche sont de vrais `<input>` debouncés qui filtrent. Filtres = vrais prédicats. Overlays fermables (backdrop + croix + Échap). Boutons critiques (SOS, partage position, check-in, vérif, achat, quête, message, ICE, RGPD) tous reliés. **Aucun bouton placebo notable.** Le facteur de risque = dépendance migrations Supabase (dégradation silencieuse, pas de crash).

Détail complet de chaque fonctionnalité (status + preuve) dans `TEST_TECHNIQUE_v529.md`.

## 3) Supabase / Données / Sécurité
> Architecture conforme (clé anon publique + RLS = seul rempart). Aucun secret exposé. Tous les RPC appelés ont une définition SQL. Risque dominant = **dépendance aux migrations** (toute l'intégrité vit dans ~77 `supabase_*.sql` lancés à la main).

| Sév. | Statut | Constat | Preuve | Reco |
|---|---|---|---|---|
| **P0** | depends-migration | Anti-escalade de privilèges dépend du trigger `sm_guard_privilege` | `index.html:11443`, `schema.sql:27-30`, `hardening.sql:18-35` | **Confirmer le trigger en base, sinon lancer la migration d'urgence.** |
| **P1** | risk | `sm_grant_badge` = auto-attribution de **tout** badge sans condition | `badges_grant.sql:18-37`, `index.html:18556` | Ne granter que les badges-jalons vérifiables serveur. |
| P2 | risk | `is_verified`/`trust_score` modifiables côté client (vérif déclarative, choix MVP) | `hardening.sql:10-11`, `security_fixes.sql:82-111` (H2 commenté) | OK pour démo si assumé. Router par RPC + activer H2 avant comm « sécurité ». |
| **P1** | depends-migration | Features qui marchent en UI mais échouent sans migration (groupes, solo, suncoins, Pro, eggs, stats live, feed) | `index.html:10621-10625` | Ordre canonique d'exécution + étendre le panneau diagnostics à TOUS les RPC. |
| P3 | works | Aucun secret sensible exposé (clé anon conforme) | `index.html:6722-6723` | RAS. Maintenir la discipline. |
| P3 | works | Flux d'auth robuste (anti-deadlock onAuthStateChange, course au jeton RLS) | `index.html:8432-8488,8570` | RAS. Valider SPF/DKIM/DMARC du SMTP avant lancement. |
| P3 | works | Garde admin client cosmétique mais doublé par RLS `is_admin()` serveur | `index.html:8764`, `session10.sql:7-19` | RAS (si session10/security_fixes/hardening lancées). |
| P3 | works | Anti-spam `once()`/`notifyOnce()` + unicité signalement + anti-farm XP (cap 3/j) | `index.html:8133-8150`, `session19/29.sql` | RAS. |
| P2 | depends-migration | Suppression RGPD : 2 versions du RPC, risque de nettoyage incomplet selon l'ordre | `security_fixes.sql:53-78`, `account_deletion.sql` | `account_deletion.sql` doit être lancé EN DERNIER. Tester sur compte test. |
| P3 | works | Beta/Lite sans impact backend (cosmétique) | `index.html:889,20098-20105` | Ne jamais s'appuyer sur data-beta pour cacher une feature sensible. |

## 4) Performance & Robustesse
> SW solide (fix chargement infini OK, file d'attente messages, bandeau hors-ligne par vrai ping). Fragilités : Supabase CDN non pré-caché + `@2` non figé, boot bloquant 3,2 s, poids 1,75 Mo.

| Sév. | Statut | Constat | Preuve | Reco |
|---|---|---|---|---|
| **P1** | risk | Client Supabase CDN **non pré-caché** + version `@2` non figée | `index.html:6718`, `sw.js:17-31` | Pinner (`@2.45.x`) + ajouter à `CDN_PRECACHE`. Bumper VER. |
| P3 | works | Fix « chargement infini » v468 confirmé | `sw.js:84-98`, `index.html:216-247` | RAS. |
| **P2** | partial | Boot bloquant : `ensureAuthedSession` poll ≤3,2 s + révélation sans watchdog | `index.html:8502,8570-8577,20531` | Watchdog 4-6 s qui révèle `authView` ; rendre le poll non bloquant. |
| **P2** | risk | Poids fichier unique ~1,75 Mo (parse lourd mobile bas de gamme) | `index.html` 1748 Ko | Acceptable (stack). Externaliser le gros CSS en `.css` same-origin (caché par SW). Ne pas grossir. |
| P3 | partial | Animations CSS infinies, partiellement calmées en Lite | ≥30 keyframes ; `lite.css:14-16` | Vérifier 0 anim au repos sur l'accueil. Étendre Lite à `animation-iteration-count:1` (sauf `.su-sos/.danger`). |
| P3 | works | SW médias/CDN sain (mais cache MEDIA non versionné = avatars figés possible) | `sw.js:12-13,64,122-129` | Cache-buster `?t=` à l'upload des photos profil. |
| P2 | risk | Dépendances CDN multiples (unpkg/jsdelivr/sentry/picsum/pravatar) | `index.html:10,181-198` | Pinner versions (Supabase surtout). Libs carte déjà defer. |
| P3 | works | MAJ SW agressive (update 5 min + reload auto controllerchange) | `index.html:221-245` | RAS. Optionnel : différer reload si un champ a le focus. |

## 5) Accessibilité (WCAG AA) & i18n FR/EN
> Base sérieuse et largement câblée (focus-visible, shim clavier KBD_SEL, shim aria-label `_smSyncLabels`, reduce-motion global, toast aria-live, moteur i18n). Faiblesses : contrastes, ✕ icon-only, modales sans `role=dialog`, zoom bloqué, EN partiellement machine-traduit.

| Sév. | Statut | Constat | Preuve | Reco |
|---|---|---|---|---|
| **P1** | risk | Accent corail sur fond clair < AA (≈2,83:1) ; blanc sur CTA corail ≈3,08:1 | `index.html:3127` sur `3121` | Texte/petites icônes → `--accent-ink` foncé ; `--accent` réservé aplats/CTA gros-gras. |
| P2 | risk | 1er bloc `:root` (mort) : muted `#9aa0ac` sur `#fbeee9` = 2,31:1 | `index.html:268` sur `258` | Aligner sur la valeur conforme du bloc sunset (`#7F6878`) ou supprimer les `:root` morts. |
| P2 | partial | ~10 boutons fermeture ✕ icon-only **sans aria-label** | `index.html:4646…6540` | `aria-label="Fermer"` (clé i18n) ; étendre le shim aux `<button>` glyphe-seul. |
| P2 | partial | Modales statiques sans `role=dialog`/`aria-modal` ni piège de focus | 5 `aria-modal` vs ~10 modales | `role=dialog`+`aria-modal`+`aria-labelledby`, focus à l'ouverture, trap Tab, `inert` sur le fond. |
| P2 | risk | `viewport user-scalable=no / maximum-scale=1` bloque le zoom (WCAG 1.4.4) | `index.html:146` | Retirer `user-scalable=no`, `maximum-scale>=5`. |
| P2 | partial | EN partiellement assuré par traduction machine runtime (MyMemory, réseau) | `index.html:19676-19717` | Promouvoir les chaînes récurrentes dans `I18N_DICT` (EN maîtrisé, hors-ligne). |
| P3 | partial | `alt` de la landing non traduits (translateTree ignore `alt`) | `index.html:4985,5018-5026` | Ajouter `alt` au dico / `data-i18n`. |
| P3 | missing | Pas de skip-link ni landmark `<main>` | grep=0 | Ajouter skip-link au focus + `<main>`. |
| P3 | works | **Base a11y solide** (focus, clavier, reduce-motion, labels champs, toast) | `index.html:731,80-137,2681,4652,19741` | Conserver. Réutiliser KBD_SEL/`_smSyncLabels`/`I18N_DICT`. |

## 6) Cohérence DA (sunset)
> Doctrine globalement respectée : statuts ambre/doré (pas de vert criard), rouge=danger, scrollbar thémée, surfaces nuit homogènes. Point faible : ~30 familles ambre figées en dur + epin (pins carte) en hex.

| Sév. | Statut | Constat | Preuve | Reco |
|---|---|---|---|---|
| P3 | works | Statuts validé/en-ligne en tons sunset | `index.html:767-775,965,2454` | RAS. |
| P3 | works | Rouge réservé au danger/SOS (`su-call`=dégradé sunset, pas rouge pur) | `index.html:1180-1181,449` | RAS. |
| P2 | partial | Scrollbar thémée mais ton défaut = taupe figé (pas `var(--accent)`) | `index.html:333-347` | `color-mix(... var(--accent) 45% ...)` pour suivre le preset. |
| **P1** | risk | **Ambre figé en dur sur ~30 familles** (ne suivra aucun autre preset) | `index.html:1491,666,1687,3622…` | Convertir en `var(--accent-grad)/--accent/--accent-soft`. Prioriser `.pcard-top/.vchip/.rate-top/.hud-bar`. |
| P2 | risk | Pins carte (epin) en hex ; hook `--epin` posé seulement par le loader (inerte) ; `window.SM_EPIN_COLOR` absent | `index.html:15571,16014…` | Implémenter `SM_EPIN_COLOR(cat,mode)` (teinte par catégorie dérivée du preset). |
| P2 | partial | Filtres carte par catégorie en hex (teal/violet/orange/ambre) | `index.html:1396-1399` | Acceptable (palette catégorielle assumée). Dériver via overrides si 100 % DA. |
| P3 | partial | Vert vif `#34c759` sur « Accepter » du faux appel (mimétisme iOS volontaire) | `index.html:1720-1721` | Tolérable. `var(--ok)` casserait l'illusion d'appel natif — arbitrer. |
| P3 | partial | Verts résiduels admin-only (point « live », réponse feedback) | `index.html:3566,2372-2373` | Faible priorité. Aligner sur `var(--ok)`. |
| P3 | works | `--ok` = vert sobre `#1E7A5A` (éco) assumé, conforme | `index.html:269` | RAS. |
| P3 | works | Surfaces nuit homogènes prune/violet via variables | `index.html:3257-3273` | RAS (textes ambre nuit = accents de titre volontaires). |

## 7) Système Beta / Lite (toggle data-beta + body.sm-lite)
> Câblé et fonctionnel **mais purement cosmétique** (masquage CSS, pas une séparation produit). **CRITIQUE pour la refonte.**

| Sév. | Statut | Constat | Preuve | Reco |
|---|---|---|---|---|
| P2 | works | Toggle : `localStorage sm_beta`, **défaut ON**, override `?lite=1` | `index.html:20098-20105,20136` | ⚠️ Défaut ON = le public voit le mode complet. Pour « public=lite », inverser le défaut ou détecter le statut beta côté Supabase. |
| **P1** | risk | Masquage 100 % CSS, **aucune garde JS** → les sections beta chargent quand même (Supabase) | `index.html:889,18293,13182,19851` | Gater le CHARGEMENT (`if(!betaOn())return;`) en plus du CSS. |
| P3 | works | **11 éléments `data-beta`** = la frontière (solo, vouch, boutique/SunCoins/cadres, feedback, quêtes groupe, lien lite) | `index.html:5266…6637` | `#shopFrames` redondant (parent déjà data-beta) → nettoyer. Confirmer le périmètre avec Maxime. |
| P3 | works | Les **5 piliers ne portent jamais data-beta** → Lite reste complète sur l'essentiel | `index.html:887-888,6647-6652` | Garder ce principe. Vérifier cohérence : coupons visibles mais boutique cachée ? |
| P2 | works | `sunmates-lite.css` masque AUSSI `.badge.secret/.easter/.retro-fx` (hors data-beta) + allège DA (anims/sheen/radius) | `lite.css:14-35` | Séparer « features lite » vs « DA calme ». Recenser `.badge.secret/.easter/.retro-fx` comme « caché en lite ». |
| **P1** | risk | Le bouton « version lite » ouvre **`sunmates-app.html` (Tailwind séparé)**, PAS index.html en sm-lite → **2 Lite divergentes** | `index.html:20137`, `sunmates-app.html:1-18` | **Décision produit avant refonte** : vanilla (CLAUDE.md) vs Tailwind. Les deux ne sont pas maintenables ensemble. |
| P2 | depends-migration | Défis/rituels solo (data-beta) dépendent de `solo_tasks ≥26` | `index.html:18152-18153,10621` | Moins critique (beta-only masqué). Vérifier migrations si promus hors beta. |
| P2 | risk | La **visite guidée pilote dans des sections beta** (cibles `display:none` en lite) | `index.html:11053-11117` | Gater ces étapes par `betaOn()` ou les retirer du parcours public. |

---

## Implications directes pour la refonte Lite (chantier E)
1. **Trancher la base Lite** (P1 #2) — recommandation audit : **`index.html` + `body.sm-lite` en vanilla** (stack imposée CLAUDE.md), abandonner `sunmates-app.html` comme base. ⟵ *décision Maxime requise.*
2. **Confirmer `sm_guard_privilege` en base** (P0) avant tout déploiement public.
3. **Gater le chargement** des sections beta (pas seulement le CSS).
4. **Tokens, pas de hex** : ne recoder aucune surface en dur ; texte sur fond clair → `--accent-ink`.
5. **Pré-cacher + pinner Supabase** pour un offline réel.
6. **Hériter de la base a11y** (KBD_SEL, `_smSyncLabels`, reduce-motion) et combler ✕/modales/zoom.
7. **Respecter le contrat anti-régression** (`TEST_TECHNIQUE_v529.md › Ne jamais casser`).
