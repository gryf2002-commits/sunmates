-- ============================================================================
-- SunMates — Réponse admin aux feedbacks + notif "corrigé" (P2.34).
-- Dépend de supabase_migration_feedback.sql (table app_feedback).
-- L'admin peut répondre à un retour et le marquer résolu ; l'auteur voit la réponse
-- (et reçoit un toast "ton retour a été traité ✅" au prochain passage dans l'app).
-- À exécuter dans le SQL Editor de Supabase.
-- ============================================================================

alter table app_feedback add column if not exists admin_reply text;
alter table app_feedback add column if not exists status text not null default 'open';   -- open | resolved
alter table app_feedback add column if not exists replied_at timestamptz;

-- L'AUTEUR peut lire SES propres retours (pour voir la réponse admin). (L'admin garde sa policy.)
drop policy if exists app_feedback_select_own on app_feedback;
create policy app_feedback_select_own on app_feedback
  for select using (user_id = auth.uid());

-- RPC admin : répondre + marquer résolu. Réservé aux admins (security definer).
create or replace function sm_reply_feedback(p_id uuid, p_reply text)
returns table (ok boolean, message text)
language plpgsql
security definer
set search_path = public
as $$
declare is_adm boolean;
begin
  select coalesce(p.is_admin, false) into is_adm from profiles p where p.id = auth.uid();
  if not coalesce(is_adm, false) then return query select false, 'Réservé à l''admin'; return; end if;
  update app_feedback
     set admin_reply = p_reply,
         status = 'resolved',
         replied_at = now()
   where id = p_id;
  return query select true, 'ok';
end;
$$;

grant execute on function sm_reply_feedback(uuid, text) to authenticated;
