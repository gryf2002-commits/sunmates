-- ============================================================================
-- SunMates — QA Audit juin 2026 — Bloc J.7 (onboarding : anti profil orphelin)
-- Projet : ihiwuharxkmkzaxixhae
--
-- ✅ APPLIQUÉ EN PROD le 26/06/2026 via MCP (qa_audit_juin2026_blocJ_signup_trigger)
--    Validé end-to-end : insert auth.users (tx + rollback) → profiles créé
--    (username depuis metadata, is_public=false, défauts OK), 0 résidu.
--
-- Constat : 1 auth.users SANS profiles (/60) → la création de profil était
--   100% côté client (ensureProfile, select-then-insert). Un signup interrompu
--   (email non confirmé jamais ouvert, coupure réseau) laisse un compte orphelin
--   capable de se connecter mais sans profil.
-- Fix : créer la ligne profiles AU MOMENT du signup (atomique). Compatible avec
--   le client (ensureProfile fait un select avant insert → pas de double insert).
--   on conflict (id) do nothing = jamais bloquant pour le signup.
--   Miroir exact du défaut client : username = meta.username || préfixe email (≤20),
--   is_public = false (compte privé par défaut).
-- NB : l'orphelin existant s'auto-répare à sa prochaine connexion (ensureProfile).
--   profiles_private reste en création paresseuse (by design : 45/59 sans ligne).
-- ============================================================================

create or replace function public.handle_new_user()
 returns trigger
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
begin
  insert into public.profiles (id, username, is_public)
  values (
    new.id,
    left(coalesce(
      nullif(trim(new.raw_user_meta_data->>'username'), ''),
      split_part(new.email, '@', 1)
    ), 20),
    false
  )
  on conflict (id) do nothing;
  return new;
end;
$function$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
