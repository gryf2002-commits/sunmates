-- ============================================================
-- SunMates — historique DA (versions / rollback)
-- Append-only : une ligne par publication. Restauration = upsert da_tokens.
-- À exécuter dans le SQL Editor Supabase. Admin = profiles.is_admin.
-- ============================================================
create table if not exists public.da_history (
  id          bigint generated always as identity primary key,
  tokens      jsonb       not null,
  created_at  timestamptz not null default now(),
  updated_by  uuid        references auth.users(id)
);
alter table public.da_history enable row level security;

drop policy if exists "da_history read" on public.da_history;
create policy "da_history read" on public.da_history
  for select using (true);

drop policy if exists "da_history admin write" on public.da_history;
create policy "da_history admin write" on public.da_history
  for insert with check (
    exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin)
  );

-- (optionnel) purge : ne garder que les 50 dernières versions
-- delete from public.da_history where id not in
--   (select id from public.da_history order by id desc limit 50);
