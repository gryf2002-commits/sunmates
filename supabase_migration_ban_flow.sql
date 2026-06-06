-- ============================================================
-- SunMates — Flux de bannissement (à lancer dans le SQL Editor Supabase)
-- ============================================================
-- Deux niveaux de bannissement :
--   • TEMPORAIRE (défaut) : le compte est conservé, l'utilisateur est prévenu
--     à sa prochaine connexion et peut demander une révision (récupération).
--   • DÉFINITIF : aucune info pour l'utilisateur, le profil est masqué de la
--     liste des membres (vraie suppression du compte auth = via le back-office
--     Supabase / Admin API, non gérable depuis le client).
-- ------------------------------------------------------------

-- 1) Colonnes de bannissement sur les profils
alter table public.profiles add column if not exists banned_at         timestamptz;
alter table public.profiles add column if not exists ban_permanent     boolean not null default false;
alter table public.profiles add column if not exists ban_reason        text;
alter table public.profiles add column if not exists recovery_requested boolean not null default false;
alter table public.profiles add column if not exists recovery_note     text;

-- 2) RPC : l'utilisateur banni (temporaire) demande une révision de son compte.
--    SECURITY DEFINER pour pouvoir écrire malgré le bannissement.
create or replace function public.request_ban_recovery(p_note text)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  r public.profiles%rowtype;
begin
  select * into r from public.profiles where id = auth.uid();
  if not found then
    return json_build_object('ok', false, 'message', 'Profil introuvable.');
  end if;
  if not coalesce(r.banned, false) then
    return json_build_object('ok', false, 'message', 'Ton compte n''est pas suspendu.');
  end if;
  if coalesce(r.ban_permanent, false) then
    -- Bannissement définitif : aucune révision possible (et on ne le dit pas).
    return json_build_object('ok', false, 'message', 'Demande impossible.');
  end if;
  update public.profiles
     set recovery_requested = true,
         recovery_note = left(coalesce(p_note, ''), 500)
   where id = auth.uid();
  return json_build_object('ok', true);
end;
$$;

grant execute on function public.request_ban_recovery(text) to authenticated;

-- 3) (Optionnel) Index pour retrouver vite les demandes de révision en modération.
create index if not exists idx_profiles_recovery on public.profiles (recovery_requested) where recovery_requested;

-- ✅ Terminé. Le front gère le reste (chooser admin temp/définitif, écran de
--    bannissement à la connexion, bouton « demander une révision »).
