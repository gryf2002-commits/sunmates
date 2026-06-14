-- ============================================================================
-- SunMates — RGPD : suppression de compte (droit à l'effacement, P2.50).
-- Une RPC sécurisée que l'utilisateur appelle pour SUPPRIMER son propre compte :
-- efface ses données dans toutes les tables connues PUIS son compte Auth.
-- Best-effort par table (ignore une table/colonne absente → robuste sur ce schéma).
-- ⚠️ VERSION CANONIQUE & COMPLÈTE de sm_delete_my_account (supersede la copie plus ancienne et
--    incomplète de supabase_migration_security_fixes.sql). C'est « create or replace » → sûr à
--    relancer. À EXÉCUTER EN DERNIER dans le SQL Editor de Supabase pour écraser toute version périmée.
-- ============================================================================

create or replace function sm_delete_my_account()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare uid uuid := auth.uid();
begin
  if uid is null then return; end if;
  -- Données liées (best-effort : un bloc par table pour ne pas échouer si une table n'existe pas).
  begin delete from messages where sender_id = uid or recipient_id = uid; exception when others then null; end;
  begin delete from matches_connections where user_a = uid or user_b = uid; exception when others then null; end;
  begin delete from checkpoints where user_id = uid; exception when others then null; end;
  begin delete from user_quests where user_id = uid; exception when others then null; end;
  begin delete from blocks where blocker = uid or blocked = uid; exception when others then null; end;
  begin delete from feed_posts where user_id = uid; exception when others then null; end;
  begin delete from feed_comments where user_id = uid; exception when others then null; end;
  begin delete from feed_poll_votes where user_id = uid; exception when others then null; end;
  begin delete from message_reactions where user_id = uid; exception when others then null; end;
  begin delete from push_subscriptions where user_id = uid; exception when others then null; end;
  begin delete from app_feedback where user_id = uid; exception when others then null; end;
  begin delete from locations_realtime where user_id = uid; exception when others then null; end;
  begin delete from trips where user_id = uid; exception when others then null; end;
  begin delete from quest_suggestions where from_user = uid or to_user = uid; exception when others then null; end;
  begin delete from reports where reporter = uid or reported_user = uid; exception when others then null; end; -- FIX : la colonne est « reported_user »
  begin delete from vouches where voucher = uid or vouchee = uid; exception when others then null; end; -- FIX : la colonne est « vouchee » (pas « vouched »)
  begin delete from place_reviews where user_id = uid; exception when others then null; end;
  -- Tables ajoutées depuis (groupes, badges, coupons, journal solo, activités carte, sessions de groupe).
  -- La plupart cascadent déjà via auth.users, mais on les efface aussi explicitement (robustesse si le
  -- delete auth.users échoue) — best-effort, un bloc par table.
  begin delete from group_messages where sender_id = uid; exception when others then null; end;
  begin delete from group_members where user_id = uid; exception when others then null; end;
  begin delete from group_chats where creator = uid; exception when others then null; end;
  begin delete from user_badges where user_id = uid; exception when others then null; end;
  begin delete from user_coupons where user_id = uid; exception when others then null; end;
  begin delete from user_solo_log where user_id = uid; exception when others then null; end;
  begin delete from map_activities where creator = uid; exception when others then null; end;
  begin delete from quest_group_runs where initiator = uid or partner = uid; exception when others then null; end;
  -- Fichiers uploadés (avatars, notes vocales) : storage.objects ne cascade PAS sur auth.users → on les
  -- supprime explicitement, sinon les photos/audios de l'utilisateur restent dans les buckets (fuite RGPD).
  begin delete from storage.objects where owner = uid; exception when others then null; end;
  begin delete from profiles_private where id = uid; exception when others then null; end;
  begin delete from profiles where id = uid; exception when others then null; end;
  -- Le compte Auth lui-même (efface définitivement l'identité de connexion).
  begin delete from auth.users where id = uid; exception when others then null; end;
end;
$$;

grant execute on function sm_delete_my_account() to authenticated;
