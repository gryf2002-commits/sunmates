-- ============================================================
-- SunMates — Session 26 : QUÊTES PARIS (lancement « jeu de ville »)
-- ============================================================
-- Ajoute 10 quêtes géolocalisées sur Paris (le « plateau de jeu » de la carte
-- d'accueil) + des colonnes lat/lng à la table quests pour les placer sur la carte.
--
-- ⚠️ Pas de partenariats B2B pour l'instant : ces quêtes sont PUREMENT LUDIQUES
--    (aucun coupon partenaire). Elles rapportent de l'XP + un badge.
--
-- Rejouable : à exécuter dans le SQL Editor de Supabase (on conflict do update).
-- ============================================================

-- 1) Colonnes de géolocalisation des quêtes (pour les marqueurs de la carte)
alter table quests add column if not exists lat double precision;
alter table quests add column if not exists lng double precision;

-- 2) Seed des 10 quêtes Paris (kind='quest', sans coupon, avec position)
insert into quests
  (key, kind, title, emoji, city, description, participants, rating, requires_code,
   badge_key, badge_name, badge_emoji, points, sort_order, lat, lng)
values
  ('quest_paris_eiffel','quest','Photographie la Tour Eiffel','🗼','Paris, France',
   'Rends-toi au pied de la Dame de Fer, capture ton plus beau cliché et partage-le. Encore plus fun avec un Mate !',
   '3 200','9.8', false, 'badge_photographer','Photographe','📷', 120, 101, 48.8584, 2.2945),

  ('quest_paris_montmartre','quest','Montmartre, quartier des artistes','🎨','Paris, France',
   'Monte jusqu''au Sacré-Cœur, flâne dans les ruelles et déniche une œuvre de street-art.',
   '2 140','9.6', false, 'badge_culture','Culture','🎨', 90, 102, 48.8867, 2.3431),

  ('quest_paris_notredame','quest','Notre-Dame de Paris','⛪','Paris, France',
   'Photographie la cathédrale et balade-toi sur l''île de la Cité, cœur historique de Paris.',
   '2 780','9.5', false, 'badge_photographer','Photographe','📷', 100, 103, 48.8530, 2.3499),

  ('quest_paris_louvre','quest','Pyramide du Louvre','🖼️','Paris, France',
   'Trouve la pyramide de verre, prends la pose et découvre la plus grande galerie du monde.',
   '1 960','9.4', false, 'badge_culture','Culture','🎨', 90, 104, 48.8606, 2.3376),

  ('quest_paris_seine','quest','Au fil de la Seine','⛵','Paris, France',
   'Traverse le Pont des Arts et longe les quais : trouve un pont mythique et admire la vue.',
   '1 540','9.3', false, 'badge_explorer','Explorateur','🧭', 90, 105, 48.8585, 2.3373),

  ('quest_paris_marais','quest','Café dans le Marais','☕','Paris, France',
   'Donne rendez-vous à un Mate dans un café du Marais et savoure une pause conviviale et sûre.',
   '1 220','9.4', false, 'badge_local','Ami local','🤝', 110, 106, 48.8590, 2.3580),

  ('quest_paris_latin','quest','Trésor du Quartier latin','📚','Paris, France',
   'Pousse la porte de la librairie Shakespeare & Company et repars avec une pépite littéraire.',
   '980','9.2', false, 'badge_questmaster','Aventurier','🗺️', 70, 107, 48.8525, 2.3470),

  ('quest_paris_canal','quest','Rencontre au Canal Saint-Martin','🗣️','Paris, France',
   'Au bord de l''eau, engage la conversation avec un·e inconnu·e et demande son meilleur spot parisien.',
   '1 410','9.5', false, 'badge_polyglot','Polyglotte','🗣️', 100, 108, 48.8709, 2.3674),

  ('quest_paris_luxembourg','quest','Pause au jardin du Luxembourg','🌳','Paris, France',
   'Détends-toi sur une chaise iconique, observe la vie parisienne et respire un grand coup.',
   '1 060','9.3', false, 'badge_explorer','Explorateur','🧭', 80, 109, 48.8462, 2.3372),

  ('quest_paris_arc','quest','Cap sur l''Arc de Triomphe','🏛️','Paris, France',
   'Remonte la plus belle avenue du monde, les Champs-Élysées, jusqu''à l''Arc de Triomphe.',
   '1 720','9.4', false, 'badge_questmaster','Aventurier','🗺️', 60, 110, 48.8738, 2.2950)
on conflict (key) do update set
  kind=excluded.kind, title=excluded.title, emoji=excluded.emoji, city=excluded.city,
  description=excluded.description, participants=excluded.participants, rating=excluded.rating,
  requires_code=excluded.requires_code, badge_key=excluded.badge_key, badge_name=excluded.badge_name,
  badge_emoji=excluded.badge_emoji, points=excluded.points, sort_order=excluded.sort_order,
  lat=excluded.lat, lng=excluded.lng;

-- ============================================================
-- Fin. Les quêtes Paris apparaissent dans l'onglet Jeux ET sur la carte d'accueil
-- (couche « 🎯 Quêtes »). Les compléter rapporte l'XP indiqué + le badge associé.
-- ============================================================
