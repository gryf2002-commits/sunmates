-- ============================================================
-- SunMates — Session 24 : l'admin peut SUPPRIMER un signalement traité
-- (complète les politiques admin existantes : lecture + update déjà en place).
-- À lancer dans le SQL Editor de Supabase. Rejouable (idempotent).
-- ============================================================

drop policy if exists "Admin supprime les signalements" on reports;
create policy "Admin supprime les signalements" on reports
  for delete to authenticated using (is_admin());

-- Fin session 24.
