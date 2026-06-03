-- ============================================================
--  SunMates — SESSION 5 : carte, édition/suppression messages, blocage
--  À coller dans Supabase : SQL Editor > New query > Run. Idempotent.
-- ============================================================

-- 1) Coordonnées des lieux sûrs (pour la carte interactive)
alter table partner_cafes add column if not exists lat double precision;
alter table partner_cafes add column if not exists lng double precision;

update partner_cafes set lat = c.lat, lng = c.lng
from (values
  ('Le Comptoir Solaire', 38.7139, -9.1390),
  ('Sunrise Co-Living',   41.3851,  2.1734),
  ('Green Bean Hub',      52.5200, 13.4050),
  ('Casa do Sol',         38.7223, -9.1393),
  ('Maritimo Co-Living',  41.1496, -8.6109),
  ('Atelier Lumière',     48.8566,  2.3522),
  ('Surf & Co',           43.4832, -1.5586),
  ('Mirador Verde',       41.4036,  2.1744)
) as c(name, lat, lng)
where partner_cafes.name = c.name;

-- 2) Messages : pouvoir éditer / supprimer SES propres messages
drop policy if exists "Je modifie mes messages" on messages;
create policy "Je modifie mes messages" on messages for update to authenticated
  using (auth.uid() = sender_id) with check (auth.uid() = sender_id);

drop policy if exists "Je supprime mes messages" on messages;
create policy "Je supprime mes messages" on messages for delete to authenticated
  using (auth.uid() = sender_id);

-- 3) Blocage d'un voyageur
create table if not exists blocks (
  id         bigint generated always as identity primary key,
  blocker    uuid references auth.users(id) on delete cascade,
  blocked    uuid references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  unique (blocker, blocked)
);
alter table blocks enable row level security;

drop policy if exists "Je vois mes blocages" on blocks;
create policy "Je vois mes blocages" on blocks for select to authenticated using (auth.uid() = blocker);
drop policy if exists "Je bloque" on blocks;
create policy "Je bloque" on blocks for insert to authenticated with check (auth.uid() = blocker);
drop policy if exists "Je debloque" on blocks;
create policy "Je debloque" on blocks for delete to authenticated using (auth.uid() = blocker);

-- ✅ Terminé.
