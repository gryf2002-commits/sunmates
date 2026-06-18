# Exploration Stitch — « SunMates: Safe Solo Connections » (rapport agent)

> Inventaire issu d'une passe d'exploration du canvas Stitch. Observé, non inventé ;
> zones illisibles marquées. Hex de couleurs = estimations visuelles (le Panneau DA
> est resté partiellement masqué) → à confirmer dans une passe ciblée.
> ⚠️ Sécurité : aucune modif faite (screenshot/zoom/scroll/clics à vide uniquement).
> Des générations IA tournaient en autonomie côté chat (« Schéma de données Supabase »,
> « Concevoir le Hub de Jeux », « Les trois ») — non déclenchées par l'exploration.

## 1. Cadres / boards trouvés
**Console Admin (desktop sombre)**
1. Console Admin – Gestion : « Member Management », validation **Pending "Hôte" Requests**
   (Elena R. Paris Trust 92 / Marco V. Italy Trust 88 → Accept/Refuse), onglets Actifs/Suspendus.
2. Console Admin – Modération : « Gestion des signalements et conflits », **12 EN ATTENTE**,
   filtres Tous/Urgent/Traité, cartes signalement avec statuts EN ATTENTE/TRAITÉ.
3. Console Admin – Tableau de bord : KPI live (Actifs 1 248 · Alertes 3 · Inscrits 24h +42 ·
   Lieux 87), Stats globales (Membres 45,2k +12% · Vérifiés 18,5k +5% · Gold 2,1k +22%).

**Documents / specs**
4. Schéma Supabase v2026 : enums `user_status`, `connection_status('pending','accepted','rejected','blocked')`,
   `quest_status('available','joined','completed')`, `host_status('none','pending','approved','rejected')`,
   section Tables Core (profiles…), RLS mentionné.
5. Autres boards clairs (specs/versions) — illisibles (zoom bloqué).

**Écrans App (DA sunset/violet, compte = Max admin/HÔTE)**
6. Mon profil (×3 variantes). 7. Hub Jeux & Quêtes. 8. Besoin d'aide. 9. Sécurité.
10. Mes Mates. 11. Glassmorphic Profile (Elena Rodriguez, glass sur coucher de soleil).
12. Safety Center (Safety Check-in countdown, SOS, Share Live Location).
13. Panneau de contrôle DA in-app (tokens copiables + sélecteur de mode + onglet Sons/Bêta).

## 2. Couleurs (mode « Nuit Tropicale » à l'écran ; hex à confirmer)
- Fond violet profond→indigo (~#2A1A4A→#3D2566) ; cartes glass (~#3A2A55) à liseré subtil.
- Accent primaire dégradé **orange→corail/rouge** (~#FF8A3D→#FF4D6D) sur les CTA.
- Tokens nommés : **« Ambre »** (or, badges/Gold/validé), **« Corail pâle (chips) »**.
- Tuiles catégorielles (Hub) : Quêtes corail/orange · Jeux violet · Badges ambre/or ·
  Coupons bleu · Classement teal/cyan · Boutique magenta/rose.
- Sémantique : urgence = rouge (SOS/Alerte) ; info = liseré ambre ; trust = pastille corail-rouge.
- Modes : **Nuit Tropicale** (actuel), **Hiver Glaciaire ❄️** (proposé), + sélecteur multi-modes (cf. 6 modes projet).

## 3. Typo
- Titres d'écran : **serif display crème** centrée (signature DA). Logo serif + emblème soleil.
- Corps/labels/boutons : sans-serif ; sous-libellés en **petites capitales** (À PROXIMITÉ, VALIDÉS…).
- Stats en chiffres bold marqués.

## 4. Composants & états
- Header : statut iOS + logo + icône soleil (toggle thème) + cloche + pill Déconnexion.
- Carte profil glass : avatar+roue, « Max 👑 ✓ » badge **HÔTE** hexagonal, 📍Paris,
  pill **« ⬡ Confiance 190 ⓘ »**.
- Bloc stats 3 col (210 XP★ / 14 Mates / 8 Check-ins) ; variante (🔥8 ·🎯5 ·🏅22 ·★210).
- Barre « Profil complété à 100% 🎉 ». Pills rôle : Premium✨ / Espace Pro / Admin🛡.
- Boutons : primaire pleine largeur dégradé orange→corail ; secondaire/outline pill bordée.
- **Tuiles « joyau »** (signature) : carré arrondi, dégradé par catégorie, icône-joyau, titre+sous-titre caps.
- **Carte Spotlight « Quête du Jour »** : photo lieu en fond, badge NOUVEAU, méta ⬡+70 XP·Badge, pills Solo/À deux, CTA rouge.
- Listes progression : icône+titre+méta+chevron (Objectif semaine 2/3, Quête 1.1km, Collection 1/55, Ville à l'honneur).
- Carte premium **SunMates Gold** : couronne or, 9,99€/mois, « Bientôt disponible », CTA « 🔔 Me prévenir », lien « Aperçu mode Gratuit ».
- Bloc urgence : « Appeler le 112 » (orange) / « Alerte d'urgence » (rouge) / « Partager position (sans urgence) » (outline) + note info 📍24h vs ⚠️immédiat + liens contacts/cercle.
- **Bottom nav 5** : Explorer · Carte · Jeux · Mates · Profil.
- **Panneau DA** : onglets Livre blanc/Bord/Membres/Lieux/Signal./Devis/Bêta/Sons/**DA**/Données/Système ; pastilles couleur **cliquables = copier le hex**.

## 5. Micro-interactions / animations (guide affiché)
- Célébrations : starbursts, **pluies de confettis**, **barres d'XP animées**.
- **Identité sonore** : API **SMSound** pour chaque action clé (onglet Sons dans le Panneau DA).
- Easter eggs : trajectoires **avion en papier** + **effets saisonniers**.
- Hub : récompenses visuelles, finitions « joyaux », contrastes vibrants, Spotlight immersive, suivi de progression (rétention).

## 6. Écrans inédits / fonctionnalités fancy
- Hub Jeux complet (Quêtes/Jeux/Badges/Coupons/Classement/Boutique), modes Solo/À deux,
  Collection d'artefacts 1/55, Ville à l'honneur, objectifs hebdo.
- Boutique de cosmétiques. Panneau DA in-app (inspecteur tokens + modes + Sons + Bêta + Système).
- Glassmorphic Profile premium. Safety Center avec **Safety Check-in 01:45:30 remaining**.
- Sécurité : Faux appel, Signal d'aide, Partager position, Alerte, Rentrée en sécurité, Cercle/Mates partagés, Aide à proximité, Numéros d'urgence.
- Console Admin (membres + validation hôtes, modération, dashboard live).

## 7. Top 10 pépites à reprendre
1. Tuiles « joyau » colorées par catégorie. 2. Carte Spotlight Quête du Jour immersive.
3. Panneau de contrôle DA in-app (pastilles = copier hex + sélecteur de mode + Sons).
4. Titres serif crème sur violet (premium immédiat). 5. Pill « ⬡ Confiance » + badge HÔTE hexagonal.
6. Note info bicolore urgence (24h vs immédiat). 7. Safety Check-in à compte à rebours.
8. Célébrations animées + identité sonore par action. 9. Carte premium Gold sobre (sans monnayer la sécurité).
10. Modes thématiques (Nuit Tropicale / Hiver Glaciaire…) re-skinnant toute l'app.

## À finir (passe ciblée)
- Hex EXACTS du Panneau de contrôle DA (resté masqué). 
- Bas des cadres app (masqués par la barre de prompt). 
- Boards documents (cluster specs).
