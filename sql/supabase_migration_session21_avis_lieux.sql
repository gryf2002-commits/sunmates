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

-- Avis de DÉMO (pour que la feature paraisse vivante dès le lancement) : jusqu'à 5 avis
-- par lieu, écrits par des comptes de démo. Idempotent (on conflict do nothing).
insert into place_reviews (cafe_id, user_id, rating, comment, created_at)
select c.id, d.id,
  (array[5,4,5,4,5])[d.rn],
  (array[
    'Accueil au top et ambiance hyper safe, je recommande 🙌',
    'Spot parfait pour rencontrer des voyageurs, je m''y suis senti·e en sécurité.',
    'Cosy et bien situé, l''équipe est adorable ☕',
    'Bonne adresse, lumineuse et conviviale. J''y retourne !',
    'Calme et rassurant, idéal pour un premier rendez-vous entre Mates.'
  ])[d.rn],
  now() - (d.rn || ' days')::interval
from partner_cafes c
cross join lateral (
  select p.id, row_number() over (order by p.id) as rn
  from profiles p where p.is_demo = true order by p.id limit 5
) d
on conflict (cafe_id, user_id) do nothing;

-- Fin session 21.
