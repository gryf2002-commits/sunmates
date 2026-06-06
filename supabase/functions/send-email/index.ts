// ============================================================
// SunMates — Edge Function "send-email" (Resend)
// ============================================================
// Envoie un email transactionnel via Resend (ex : confirmation d'email,
// vérification d'identité, notification). À déployer sur Supabase.
//
// MISE EN PLACE (voir RESEND_SETUP.md à la racine) :
//   1. Crée un compte sur https://resend.com et un domaine vérifié.
//   2. Dans Supabase > Edge Functions > Secrets :
//        RESEND_API_KEY = re_xxx
//        EMAIL_FROM     = "SunMates <hello@ton-domaine.com>"
//   3. Déploie :  supabase functions deploy send-email
//
// APPEL DEPUIS LE FRONT (utilisateur connecté) :
//   const { data, error } = await db.functions.invoke("send-email", {
//     body: { to, subject, html }
//   });
// ------------------------------------------------------------

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const EMAIL_FROM = Deno.env.get("EMAIL_FROM") ?? "SunMates <onboarding@resend.dev>";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    if (!RESEND_API_KEY) {
      return json({ ok: false, error: "RESEND_API_KEY manquant (configure les secrets)." }, 500);
    }
    const { to, subject, html, text } = await req.json();
    if (!to || !subject || (!html && !text)) {
      return json({ ok: false, error: "Champs requis : to, subject, html|text." }, 400);
    }
    const r = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ from: EMAIL_FROM, to, subject, html, text }),
    });
    const data = await r.json();
    if (!r.ok) return json({ ok: false, error: data?.message || "Échec d'envoi." }, 502);
    return json({ ok: true, id: data?.id });
  } catch (e) {
    return json({ ok: false, error: String(e?.message || e) }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
