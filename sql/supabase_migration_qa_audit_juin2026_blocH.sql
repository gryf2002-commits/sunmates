-- ============================================================================
-- SunMates — QA Audit juin 2026 — Bloc H (sécurité / RLS / perf backend)
-- Projet : ihiwuharxkmkzaxixhae
-- Branche : qa/audit-juin-2026
--
-- ✅ APPLIQUÉ EN PROD le 26/06/2026 via MCP apply_migration (nom: qa_audit_juin2026_blocH)
--    + 2 CREATE INDEX CONCURRENTLY. Re-scan advisors perf : initplan + FK non indexées = 0.
--    Feu vert Maxime explicite (« Oui, applique tout »).
--
-- ⚠️ NE PAS ré-appliquer sans feu vert explicite de Maxime (« applique le »).
--    Toutes les corrections ci-dessous DURCISSENT la sécurité (aucun
--    affaiblissement). Les blocs sont indépendants : on peut appliquer
--    section par section. Idempotent autant que possible.
--
-- Couvre : H.1 P1-S1..S4, H.2 (rien à corriger), H.3 P1.
-- Hors-SQL (dashboard Maxime) : activer Leaked Password Protection.
-- ============================================================================

begin;

-- ----------------------------------------------------------------------------
-- P1-S1 + P2-S7 : trip groups exécutables par ANON
--   sm_join_trip_group : un anon peut créer/RENOMMER un groupe (on conflict
--   do update set city) et insérer un membre user_id = NULL.
--   sm_in_trip_group : inoffensif pour anon (auth.uid() NULL → false) mais
--   ne doit pas être exposé au rôle anonyme.
-- Fix : révoquer anon + refuser l'appel non authentifié dans le corps.
-- ----------------------------------------------------------------------------
revoke execute on function public.sm_join_trip_group(text, text, text) from anon;
revoke execute on function public.sm_in_trip_group(bigint)             from anon;

create or replace function public.sm_join_trip_group(p_city text, p_key text, p_period text)
 returns trip_groups
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
declare g public.trip_groups;
begin
  if auth.uid() is null then raise exception 'Connexion requise'; end if;   -- AJOUT
  if coalesce(trim(p_key), '') = '' then raise exception 'group_key requis'; end if;
  insert into public.trip_groups (group_key, city, period, created_by)
    values (p_key, coalesce(nullif(trim(p_city), ''), 'Voyage'), p_period, auth.uid())
    on conflict (group_key) do update set city = excluded.city
    returning * into g;
  insert into public.trip_group_members (group_id, user_id) values (g.id, auth.uid())
    on conflict (group_id, user_id) do nothing;
  return g;
end;
$function$;

-- ----------------------------------------------------------------------------
-- P1-S2 + P1-S3 : prix CÔTÉ CLIENT (sm_spend_coins / sm_buy_boost)
--   Le client passe p_amount / p_cost → on peut acheter n'importe quel
--   cosmétique ou boost pour 0 SunCoin (p_amount=0 est accepté).
-- Fix : le SERVEUR fait autorité sur les prix. Le paramètre client devient
--   purement indicatif ; le débit réel vient du catalogue ci-dessous.
--   ⚠️ Si un prix change dans app.html (SHOP_TITLES / SHOP_FRAMES / BOOSTS),
--      mettre à jour ces CASE en miroir (ou migrer vers une table catalogue).
-- ----------------------------------------------------------------------------
create or replace function public.sm_spend_coins(p_amount integer, p_item text default null::text)
 returns table(ok boolean, balance integer, message text)
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
declare uid uuid := auth.uid(); bal int; v_price int;
begin
  if uid is null then return query select false, 0, 'Non connecté'; return; end if;
  -- Prix AUTORITATIF serveur (miroir de SHOP_TITLES + SHOP_FRAMES dans app.html)
  v_price := case p_item
    -- titres
    when 'none' then 0 when 'freebird' then 0 when 'sunheart' then 40 when 'sunchaser' then 90
    when 'wildsoul' then 180 when 'shootingstar' then 320 when 'globetrotter' then 550
    when 'pathfinder' then 850 when 'citylegend' then 1300 when 'sunlegend' then 2000 when 'mythic' then 3500
    -- cadres
    when 'gold' then 60 when 'coral' then 130 when 'sunset' then 260 when 'aurora' then 480
    when 'emerald' then 900 when 'royal' then 1800
    else null end;
  if v_price is null then return query select false, 0, 'Article inconnu'; return; end if;
  select coins into bal from profiles where id = uid for update;
  if bal is null then return query select false, 0, 'Profil introuvable'; return; end if;
  -- Déjà possédé → 0 débit, succès idempotent
  if p_item is not null and (select cosmetics_owned ? p_item from profiles where id = uid) then
    return query select true, bal, 'ok'; return;
  end if;
  if bal < v_price then return query select false, bal, 'Pas assez de SunCoins'; return; end if;
  update profiles
     set coins = coins - v_price,
         cosmetics_owned = case
           when p_item is null or cosmetics_owned ? p_item then cosmetics_owned
           else cosmetics_owned || to_jsonb(p_item) end
   where id = uid;
  select coins into bal from profiles where id = uid;
  return query select true, bal, 'ok';
end;
$function$;

create or replace function public.sm_buy_boost(p_boost text, p_cost integer)
 returns table(ok boolean, balance integer, message text)
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
declare uid uuid := auth.uid(); bal int; v_price int;
begin
  if uid is null then return query select false, 0, 'Non connecté'; return; end if;
  v_price := case p_boost when 'spotlight' then 120 else null end;   -- miroir de BOOSTS
  if v_price is null then return query select false, 0, 'Boost inconnu'; return; end if;
  select coins into bal from profiles where id = uid for update;
  if bal is null then return query select false, 0, 'Profil introuvable'; return; end if;
  if bal < v_price then return query select false, bal, 'Pas assez de SunCoins'; return; end if;
  update profiles
     set coins = coins - v_price,
         boosted_until = greatest(coalesce(boosted_until, now()), now()) + interval '24 hours'
   where id = uid;
  select coins into bal from profiles where id = uid;
  return query select true, bal, 'ok';
end;
$function$;

-- ----------------------------------------------------------------------------
-- P1-S4 : sm_grant_badge — autorise-par-défaut
--   Les badges du catalogue SANS branche de condition codée (badges secrets,
--   nouveaux badges) gardent v_ok = true → auto-attribuables → fausse le
--   classement « par badges ». Fix : refus par défaut (deny-by-default).
-- ----------------------------------------------------------------------------
create or replace function public.sm_grant_badge(p_key text)
 returns json
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
declare
  v_name text; v_emoji text; v_secret boolean;
  uid uuid := auth.uid();
  v_ok boolean := false;   -- CHANGÉ : deny par défaut (était true)
  v_cnt int;
begin
  if uid is null then return json_build_object('ok', false, 'message', 'non connecté'); end if;
  select name, emoji, coalesce(is_secret, false) into v_name, v_emoji, v_secret
    from badges_catalog where key = p_key;
  if not found then return json_build_object('ok', false, 'message', 'badge inconnu'); end if;

  if p_key = 'badge_verified' then
    select coalesce(is_verified, false) into v_ok from profiles where id = uid;
  elsif p_key = 'badge_legend' then
    select (coalesce(xp, 0) >= 500) into v_ok from profiles where id = uid;
  elsif p_key = 'badge_butterfly' then
    select count(*) into v_cnt from matches_connections
      where status = 'accepted' and (user_a = uid or user_b = uid);
    v_ok := (v_cnt >= 10);
  elsif p_key = 'badge_globetrotter' then
    select count(distinct c.city) into v_cnt
      from checkpoints ck join partner_cafes c on c.id = ck.cafe_id
      where ck.user_id = uid and c.city is not null;
    v_ok := (v_cnt >= 5);
  end if;
  -- tout autre badge : v_ok reste false → non auto-attribuable côté client
  -- (les badges secrets / serveur passent par d'autres chemins de confiance)

  if not coalesce(v_ok, false) then
    return json_build_object('ok', false, 'message', 'condition non remplie');
  end if;
  insert into user_badges (user_id, badge_key, name, emoji)
  values (uid, p_key, v_name, v_emoji)
  on conflict (user_id, badge_key) do nothing;
  return json_build_object('ok', true);
end;
$function$;

-- ----------------------------------------------------------------------------
-- P1-S5 : sm_delete_my_account — suppression silencieusement incomplète
--   Quasi toutes les tables CASCADE sur auth.users, MAIS group_members.added_by
--   et da_*.updated_by sont en NO ACTION : si l'utilisateur a ajouté des membres
--   à un groupe, « delete from auth.users » échoue → l'exception est avalée →
--   le compte SURVIT (login encore possible) sans erreur visible.
-- Fix : nettoyer les références NO ACTION, puis supprimer auth.users SANS
--   avaler l'erreur finale (le CASCADE purge le reste : ~50 tables).
-- ----------------------------------------------------------------------------
create or replace function public.sm_delete_my_account()
 returns void
 language plpgsql
 security definer
 set search_path to 'public', 'auth'
as $function$
declare uid uuid := auth.uid();
begin
  if uid is null then return; end if;
  -- Références NO ACTION (sinon le delete auth.users serait bloqué)
  update public.group_members set added_by = null where added_by = uid;
  update public.da_strings   set updated_by = null where updated_by = uid;
  update public.da_tokens    set updated_by = null where updated_by = uid;
  update public.da_history   set updated_by = null where updated_by = uid;
  -- Tout le reste (profiles, messages, checkpoints, badges, coupons, logs, feed,
  -- trips, trip_group_*, group_*, vouches, reports, locations, etc.) est en
  -- ON DELETE CASCADE sur auth.users → purge automatique ci-dessous.
  delete from auth.users where id = uid;   -- PAS de exception/null : on veut que ça échoue bruyamment si ça échoue
end;
$function$;

-- ----------------------------------------------------------------------------
-- P1 (H.3) : RLS auth_rls_initplan — auth.uid() ré-évalué par ligne
--   trip_groups / trip_group_members / trip_group_messages.
--   Fix : (select auth.uid()). Mêmes droits, juste plus rapide à l'échelle.
--   (On recrée chaque policy à l'identique avec l'enrobage select.)
-- ----------------------------------------------------------------------------
-- trip_groups : "tg insert"  (check: created_by = auth.uid())
drop policy if exists "tg insert" on public.trip_groups;
create policy "tg insert" on public.trip_groups
  for insert to authenticated
  with check (created_by = (select auth.uid()));

-- trip_group_members : "tgm insert self"  (check: user_id = auth.uid())
drop policy if exists "tgm insert self" on public.trip_group_members;
create policy "tgm insert self" on public.trip_group_members
  for insert to authenticated
  with check (user_id = (select auth.uid()));

-- trip_group_members : "tgm delete self"  (using: user_id = auth.uid())
drop policy if exists "tgm delete self" on public.trip_group_members;
create policy "tgm delete self" on public.trip_group_members
  for delete to authenticated
  using (user_id = (select auth.uid()));

-- trip_group_messages : "tgmsg insert member"  (check: user_id = auth.uid() AND sm_in_trip_group(group_id))
drop policy if exists "tgmsg insert member" on public.trip_group_messages;
create policy "tgmsg insert member" on public.trip_group_messages
  for insert to authenticated
  with check (user_id = (select auth.uid()) and sm_in_trip_group(group_id));

-- trip_group_messages : "tgmsg delete own"  (using: user_id = auth.uid())
drop policy if exists "tgmsg delete own" on public.trip_group_messages;
create policy "tgmsg delete own" on public.trip_group_messages
  for delete to authenticated
  using (user_id = (select auth.uid()));

commit;

-- ============================================================================
-- P1 (H.3) : index FK manquants — SÉPARÉ car CREATE INDEX CONCURRENTLY
--   ne peut pas tourner dans une transaction. Lancer ces lignes UNE PAR UNE
--   (hors du begin/commit ci-dessus).
-- ============================================================================
-- create index concurrently if not exists idx_trip_group_messages_user_id
--   on public.trip_group_messages (user_id);
-- create index concurrently if not exists idx_trip_groups_created_by
--   on public.trip_groups (created_by);
