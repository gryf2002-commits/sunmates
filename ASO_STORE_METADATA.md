# ASO — métadonnées prêtes pour les stores (Play Store / App Store)

> Brouillon prêt à coller le jour d'une soumission store. La PWA SunMates peut partir
> sur **Google Play via une TWA** (Trusted Web Activity, qui lit `manifest.json`) et sur
> **iOS via Capacitor** si besoin. Rien n'est soumis automatiquement : ce fichier est une base.
> Domaine de prod : **sunmatesapp.com**. Ton de marque : chaleureux, joueur, rassurant (jamais anxiogène).

---

## 🇫🇷 Français

**Titre (30 car. max — Play)**
`SunMates : voyager solo`

**Sous-titre / Promo (App Store 30 car.)**
`Pars solo, trouve ta bande`

**Description courte (80 car. — Play)**
`Rencontre des voyageurs autour de toi, lance des quêtes, pars l'esprit tranquille.`

**Mots-clés (App Store, 100 car. séparés par virgule)**
`voyage solo,voyageurs,rencontre voyage,backpack,quêtes,carte,sécurité,communauté,nomade,amis`

**Description longue (Play / App Store)**
```
Voyager solo ne veut pas dire voyager seul·e.

SunMates est l'app sociale « sécurité d'abord » des voyageurs solo. Une carte vivante
te montre les lieux qui valent le détour et les voyageurs comme toi autour de toi.
Un message, un café, une virée, et tu repars avec une bande.

☀️ EXPLORE
Repère en temps réel les voyageurs et les lieux sûrs près de toi, partout dans le monde.

🤝 CONNECTE
Trouve des gens qui vibrent comme toi, discute, et transforme une rencontre de voyage
en souvenirs partagés.

🎮 JOUE
Relève des quêtes, gagne de l'XP, débloque des badges et des coupons chez des spots
locaux, et grimpe au classement avec ta bande.

🛟 EN SÉCURITÉ, TOUJOURS
Profils vérifiés, partage de position à ton cercle de confiance, bouton SOS.
La sécurité est gratuite pour tous, et elle le restera toujours.

Pars solo, trouve ta bande. ☀️
```

---

## 🇬🇧 English

**Title (30 chars max — Play)**
`SunMates: solo travel, together`

**Subtitle / Promo (App Store 30 chars)**
`Travel solo, find your crew`

**Short description (80 chars — Play)**
`Meet travellers around you, take on quests, travel with peace of mind.`

**Keywords (App Store, 100 chars comma-separated)**
`solo travel,travelers,meet travel,backpacking,quests,map,safety,community,nomad,friends`

**Long description (Play / App Store)**
```
Travelling solo doesn't mean travelling alone.

SunMates is the safety-first social app for solo travellers. A living map shows you the
places worth the detour and the travellers like you nearby. A message, a coffee, an
outing, and you leave with a crew.

☀️ EXPLORE
Spot travellers and safe places near you in real time, anywhere in the world.

🤝 CONNECT
Find people who vibe like you, chat, and turn a travel encounter into shared memories.

🎮 PLAY
Take on quests, earn XP, unlock badges and coupons at local spots, and climb the
leaderboard with your crew.

🛟 SAFE, ALWAYS
Verified profiles, location sharing with your trusted circle, SOS button.
Safety is free for everyone, and always will be.

Travel solo, find your crew. ☀️
```

---

## Assets store (à préparer le moment venu)
- **Icône** : `icon-512.png` (512×512) + `icon-maskable-512.png` (adaptive Android). ✓ présents.
- **Captures (déclarées dans `manifest.json` → `screenshots`)** : `shot_accueil.jpg`, `shot_jeux.jpg`,
  `shot_profil.jpg` (780×1688, format « narrow »). Pour les stores, prévoir aussi des captures
  cadrées « marketing » (texte + device frame) en 1080×1920 ou 1284×2778 (iPhone 6.7").
- **Feature graphic Play** : 1024×500 (à créer).
- **Catégories** : Social / Voyage / Lifestyle (déjà dans le manifest).

## Notes techniques
- **Play Store (TWA)** : Bubblewrap lit `manifest.json` (name, icons, theme_color, screenshots, id) →
  l'enrichissement manifest fait ici (id + screenshots) est exactement ce que Bubblewrap exige.
- **Vérification d'identité** : aujourd'hui simulée (MVP). Les stores demandent une politique de
  confidentialité publique (voir P1 de l'audit) + déclaration de collecte de données (géoloc).
- **SEO web** : `index.html` contient désormais meta description, Open Graph, Twitter Card et
  JSON-LD (SoftwareApplication). `robots.txt` + `sitemap.xml` à la racine. La landing pré-connexion
  est dans le HTML statique (titres sémantiques h1/h2), donc indexable.
