-- ============================================================
-- SunMates — stats EN DIRECT du tableau de bord admin (#26)
-- À exécuter dans Supabase : SQL Editor → New query → coller → Run.
-- Idempotent : tu peux le relancer sans risque.
-- ============================================================

create or replace function public.admin_live_stats()
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  result json;
begin
  -- Réservé aux admins (le SECURITY DEFINER permet de compter ce que la RLS cache,
  -- mais UNIQUEMENT des comptages agrégés — aucun contenu n'est exposé).
  if not exists (select 1 from profiles where id = auth.uid() and is_admin = true) then
    return json_build_object('ok', false);
  end if;

  select json_build_object(
    'ok', true,
    'active_now',     (select count(*) from profiles where last_seen_at > now() - interval '10 minutes'),
    'active_today',   (select count(*) from profiles where last_seen_at > date_trunc('day', now())),
    'messages_today', (select count(*) from messages where created_at > date_trunc('day', now())),
    'checkins_today', (select count(*) from checkpoints where created_at > date_trunc('day', now())),
    'new_users_today',(select count(*) from profiles where created_at > date_trunc('day', now()))
  ) into result;

  return result;
end;
$$;

revoke all on function public.admin_live_stats() from public;
grant execute on function public.admin_live_stats() to authenticated;
