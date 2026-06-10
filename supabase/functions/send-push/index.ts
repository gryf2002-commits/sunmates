// SunMates — Fonction Edge "send-push"
// Appelée par des Database Webhooks Supabase. Envoie une notification Web Push
// au BON destinataire selon la table qui a déclenché le webhook (même app fermée).
//
// 3 webhooks à brancher sur CETTE MÊME fonction (cf. PUSH_SETUP.md) :
//   1) INSERT sur `messages`            → notifie le destinataire d'un nouveau message
//   2) INSERT sur `matches_connections` → notifie une nouvelle demande de connexion (user_b)
//   3) UPDATE sur `matches_connections` → notifie un match quand status passe à "accepted" (user_a)
//
// Secrets à définir (Dashboard > Edge Functions > send-push > Secrets) :
//   VAPID_PUBLIC, VAPID_PRIVATE, WEBHOOK_SECRET
// (SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY sont fournis automatiquement.)
//
// IMPORTANT : désactive "Verify JWT" pour cette fonction (les webhooks l'appellent
// sans jeton utilisateur).
//
// 🔐 SÉCURITÉ (audit 10/06/2026) : comme "Verify JWT" est désactivé, N'IMPORTE QUI
// pouvait appeler cette URL avec un faux payload et pousser des notifications
// arbitraires à n'importe quel utilisateur. La fonction exige désormais un secret
// partagé : chaque webhook doit envoyer le header  x-webhook-secret: <WEBHOOK_SECRET>.
//   1. Génère un secret (longue chaîne aléatoire), ajoute-le dans les Secrets de la
//      fonction sous le nom WEBHOOK_SECRET.
//   2. Dans Database > Webhooks, édite les 3 webhooks → HTTP Headers →
//      ajoute  x-webhook-secret = <le même secret>.
//   3. Redéploie :  supabase functions deploy send-push --no-verify-jwt

import webpush from "npm:web-push@3.6.7";
import { createClient } from "npm:@supabase/supabase-js@2";

const VAPID_PUBLIC = Deno.env.get("VAPID_PUBLIC")!;
const VAPID_PRIVATE = Deno.env.get("VAPID_PRIVATE")!;
const WEBHOOK_SECRET = Deno.env.get("WEBHOOK_SECRET") ?? "";
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
    return {
      recipient,
      note: {
        title: "💬 " + name,
        body: (row?.content || "").toString().slice(0, 120),
        tab: "connexions",
        tag: "msg-" + row?.sender_id,
      },
    };
  }

  // 2/3) Connexions (table matches_connections : user_a = demandeur, user_b = destinataire).
  if (table === "matches_connections") {
    // Nouvelle demande (INSERT, status "pending") → on prévient user_b.
    if (type === "INSERT" && (row?.status === "pending" || !row?.status)) {
      const recipient = row?.user_b;
      if (!recipient) return null;
      const name = await usernameOf(row?.user_a);
      return {
        recipient,
        note: {
          title: "👋 Nouvelle demande",
          body: name + " veut se connecter avec toi",
          tab: "connexions",
          tag: "conn-" + (row?.id ?? recipient),
        },
      };
    }
    // Demande acceptée (UPDATE : pending → accepted) → on prévient le demandeur user_a.
    if (type === "UPDATE" && row?.status === "accepted" && old?.status !== "accepted") {
      const recipient = row?.user_a;
      if (!recipient) return null;
      const name = await usernameOf(row?.user_b);
      return {
        recipient,
        note: {
          title: "🤝 Nouveau match !",
          body: name + " a accepté ta demande de connexion",
          tab: "connexions",
          tag: "match-" + (row?.id ?? recipient),
        },
      };
    }
    return null;
  }

  return null;
}

Deno.serve(async (req) => {
  // Anti-usurpation : seuls les webhooks Supabase (porteurs du secret) sont acceptés.
  // Si WEBHOOK_SECRET n'est pas configuré, on refuse TOUT (sécurité par défaut).
  if (!WEBHOOK_SECRET || req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("forbidden", { status: 403 });
  }
  try {
    const payload = await req.json();
    const built = await buildNote(payload);
    if (!built) return new Response("nothing to send", { status: 200 });

    // Abonnements push du destinataire (tous ses appareils).
    const { data: subs } = await admin
      .from("push_subscriptions")
      .select("subscription,endpoint")
      .eq("user_id", built.recipient);
    if (!subs || !subs.length) return new Response("no subscription", { status: 200 });

    const note = JSON.stringify({ url: "./", ...built.note });

    await Promise.all(subs.map(async (s) => {
      try {
        await webpush.sendNotification(s.subscription, note);
      } catch (err) {
        // 404/410 = abonnement expiré → on le supprime.
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
