-- ============================================================
--  SunMates — SESSION 7 : abonnements Web Push (notif app fermée)
--  À coller dans Supabase : SQL Editor > New query > Run. Idempotent.
-- ============================================================

create table if not exists push_subscriptions (
  id           bigint generated always as identity primary key,
  user_id      uuid references auth.users(id) on delete cascade,
  endpoint     text unique not null,        -- identifiant unique de l'appareil/navigateur
  subscription jsonb not null,              -- l'objet d'abonnement complet (endpoint + clés)
  created_at   timestamptz default now()
);
alter table push_subscriptions enable row level security;

drop policy if exists "Je vois mes abonnements push" on push_subscriptions;
create policy "Je vois mes abonnements push" on push_subscriptions for select to authenticated using (auth.uid() = user_id);
drop policy if exists "J enregistre mon abonnement push" on push_subscriptions;
create policy "J enregistre mon abonnement push" on push_subscriptions for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Je mets a jour mon abonnement push" on push_subscriptions;
create policy "Je mets a jour mon abonnement push" on push_subscriptions for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Je supprime mon abonnement push" on push_subscriptions;
create policy "Je supprime mon abonnement push" on push_subscriptions for delete to authenticated using (auth.uid() = user_id);

-- ✅ Terminé. La fonction Edge "send-push" (service_role) lira cette table
--    pour envoyer les notifications — voir PUSH_SETUP.md.
