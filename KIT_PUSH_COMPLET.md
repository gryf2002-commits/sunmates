# 🔔 KIT PUSH COMPLET — SunMates

Tu as **déjà** le push sur les **messages**. Ce kit ajoute les **demandes de connexion**
et les **matchs acceptés**, et propre la notif (logo soleil + vibration douce + ouverture
sur le bon onglet). Tout se fait dans le **dashboard Supabase**, ~5 minutes, zéro outil à installer.

> Ce que tu as déjà et qui ne bouge PAS : la table `push_subscriptions`, les secrets
> `VAPID_PUBLIC` / `VAPID_PRIVATE`, le webhook sur `messages`, « Verify JWT » désactivé.
> → Tu ne refais PAS tout ça. Tu fais juste **2 choses** : remplacer le code de la fonction
> (étape 1) et ajouter **2 webhooks** (étape 2).

---

## ✅ Étape 1 — Remplacer le code de la fonction `send-push`

Dashboard Supabase → **Edge Functions** → `send-push` → **remplace tout le code** par
celui ci-dessous → **Deploy**.

*(C'est le même fichier que `supabase/functions/send-push/index.ts` dans le repo.)*

```ts
// SunMates — Fonction Edge "send-push"
// Appelée par des Database Webhooks Supabase. Envoie une notification Web Push
// au BON destinataire selon la table qui a déclenché le webhook (même app fermée).
import webpush from "npm:web-push@3.6.7";
import { createClient } from "npm:@supabase/supabase-js@2";

const VAPID_PUBLIC = Deno.env.get("VAPID_PUBLIC")!;
const VAPID_PRIVATE = Deno.env.get("VAPID_PRIVATE")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

webpush.setVapidDetails("mailto:support@sunmates.app", VAPID_PUBLIC, VAPID_PRIVATE);
const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

// Pseudo d'un utilisateur (pour le titre/corps de la notif).
async function usernameOf(id: string | null | undefined): Promise<string> {
  if (!id) return "Un Mate";
  const { data } = await admin.from("profiles").select("username").eq("id", id).maybeSingle();
  return (data?.username as string) || "Un Mate";
}

type Built = { recipient: string; note: Record<string, unknown> } | null;

// Construit la notif selon la table + l'événement. Retourne null si rien à envoyer.
async function buildNote(payload: Record<string, any>): Promise<Built> {
  const type = payload.type || payload.eventType || "";
  const table = payload.table || "";
  const row = payload.record || payload.new || payload;
  const old = payload.old_record || payload.old || {};

  // 1) Nouveau message → on prévient le destinataire.
  if (table === "messages") {
    const recipient = row?.recipient_id;
    if (!recipient) return null;
    const name = await usernameOf(row?.sender_id);
    return { recipient, note: { title: "💬 " + name, body: (row?.content || "").toString().slice(0, 120), tab: "connexions", tag: "msg-" + row?.sender_id } };
  }

  // 2/3) Connexions (matches_connections : user_a = demandeur, user_b = destinataire).
  if (table === "matches_connections") {
    // Nouvelle demande (INSERT, status "pending") → on prévient user_b.
    if (type === "INSERT" && (row?.status === "pending" || !row?.status)) {
      const recipient = row?.user_b;
      if (!recipient) return null;
      const name = await usernameOf(row?.user_a);
      return { recipient, note: { title: "👋 Nouvelle demande", body: name + " veut se connecter avec toi", tab: "connexions", tag: "conn-" + (row?.id ?? recipient) } };
    }
    // Demande acceptée (UPDATE : pending → accepted) → on prévient le demandeur user_a.
    if (type === "UPDATE" && row?.status === "accepted" && old?.status !== "accepted") {
      const recipient = row?.user_a;
      if (!recipient) return null;
      const name = await usernameOf(row?.user_b);
      return { recipient, note: { title: "🤝 Nouveau match !", body: name + " a accepté ta demande de connexion", tab: "connexions", tag: "match-" + (row?.id ?? recipient) } };
    }
    return null;
  }

  return null;
}

Deno.serve(async (req) => {
  try {
    const payload = await req.json();
    const built = await buildNote(payload);
    if (!built) return new Response("nothing to send", { status: 200 });

    const { data: subs } = await admin.from("push_subscriptions").select("subscription,endpoint").eq("user_id", built.recipient);
    if (!subs || !subs.length) return new Response("no subscription", { status: 200 });

    const note = JSON.stringify({ url: "./", ...built.note });
    await Promise.all(subs.map(async (s) => {
      try {
        await webpush.sendNotification(s.subscription, note);
      } catch (err) {
        const code = (err as { statusCode?: number }).statusCode;
        if (code === 404 || code === 410) {
          await admin.from("push_subscriptions").delete().eq("endpoint", s.endpoint);
        }
      }
    }));
    return new Response("ok", { status: 200 });
  } catch (e) {
    return new Response("err: " + (e as Error).message, { status: 200 });
  }
});
```

---

## ✅ Étape 2 — Ajouter 2 webhooks

Dashboard → **Database** → **Webhooks** → **Create a new hook**. Pour chacun :
- **Type** : *Supabase Edge Functions* → choisir **`send-push`**
- **Method** : POST, en-têtes par défaut → **Create**

| # | Table | Events | Notifie |
|---|-------|--------|---------|
| (déjà fait) | `messages` | ☑️ Insert | Nouveau message |
| **A (nouveau)** | `matches_connections` | ☑️ **Insert** | Nouvelle demande de connexion → destinataire |
| **B (nouveau)** | `matches_connections` | ☑️ **Update** | Demande acceptée = match → demandeur |

> Tu gardes ton webhook `messages`. Tu ajoutes **A** et **B**.

---

## ✅ Étape 3 — Vérifier les secrets (normalement déjà là)
Edge Functions → `send-push` → **Secrets** : `VAPID_PUBLIC` et `VAPID_PRIVATE` doivent
être présents. Et **« Verify JWT » désactivé** dans les réglages de la fonction.

---

## 🎉 Étape 4 — Tester
Avec **2 comptes** (ton tél + un autre / un onglet privé), app **en ligne (HTTPS)** et
**notifications autorisées** :
1. Compte B **envoie une demande de connexion** à A → A reçoit « 👋 Nouvelle demande ».
2. A **accepte** → B reçoit « 🤝 Nouveau match ! ».
3. B **envoie un message** → A reçoit « 💬 … ».

Chaque notif a le **petit logo soleil** (plus de pavé gris), **vibre doucement**, et au clic
**ouvre directement l'onglet Connexions**.

---

## 🛠️ Dépannage
- **Rien ne s'affiche** : permission accordée ? une ligne dans `push_subscriptions` pour ce
  user ? les 2 secrets VAPID ? « Verify JWT » désactivé ? Regarde **Edge Functions →
  send-push → Logs** (tu verras `ok` / `no subscription` / `nothing to send`).
- **iPhone** : le push web marche **uniquement si la PWA est installée** sur l'écran d'accueil
  (iOS 16.4+). Pas dans Safari onglet.
- **« via Chrome » sous la notif** (Android) : normal si l'app n'est **pas installée** en PWA.
  Installe-la (« Ajouter à l'écran d'accueil ») → le logo SunMates remplace celui de Chrome.
- **Notif en double** : géré par le `tag` (une notif du même type remplace au lieu d'empiler).
