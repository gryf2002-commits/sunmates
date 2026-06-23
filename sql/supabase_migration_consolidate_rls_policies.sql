-- ============================================================================
-- Consolidation des policies RLS permissives en DOUBLE (linter perf 0006).
-- ⚠️ NON APPLIQUÉ AUTOMATIQUEMENT — à exécuter par Maxime (SQL Editor) après relecture.
-- Touche des policies de SÉCURITÉ de production → relire avant de lancer.
--
-- PRINCIPE (sûr) : 2 policies PERMISSIVES pour le même rôle+action = un row passe si
-- "A OR B". Les fusionner en UNE policy "(A OR B)" donne EXACTEMENT les mêmes droits,
-- avec une seule évaluation au lieu de deux. Vérifié policy par policy avant écriture.
--
-- Pour les tables où l'admin a une policy FOR ALL (da_strings, da_tokens, partner_cafes) :
-- la lecture est déjà ouverte (USING true) donc l'admin n'a besoin que des ÉCRITURES →
-- on remplace le FOR ALL par des policies INSERT/UPDATE/DELETE (mêmes droits, sans le
-- doublon sur SELECT).
--
-- ROLLBACK : recréer les policies d'origine (cf. git / supabase_schema). Transactionnel
-- si lancé d'un bloc (BEGIN; ... COMMIT;).
-- ============================================================================
begin;

-- 1) app_feedback SELECT : admin OR propriétaire
drop policy if exists "app_feedback_select_admin" on public.app_feedback;
drop policy if exists "app_feedback_select_own"   on public.app_feedback;
create policy "app_feedback_select" on public.app_feedback for select to public
  using (
    exists (select 1 from public.profiles p where p.id = (select auth.uid()) and coalesce(p.is_admin,false) = true)
    or user_id = (select auth.uid())
  );

-- 2) checkpoints SELECT : les miens OR ceux du lieu dont je suis partenaire
drop policy if exists "Je vois mes check-ins" on public.checkpoints;
drop policy if exists "Partenaire voit les checkins de son lieu" on public.checkpoints;
create policy "checkpoints_select" on public.checkpoints for select to authenticated
  using (
    (select auth.uid()) = user_id
    or cafe_id = (select partner_place_id from public.profiles where id = (select auth.uid()))
  );

-- 3) profiles UPDATE : admin OR mon profil
drop policy if exists "Admin gere les profils" on public.profiles;
drop policy if exists "Je modifie seulement mon profil" on public.profiles;
create policy "profiles_update" on public.profiles for update to authenticated
  using ( public.is_admin() or (select auth.uid()) = id )
  with check ( public.is_admin() or (select auth.uid()) = id );

-- 4) reports SELECT : admin OR mes signalements
drop policy if exists "Admin lit les signalements" on public.reports;
drop policy if exists "Je vois mes signalements" on public.reports;
create policy "reports_select" on public.reports for select to authenticated
  using ( public.is_admin() or (select auth.uid()) = reporter );

-- 5) da_strings : lecture (true) couvre tout le monde, admin = écritures seulement
drop policy if exists "da_strings admin write" on public.da_strings;
create policy "da_strings admin insert" on public.da_strings for insert to public
  with check ( exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_admin) );
create policy "da_strings admin update" on public.da_strings for update to public
  using ( exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_admin) )
  with check ( exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_admin) );
create policy "da_strings admin delete" on public.da_strings for delete to public
  using ( exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_admin) );

-- 6) da_tokens : idem
drop policy if exists "da_tokens admin write" on public.da_tokens;
create policy "da_tokens admin insert" on public.da_tokens for insert to public
  with check ( exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_admin) );
create policy "da_tokens admin update" on public.da_tokens for update to public
  using ( exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_admin) )
  with check ( exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_admin) );
create policy "da_tokens admin delete" on public.da_tokens for delete to public
  using ( exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_admin) );

-- 7) partner_cafes : SELECT couvert par "Lieux surs visibles" (true).
--    On retire le FOR ALL admin, on fusionne l'UPDATE (admin OR partenaire), admin INSERT/DELETE recréés.
drop policy if exists "Admin gere les lieux" on public.partner_cafes;
drop policy if exists "Partenaire met a jour son lieu" on public.partner_cafes;
create policy "partner_cafes_update" on public.partner_cafes for update to authenticated
  using ( public.is_admin() or id = (select partner_place_id from public.profiles where id = (select auth.uid())) )
  with check ( public.is_admin() or id = (select partner_place_id from public.profiles where id = (select auth.uid())) );
create policy "partner_cafes admin insert" on public.partner_cafes for insert to authenticated
  with check ( public.is_admin() );
create policy "partner_cafes admin delete" on public.partner_cafes for delete to authenticated
  using ( public.is_admin() );

commit;
