# 🔔 Activer les notifications push (même app fermée)

Le code est prêt. Il reste à brancher le « mini-serveur » côté Supabase.
Tout se fait dans le **dashboard Supabase** (aucun outil à installer).

> ⚠️ Ta clé **VAPID privée** ne doit JAMAIS être mise dans le code ni sur GitHub.
> Elle te sera donnée par Claude dans le chat — colle-la uniquement comme **secret**
> à l'étape 3.

---

## 1) Créer la table des abonnements
SQL Editor → New query → colle **`supabase_migration_session7.sql`** → **Run**.

## 2) Créer la fonction Edge `send-push`
Menu **Edge Functions** → **Create a new function** → nom exactement : `send-push`.
Colle tout le contenu de **`supabase/functions/send-push/index.ts`** → **Deploy**.

## 3) Définir les secrets de la fonction
Edge Functions → `send-push` → onglet **Secrets** (ou « Manage secrets ») → ajoute :
- `VAPID_PUBLIC` = `BDroKpS-uCezrK7igjxCD9Ih8a5OgPQ3AtOuza220aSx8CzR3LIw9EwkkObyHZVMI1wyT24_w48Ho7CUnAAPZ_0`
- `VAPID_PRIVATE` = *(la clé privée donnée par Claude dans le chat)*
- **`WEBHOOK_SECRET`** = *(une longue chaîne secrète que TU inventes, ex. 32+ caractères aléatoires)* — **OBLIGATOIRE**.

> 🔒 **Pourquoi `WEBHOOK_SECRET` ?** La version actuelle de `send-push` **refuse TOUT appel**
> qui n'apporte pas le bon en-tête `x-webhook-secret` (sécurité par défaut : sans ce secret,
> aucune notification ne part — c'est le cas aujourd'hui). Tu dois donc (a) poser ce secret ici,
> puis (b) le renvoyer dans CHAQUE webhook à l'étape 5. Garde-le privé (jamais dans le code/GitHub).

*(SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY sont déjà fournis automatiquement.)*

## 4) Désactiver « Verify JWT » pour cette fonction
Dans les réglages de la fonction `send-push`, **désactive « Verify JWT »**
(le webhook l'appelle sans jeton utilisateur).

## 5) Créer les Database Webhooks (déclencheurs)
La **même** fonction `send-push` gère plusieurs cas selon la table : crée **3 webhooks**
(Menu **Database** → **Webhooks** → **Create a new hook**). Pour chacun :
- **Type** : *Supabase Edge Functions* → choisir **`send-push`**
  *(ou HTTP Request POST vers `https://ihiwuharxkmkzaxixhae.functions.supabase.co/send-push`)*
- **Method** : POST.
- **⚠️ HTTP Headers** : ajoute un en-tête **`x-webhook-secret`** = *(la MÊME valeur que `WEBHOOK_SECRET` de l'étape 3)*.
  Sans cet en-tête, la fonction répond **401** et **aucune notif ne part**. → **Create**.

| # | Table | Events | Ce que ça notifie |
|---|-------|--------|-------------------|
| 1 | `messages` | ☑️ Insert | Nouveau message reçu |
| 2 | `matches_connections` | ☑️ Insert | Nouvelle demande de connexion (→ destinataire) |
| 3 | `matches_connections` | ☑️ Update | Demande **acceptée** = nouveau match (→ demandeur) |

> ⚠️ Si tu avais DÉJÀ créé le webhook `messages`, garde-le. Ajoute juste les **2 nouveaux**
> sur `matches_connections` (un Insert, un Update). Et **re-déploie** la fonction `send-push`
> (étape 2) car son code a été mis à jour pour gérer ces nouveaux cas.

## 6) Tester 🎉
1. Ouvre l'app **en ligne** (HTTPS) et **autorise les notifications** quand le navigateur demande.
2. Sur Android/desktop : installe la PWA (« Ajouter à l'écran d'accueil ») pour le mode app fermée.
   *(Sur iPhone, le push web ne marche QUE si l'app est installée sur l'écran d'accueil, iOS 16.4+.)*
3. Depuis un **autre compte** : envoie-toi un message **OU** une demande de connexion, puis
   **accepte une demande** → tu dois recevoir une notification **même app fermée**, avec un
   petit logo soleil net (plus de pavé gris) qui ouvre directement l'onglet **Connexions**.

---

### Dépannage
- Rien ne s'affiche ? Vérifie : permission accordée, une ligne dans `push_subscriptions`,
  les 2 secrets VAPID **+ `WEBHOOK_SECRET`**, « Verify JWT » désactivé, et les **logs** de la fonction
  (Edge Functions → send-push → Logs).
- **Logs « 401 » / « unauthorized »** = l'en-tête `x-webhook-secret` du webhook ne correspond pas
  (ou est absent) à la valeur du secret `WEBHOOK_SECRET`. Corrige l'en-tête dans les 3 webhooks (étape 5).
- État actuel constaté (21/06) : les appareils s'abonnent bien (lignes présentes dans `push_subscriptions`),
  donc le SEUL chaînon manquant est la paire `WEBHOOK_SECRET` (secret) + en-tête `x-webhook-secret` (webhooks).
- iPhone : il faut **installer** la PWA (écran d'accueil) ; le push ne marche pas dans Safari onglet.
