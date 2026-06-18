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

*(SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY sont déjà fournis automatiquement.)*

## 4) Désactiver « Verify JWT » pour cette fonction
Dans les réglages de la fonction `send-push`, **désactive « Verify JWT »**
(le webhook l'appelle sans jeton utilisateur).

## 5) Créer les Database Webhooks (déclencheurs)
La **même** fonction `send-push` gère plusieurs cas selon la table : crée **3 webhooks**
(Menu **Database** → **Webhooks** → **Create a new hook**). Pour chacun :
- **Type** : *Supabase Edge Functions* → choisir **`send-push`**
  *(ou HTTP Request POST vers `https://ihiwuharxkmkzaxixhae.functions.supabase.co/send-push`)*
- **Method** : POST, en-têtes par défaut → **Create**.

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
  les 2 secrets VAPID, « Verify JWT » désactivé, et les **logs** de la fonction
  (Edge Functions → send-push → Logs).
- iPhone : il faut **installer** la PWA (écran d'accueil) ; le push ne marche pas dans Safari onglet.
