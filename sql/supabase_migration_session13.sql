-- ============================================================================
-- SunMates — Migration session 13
-- Activités partagées sur la carte : chaque membre peut créer SON point
-- (titre + position) pour proposer une quête / activité aux autres voyageurs.
-- À lancer dans le SQL Editor de Supabase (sans danger, idempotent).
-- ============================================================================

create table if not exists map_activities (
  id          bigint generated always as identity primary key,
  creator     uuid references auth.users(id) on delete cascade,
  title       text not null,
  note        text,
  lat         double precision not null,
  lng         double precision not null,
  created_at  timestamptz default now()
);
alter table map_activities enable row level security;

-- Lecture : tous les membres connectés voient les activités partagées.
drop policy if exists "Activites carte visibles" on map_activities;
create policy "Activites carte visibles" on map_activities for select to authenticated
  using (true);

-- Création : on ne crée que SES propres activités.
drop policy if exists "Je cree mes activites carte" on map_activities;
create policy "Je cree mes activites carte" on map_activities for insert to authenticated
  with check (auth.uid() = creator);

-- Suppression : on ne supprime que SES propres activités.
drop policy if exists "Je supprime mes activites carte" on map_activities;
create policy "Je supprime mes activites carte" on map_activities for delete to authenticated
  using (auth.uid() = creator);
