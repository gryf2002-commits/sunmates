-- ============================================================
-- SunMates — Correctifs sécurité (audit RLS). Idempotent / rejouable.
-- À coller dans Supabase > SQL Editor > Run.
--
-- Contexte : SunMates est un site statique (la clé anon est PUBLIQUE), donc TOUTE
-- la sécurité repose sur les règles RLS Postgres. L'audit a trouvé le backend solide ;
-- voici les quelques trous d'intégrité à boucher. Ce fichier applique H1, R1, R2, R4
-- (sans risque). H2 est plus bas, DÉSACTIVÉ (lis l'avertissement avant de l'activer).
-- ============================================================

-- ------------------------------------------------------------
-- H1) Badges auto-attribuables (faille de triche)
-- Avant : un utilisateur pouvait s'insérer N'IMPORTE QUEL badge (dont les secrets/prestige)
--         car la policy ne vérifiait que "la ligne est à moi".
-- Les badges légitimes sont attribués UNIQUEMENT par complete_quest / _grant_quest
-- (SECURITY DEFINER → contournent la RLS). Donc le client n'a jamais besoin d'INSERT direct.
-- ------------------------------------------------------------
drop policy if exists "Je gagne mes badges" on user_badges;
-- (plus aucune policy INSERT côté client → seules les fonctions de confiance écrivent les badges)


-- ------------------------------------------------------------
-- R1) Coupons "dé-consommables"
-- Avant : l'utilisateur pouvait repasser used=true -> false et réutiliser un coupon à usage unique.
-- On garde l'UPDATE owner (pour les autres champs) mais on bloque la réactivation.
-- ------------------------------------------------------------
create or replace function _sm_guard_coupon()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if old.used = true and new.used = false then
    new.used := old.used;  -- un coupon déjà utilisé ne peut plus être réactivé
  end if;
  return new;
end; $$;
drop trigger if exists sm_guard_coupon on user_coupons;
create trigger sm_guard_coupon before update on user_coupons
  for each row execute function _sm_guard_coupon();


-- ------------------------------------------------------------
-- R2) Policy admin "reports" : with check (true) -> is_admin() (propreté, défense en profondeur)
-- ------------------------------------------------------------
drop policy if exists "Admin gere les signalements" on reports;
create policy "Admin gere les signalements" on reports for update to authenticated
  using (is_admin()) with check (is_admin());


-- ------------------------------------------------------------
-- R4) Bug RGPD : la colonne est "reported_user", pas "reported".
-- L'ancienne suppression de compte ratait silencieusement le nettoyage des signalements
-- où l'utilisateur était la personne SIGNALÉE. Corrigé ci-dessous.
-- ------------------------------------------------------------
create or replace function sm_delete_my_account()
returns void language plpgsql security definer set search_path = public, auth as $$
declare uid uuid := auth.uid();
begin
  if uid is null then return; end if;
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
  begin delete from reports where reporter = uid or reported_user = uid; exception when others then null; end;
  begin delete from vouches where voucher = uid or vouched = uid; exception when others then null; end;
  begin delete from place_reviews where user_id = uid; exception when others then null; end;
  begin delete from profiles_private where id = uid; exception when others then null; end;
  begin delete from profiles where id = uid; exception when others then null; end;
  begin delete from auth.users where id = uid; exception when others then null; end;
end; $$;
grant execute on function sm_delete_my_account() to authenticated;


-- ============================================================
-- H2) OPTIONNEL — figer trust_score / is_verified (NE PAS lancer tel quel)
-- ============================================================
-- ⚠️ AVERTISSEMENT : aujourd'hui, le bouton "vérification" du MVP écrit is_verified
-- EN DIRECT côté client (choix assumé du MVP, cf. CLAUDE.md "vérification simulée").
-- Si tu actives le bloc ci-dessous SANS rien d'autre, le bouton de vérification
-- CESSERA de fonctionner (l'écriture sera figée). Pour l'activer proprement il faut
-- AUSSI router la vérification par une RPC SECURITY DEFINER qui pose le flag
-- sunmates.trusted (comme on le fait déjà pour l'XP), puis pointer le client dessus.
--
-- Tant que SunMates est un "jeu" (la vérif est cosmétique), tu peux laisser H2 de côté.
-- Quand tu voudras une vraie vérification anti-triche, dis-le-moi : je fais la RPC + le
-- changement client + ce bloc d'un coup. En attendant, on le laisse commenté.
--
-- create or replace function _sm_guard_privilege()
-- returns trigger language plpgsql security definer set search_path = public as $$
-- begin
--   if public.is_admin() or coalesce(current_setting('sunmates.trusted', true), '') = '1' then
--     return new;
--   end if;
--   new.is_admin      := old.is_admin;
--   new.is_gold       := old.is_gold;
--   new.banned        := old.banned;
--   new.ban_permanent := old.ban_permanent;
--   new.trust_score   := old.trust_score;   -- ne change que via les RPC check-in/quête
--   new.is_verified   := old.is_verified;   -- la vérif doit passer par une RPC de confiance
--   return new;
-- end; $$;
-- drop trigger if exists sm_guard_privilege on profiles;
-- create trigger sm_guard_privilege before update on profiles
--   for each row execute function _sm_guard_privilege();

-- ============================================================
-- Fin. Lance ce fichier en entier : H1, R1, R2, R4 s'appliquent ; H2 reste inactif (commenté).
-- ============================================================
