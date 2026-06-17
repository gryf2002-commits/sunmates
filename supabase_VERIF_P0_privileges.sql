-- ============================================================
-- SunMates — VÉRIF P0 « anti-escalade de privilèges »  (17/06/2026)
-- ============================================================
-- POURQUOI : la policy RLS « Je modifie seulement mon profil » autorise
-- auth.uid() = id, mais ne filtre PAS les colonnes. SANS le trigger
-- `sm_guard_privilege`, n'importe quel compte peut, avec la clé anon PUBLIQUE,
-- faire depuis le navigateur :
--      update profiles set is_admin=true / is_gold=true / banned=false ...
-- → devenir admin / Gold / se débannir. C'est LE point bloquant avant tout
--   lancement public (audit AUDIT_APP_v529.md, P0).
--
-- COMMENT S'EN SERVIR (3 étapes, une à la fois) :
--   ÉTAPE 1 = DIAGNOSTIC (lecture seule, ne change rien) → colle le bloc 1,
--             lis le verdict.
--   ÉTAPE 2 = CORRECTIF (seulement si l'étape 1 dit "MANQUANT").
--   ÉTAPE 3 = TEST RÉEL (optionnel, prouve que le garde-fou marche).
--
-- Tout est rejouable sans danger.
-- ============================================================


-- ============================================================
-- ÉTAPE 1 — DIAGNOSTIC (LECTURE SEULE — colle ceci en premier)
-- ============================================================

-- 1.a) Les 4 colonnes sensibles existent-elles ?  (sinon le trigger planterait)
select
  'colonnes sensibles' as verif,
  bool_and(present)    as tout_ok,
  string_agg(col || '=' || case when present then 'OK' else 'MANQUANTE' end, ', ' order by col) as detail
from (
  select c.col,
         exists (
           select 1 from information_schema.columns
           where table_schema='public' and table_name='profiles'
             and column_name = c.col
         ) as present
  from (values ('is_admin'),('is_gold'),('banned'),('ban_permanent')) as c(col)
) t;

-- 1.b) Le trigger anti-escalade est-il bien installé ET actif ?
select
  'trigger sm_guard_privilege' as verif,
  case
    when count(*) = 0 then '❌ MANQUANT → fais l''ÉTAPE 2'
    when bool_and(t.tgenabled <> 'D') then '✅ PRÉSENT & ACTIF'
    else '⚠️ PRÉSENT mais DÉSACTIVÉ → fais l''ÉTAPE 2'
  end as verdict
from pg_trigger t
join pg_class c on c.oid = t.tgrelid
join pg_namespace n on n.oid = c.relnamespace
where n.nspname='public' and c.relname='profiles' and t.tgname='sm_guard_privilege';

-- 1.c) La fonction du garde-fou existe-t-elle ?
select '_sm_guard_privilege()' as verif,
       case when count(*) > 0 then '✅ existe' else '❌ absente → ÉTAPE 2' end as verdict
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname='public' and p.proname='_sm_guard_privilege';

-- → SI 1.a = MANQUANTE pour une colonne : lance d'ABORD la migration qui la crée
--   (is_admin → supabase_migration_session9.sql ; banned → session10 ;
--    is_gold → session11 ; ban_permanent → supabase_migration_ban_flow.sql),
--   PUIS l'ÉTAPE 2.
-- → SI 1.b / 1.c = ❌ ou ⚠️ : fais l'ÉTAPE 2.
-- → SI tout est ✅ : le P0 est DÉJÀ couvert. (Tu peux quand même faire l'ÉTAPE 3.)


-- ============================================================
-- ÉTAPE 2 — CORRECTIF (seulement si l'ÉTAPE 1 a signalé un manque)
-- ============================================================
-- Le contenu officiel est dans  supabase_migration_hardening.sql  (idempotent).
-- Tu peux soit ouvrir ce fichier et le coller, soit coller le bloc ci-dessous
-- (identique pour la partie trigger) :

create or replace function _sm_guard_privilege()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  -- L'admin (ou une RPC de confiance qui pose le flag) peut tout modifier.
  if public.is_admin() or coalesce(current_setting('sunmates.trusted', true), '') = '1' then
    return new;
  end if;
  -- Sinon : on remet les colonnes sensibles à leur valeur d'origine (tentative ignorée).
  new.is_admin      := old.is_admin;
  new.is_gold       := old.is_gold;
  new.banned        := old.banned;
  new.ban_permanent := old.ban_permanent;
  return new;
end; $$;

drop trigger if exists sm_guard_privilege on profiles;
create trigger sm_guard_privilege before update on profiles
  for each row execute function _sm_guard_privilege();

select '✅ garde-fou (re)posé — refais l''ÉTAPE 1 pour confirmer' as info;


-- ============================================================
-- ÉTAPE 3 — TEST RÉEL (optionnel mais rassurant)
-- ============================================================
-- Simule un utilisateur NORMAL (pas admin) qui tente de se promouvoir.
-- On se met dans le rôle "authenticated" avec un faux uid, on tente l'UPDATE,
-- on regarde si is_admin a été remis à false par le garde-fou, puis ROLLBACK
-- (rien n'est réellement modifié).
--
-- ⚠️ Remplace 'METS-ICI-UN-ID-DE-PROFIL' par un id réel de la table profiles
--    (un compte de TEST, pas un vrai admin). Récupère-en un avec :
--        select id, username, is_admin from profiles limit 5;

begin;
  -- on devient un utilisateur lambda
  set local role authenticated;
  set local request.jwt.claim.sub = 'METS-ICI-UN-ID-DE-PROFIL';

  -- tentative d'auto-promotion (ce que ferait un attaquant via la clé anon)
  update profiles
     set is_admin = true, is_gold = true, banned = false
   where id = 'METS-ICI-UN-ID-DE-PROFIL';

  -- verdict : doit afficher is_admin = false si le garde-fou marche
  select id, username, is_admin, is_gold, banned,
         case when is_admin = false then '✅ ATTAQUE BLOQUÉE'
              else '❌ ESCALADE POSSIBLE — garde-fou absent/inactif' end as resultat
    from profiles
   where id = 'METS-ICI-UN-ID-DE-PROFIL';
rollback;  -- on annule tout : aucune donnée modifiée

-- ============================================================
-- Fin. Si l'ÉTAPE 1 est toute ✅ (ou après ÉTAPE 2) et que l'ÉTAPE 3 affiche
-- « ATTAQUE BLOQUÉE », le P0 est levé : tu peux envisager le lancement public.
-- ============================================================
