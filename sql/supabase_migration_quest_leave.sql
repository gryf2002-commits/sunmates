-- ============================================================================
-- SunMates — QUITTER une quête (P2.12)
-- Il manquait la policy DELETE sur user_quests (on pouvait rejoindre mais jamais
-- quitter). On autorise un utilisateur à supprimer SES lignes uniquement.
-- (Garde-fou côté app : on ne supprime que les lignes status='joined', jamais
-- une quête déjà 'completed'.)
-- À exécuter dans le SQL Editor de Supabase.
-- ============================================================================

drop policy if exists "Je quitte mes quetes" on user_quests;
create policy "Je quitte mes quetes" on user_quests
  for delete to authenticated
  using (auth.uid() = user_id);
