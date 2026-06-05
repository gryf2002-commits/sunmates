-- ============================================================
-- SunMates — Session 21 : AVIS SUR LES LIEUX (note ⭐ + commentaires)
-- Renforce le cœur « lieux sûrs » : un signal de confiance communautaire sur
-- chaque spot. Un avis par personne et par lieu (modifiable).
-- À lancer dans le SQL Editor de Supabase. Rejouable (idempotent).
-- ============================================================

create table if not exists place_reviews (
  id         bigint generated always as identity primary key,
  cafe_id    bigint references partner_cafes(id) on delete cascade,
  user_id    uuid references auth.users(id) on delete cascade,
  rating     int not null check (rating between 1 and 5),
  comment    text,
  created_at timestamptz default now(),
  unique (cafe_id, user_id)   -- un seul avis par personne et par lieu
);
alter table place_reviews enable row level security;

-- Avis publics (lisibles par tous les membres connectés)
drop policy if exists "Avis visibles par les membres" on place_reviews;
create policy "Avis visibles par les membres" on place_reviews for select to authenticated using (true);
-- Je gère uniquement MON avis
drop policy if exists "Je laisse mon avis" on place_reviews;
create policy "Je laisse mon avis" on place_reviews for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Je modifie mon avis" on place_reviews;
create policy "Je modifie mon avis" on place_reviews for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Je supprime mon avis" on place_reviews;
create policy "Je supprime mon avis" on place_reviews for delete to authenticated using (auth.uid() = user_id);

-- Moyennes par lieu (1 appel léger pour toute la liste).
create or replace function place_ratings()
returns table (cafe_id bigint, avg numeric, cnt bigint)
language sql
security definer
set search_path = public
as $$
  select cafe_id, round(avg(rating)::numeric, 1) as avg, count(*)::bigint as cnt
  from place_reviews group by cafe_id;
$$;
grant execute on function place_ratings() to authenticated;

-- Fin session 21.
