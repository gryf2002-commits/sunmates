-- ============================================================
-- SunMates — Feedback bêta (bug / idée / pixel) collecté dans l'app → admin
-- ============================================================
-- Tuile « App en bêta · donne ton avis » (Réglages) : l'utilisateur envoie un
-- retour typé (bug 🐞 / idée 💡 / pixel 🎨). Lisible dans l'onglet admin « Données ».
-- À exécuter dans le SQL Editor de Supabase. Idempotent (rejouable sans risque).
-- ============================================================

create table if not exists app_feedback (
  id          uuid primary key default gen_random_uuid(),
  type        text not null default 'bug' check (type in ('bug','idea','pixel')),
  message     text not null,
  user_id     uuid references auth.users(id) on delete set null,
  username    text,
  app_version text,
  user_agent  text,
  created_at  timestamptz not null default now()
);

create index if not exists app_feedback_created_idx on app_feedback (created_at desc);

alter table app_feedback enable row level security;

-- INSERT : tout le monde peut déposer un retour (même non connecté → anonyme).
drop policy if exists app_feedback_insert on app_feedback;
create policy app_feedback_insert on app_feedback
  for insert with check (true);

-- SELECT : lecture réservée à l'admin (panneau Données). Adapte la condition à ta
-- façon de marquer l'admin. Par défaut : colonne profiles.is_admin = true.
drop policy if exists app_feedback_select_admin on app_feedback;
create policy app_feedback_select_admin on app_feedback
  for select using (
    exists (select 1 from profiles p where p.id = auth.uid() and coalesce(p.is_admin, false) = true)
  );

-- ============================================================
-- Fin. Si tu n'as pas de colonne profiles.is_admin, crée-la :
--   alter table profiles add column if not exists is_admin boolean default false;
--   update profiles set is_admin = true where username = 'TON_PSEUDO_ADMIN';
-- ============================================================
