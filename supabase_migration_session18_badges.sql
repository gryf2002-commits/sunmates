-- ============================================================
-- SunMates — Session 18 : CATALOGUE DE BADGES (publics + SECRETS)
-- Badges non débloqués affichés grisés ; badges secrets = fonction définie
-- mais condition cachée au public (seul l'admin voit la condition d'obtention).
-- À lancer dans le SQL Editor de Supabase. Rejouable (idempotent).
-- ============================================================

create table if not exists badges_catalog (
  key              text primary key,
  name             text,
  emoji            text,
  description      text,                 -- ce qu'il représente / comment l'obtenir (public si non secret)
  is_secret        boolean default false,
  secret_hint      text,                 -- indice flou montré au public pour un badge secret (optionnel)
  unlock_condition text,                 -- condition EXACTE (réservée à l'admin)
  sort_order       int default 0
);
alter table badges_catalog enable row level security;
drop policy if exists "Catalogue badges visible" on badges_catalog;
create policy "Catalogue badges visible" on badges_catalog for select to authenticated using (true);

-- 1) Badges PUBLICS : dérivés des quêtes existantes (badge_key)
insert into badges_catalog (key, name, emoji, description, is_secret, sort_order)
select distinct on (badge_key)
  badge_key, badge_name, badge_emoji,
  'Accomplis la quête « ' || title || ' » pour le débloquer.', false, sort_order
from quests
where badge_key is not null
order by badge_key, sort_order
on conflict (key) do update set
  name = excluded.name, emoji = excluded.emoji,
  description = excluded.description, sort_order = excluded.sort_order;

-- 2) Badges SECRETS : fonction définie, condition CACHÉE au public (admin uniquement)
insert into badges_catalog (key, name, emoji, description, is_secret, secret_hint, unlock_condition, sort_order) values
  ('badge_nightowl','Oiseau de nuit','🦉','Pour les couche-tard de SunMates.', true, 'Certaines choses se révèlent à des heures… inhabituelles. 🌙', 'Ouvrir l''app entre 2h et 5h du matin', 50),
  ('badge_globetrotter','Globe-trotter','🌍','Le badge des grands voyageurs.', true, 'Voyage, voyage… 🌍', 'Faire un check-in dans au moins 5 villes différentes', 51),
  ('badge_butterfly','Papillon social','🦋','Pour les âmes ultra-connectées.', true, 'Tout est dans les liens que tu tisses. 🤝', 'Avoir 10 Mates de confiance acceptés', 52),
  ('badge_legend','Légende SunMates','👑','Le cercle très fermé des membres d''élite.', true, '✨ ???', 'Atteindre 500 XP', 53),
  ('badge_guardian','Ange gardien','🛡️','Pour ceux qui veillent sur les autres.', true, 'La sécurité avant tout. 🛡️', 'Faire partie du cercle de confiance de 3 voyageurs', 54)
on conflict (key) do update set
  name = excluded.name, emoji = excluded.emoji, description = excluded.description,
  is_secret = excluded.is_secret, secret_hint = excluded.secret_hint,
  unlock_condition = excluded.unlock_condition, sort_order = excluded.sort_order;

-- Fin session 18.
