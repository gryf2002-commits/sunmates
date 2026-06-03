// SunMates — Fonction Edge "send-push"
// Appelée par un Database Webhook à CHAQUE nouveau message inséré.
// Elle envoie une notification Web Push au destinataire (même app fermée).
//
// Secrets à définir (Dashboard > Edge Functions > send-push > Secrets) :
//   VAPID_PUBLIC, VAPID_PRIVATE
// (SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY sont fournis automatiquement.)
//
// IMPORTANT : désactive "Verify JWT" pour cette fonction (le webhook l'appelle
// sans jeton utilisateur).

import webpush from "npm:web-push@3.6.7";
import { createClient } from "npm:@supabase/supabase-js@2";

const VAPID_PUBLIC = Deno.env.get("VAPID_PUBLIC")!;
const VAPID_PRIVATE = Deno.env.get("VAPID_PRIVATE")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

webpush.setVapidDetails("mailto:support@sunmates.app", VAPID_PUBLIC, VAPID_PRIVATE);
const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

Deno.serve(async (req) => {
  try {
    const payload = await req.json();
    // Format d'un Database Webhook Supabase : { type, table, record, ... }
    const row = payload.record || payload.new || payload;
    const recipient = row?.recipient_id;
    const senderId = row?.sender_id;
    const content = (row?.content || "").toString();
    if (!recipient) return new Response("no recipient", { status: 200 });

    // Nom de l'expéditeur (pour le titre de la notif)
    let senderName = "Un Mate";
    const { data: prof } = await admin.from("profiles").select("username").eq("id", senderId).maybeSingle();
    if (prof?.username) senderName = prof.username;

    // Abonnements push du destinataire (tous ses appareils)
    const { data: subs } = await admin.from("push_subscriptions").select("subscription,endpoint").eq("user_id", recipient);
    if (!subs || !subs.length) return new Response("no subscription", { status: 200 });

    const note = JSON.stringify({
      title: "💬 " + senderName,
      body: content.slice(0, 120),
      url: "./",
      tag: "msg-" + senderId,
    });

    await Promise.all(subs.map(async (s) => {
      try {
        await webpush.sendNotification(s.subscription, note);
      } catch (err) {
        // 404/410 = abonnement expiré → on le supprime
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
