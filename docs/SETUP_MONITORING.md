# SunMates — Monitoring & analytics (gratuit)

Deux outils, deux comptes à créer (5 min chacun), deux snippets à coller dans le `<head>`
de `index.html`. Tu peux demander à Claude Code de les intégrer une fois tes clés obtenues.

## 1. Sentry — les erreurs de tes vrais utilisateurs

1. Crée un compte gratuit sur **sentry.io** → New Project → plateforme **JavaScript (Browser)**.
2. Récupère le **DSN** (une URL fournie à la création).
3. Colle dans le `<head>` (avant les autres scripts) :

```html
<script src="https://browser.sentry-cdn.com/8.0.0/bundle.min.js" crossorigin="anonymous"></script>
<script>
  Sentry.init({
    dsn: "TON_DSN_ICI",
    release: "sunmates@1.0.0",        // incrémente à chaque déploiement
    sampleRate: 1.0,
    beforeSend(event) {                // on n'envoie jamais de données perso
      if (event.user) delete event.user.email;
      return event;
    }
  });
</script>
```
→ Résultat : chaque bug JS chez un utilisateur apparaît dans ton dashboard avec la ligne exacte.

## 2. PostHog — comprendre l'usage (RGPD-friendly)

1. Compte gratuit sur **posthog.com** → choisis le **cloud EU** (eu.posthog.com, données en Europe).
2. Récupère ta **clé projet** (`phc_…`).
3. Colle dans le `<head>` :

```html
<script>
  !function(t,e){var o,n,p,r;e.__SV||(window.posthog=e,e._i=[],e.init=function(i,s,a){function g(t,e){var o=e.split(".");2==o.length&&(t=t[o[0]],e=o[1]),t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}}(p=t.createElement("script")).type="text/javascript",p.async=!0,p.src=s.api_host+"/static/array.js",(r=t.getElementsByTagName("script")[0]).parentNode.insertBefore(p,r);var u=e;for(void 0!==a?u=e[a]=[]:a="posthog",u.people=u.people||[],u.toString=function(t){var e="posthog";return"posthog"!==a&&(e+="."+a),t||(e+=" (stub)"),e},u.people.toString=function(){return u.toString(1)+".people (stub)"},o="init capture identify alias people.set people.set_once set_config register register_once unregister opt_out_capturing has_opted_out_capturing opt_in_capturing reset".split(" "),n=0;n<o.length;n++)g(u,o[n]);e._i.push([i,s,a])},e.__SV=1)}(document,window.posthog||[]);
  posthog.init("TA_CLE_phc_ICI", {
    api_host: "https://eu.posthog.com",
    autocapture: true,
    mask_all_text: true,          // ne capture pas le contenu des champs (vie privée)
    persistence: "localStorage"
  });
</script>
```

### Événements à tracer (à faire poser par Claude Code aux bons endroits)
```js
posthog.capture("signup");                 // après inscription
posthog.capture("profile_completed");      // complétion 100 %
posthog.capture("connection_sent");        // demande envoyée
posthog.capture("match");                  // connexion mutuelle
posthog.capture("message_sent");
posthog.capture("checkin");
posthog.capture("quest_completed", { kind: "quete" });
posthog.capture("coupon_claimed");
posthog.capture("pwa_installed");
```
⚠️ Ne JAMAIS tracer le contenu des messages, les positions GPS ni l'usage du SOS
(données sensibles). On compte des événements, pas des contenus.

### RGPD (sérieux mais simple)
- Cloud **EU** ✅ + `mask_all_text` ✅ + pas d'e-mail dans les events ✅.
- Ajoute une ligne dans ta future politique de confidentialité (« mesure d'audience anonymisée »).
- Idéal : un petit toggle « statistiques anonymes » dans les réglages (opt-out → `posthog.opt_out_capturing()`).

## 3. Lighthouse — la note qualité (déjà dans Chrome)
DevTools (F12) → onglet **Lighthouse** → Mobile → Analyze. Vise ≥ 90 en Performance/PWA/Accessibilité.
À lancer après chaque gros chantier — c'est aussi lui qui conditionnera le Play Store plus tard.
