-- ============================================================
-- SunMates — Session 22 : PLUS DE BADGES (jalons publics)
-- Ajoute des badges « accomplissements » débloqués automatiquement (côté app)
-- quand des conditions simples et réelles sont atteintes. Le front les attribue
-- via user_badges (RLS : chacun gère les siens).
-- À lancer dans le SQL Editor de Supabase. Rejouable (idempotent).
-- ============================================================

insert into badges_catalog (key, name, emoji, description, is_secret, sort_order) values
  ('badge_profile100','Profil au top','🌟','Compléter son profil à 100 %.', false, 20),
  ('badge_firstcheckin','Premier pas','📍','Valider son tout premier check-in.', false, 21),
  ('badge_explorer5','Routard confirmé','🧭','Faire 5 check-ins dans des lieux sûrs.', false, 22),
  ('badge_reviewer','Critique avisé','✍️','Laisser son premier avis sur un lieu.', false, 23),
  ('badge_verified','Compte vérifié','✅','Faire vérifier son compte.', false, 24),
  ('badge_questmaster','Aventurier','🗺️','Accomplir 5 quêtes.', false, 25),
  ('badge_guardian_helper','Veilleur','🛟','Partager sa position avec son cercle de confiance.', false, 26),
  ('badge_polyglot','Polyglotte','🗣️','Renseigner au moins 3 langues parlées.', false, 27)
on conflict (key) do update set
  name = excluded.name, emoji = excluded.emoji, description = excluded.description,
  is_secret = excluded.is_secret, sort_order = excluded.sort_order;

-- Fin session 22.
