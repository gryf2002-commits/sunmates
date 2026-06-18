# 📧 Emails SunMates — mise en place (Resend + Supabase)

Ce guide couvre deux besoins :

1. **Confirmation d'email à l'inscription** (1ʳᵉ vérification d'identité) → **gratuit, sans code**, via Supabase Auth.
2. **Emails personnalisés** (changement d'email, notifications, branding) → via **Resend** + une Edge Function.

---

## 1) Confirmation d'email à l'inscription (le plus important, sans code)

C'est **déjà géré par Supabase Auth**, il suffit de l'activer :

1. Supabase → **Authentication** → **Providers** → **Email**.
2. Active **« Confirm email »** (Confirmer l'email).
3. (Optionnel) **Authentication → Email Templates** : personnalise le mail de confirmation aux couleurs SunMates.

Résultat : à l'inscription, l'utilisateur reçoit un lien de confirmation. Tant qu'il ne clique pas, son email n'est pas vérifié → première barrière anti-faux-compte, **sans Resend ni code**.

> ⚠️ Le mail par défaut de Supabase a un quota limité. Pour de vrais volumes, branche un **SMTP custom** (Resend propose un SMTP) dans **Authentication → SMTP Settings**.

---

## 2) Emails personnalisés via Resend (Edge Function)

Pour envoyer des emails **sur mesure** depuis l'app (ex : « confirme ton nouvel email », « ton compte a été vérifié »).

### a. Compte Resend
1. Crée un compte sur **https://resend.com**.
2. **Vérifie un domaine** (ex : `sunmates.app`) — ou utilise `onboarding@resend.dev` pour tester.
3. Crée une **API Key** (`re_…`).

### b. Secrets Supabase
Dans **Supabase → Edge Functions → Secrets** (ou `supabase secrets set`) :
```
RESEND_API_KEY = re_xxxxxxxxxxxx
EMAIL_FROM     = SunMates <hello@ton-domaine.com>
```

### c. Déploiement de la fonction
La fonction est dans `supabase/functions/send-email/`.
```bash
supabase functions deploy send-email
```

### d. Appel depuis le front (`index.html`)
L'utilisateur doit être **connecté** (la fonction reçoit son JWT automatiquement) :
```js
const { data, error } = await db.functions.invoke("send-email", {
  body: {
    to: "destinataire@email.com",
    subject: "Bienvenue sur SunMates ☀️",
    html: "<h1>Salut !</h1><p>Confirme ton email pour débloquer ton compte.</p>"
  }
});
if (data?.ok) toast("📧", "Email envoyé !");
```

> 🔒 **Sécurité** : la fonction n'envoie qu'avec ta clé serveur (jamais exposée au client). Pense à valider/limiter côté fonction qui peut envoyer quoi (anti-spam) avant un usage en production.

---

## Récap
| Besoin | Solution | Code ? |
|---|---|---|
| Vérifier l'email à l'inscription | Supabase Auth « Confirm email » | ❌ non |
| Gros volumes de mails Auth | SMTP custom (Resend) | ❌ config |
| Emails sur mesure depuis l'app | Edge Function `send-email` + Resend | ✅ déployer |
