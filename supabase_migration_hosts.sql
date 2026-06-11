-- ============================================================
-- SunMates · Demandes d'hôte visibles côté admin (point 20)
-- À exécuter dans le SQL Editor de Supabase.
--
-- Avant : le statut « hôte » vivait uniquement dans le localStorage du
-- téléphone → l'admin ne voyait JAMAIS les demandes. Désormais il est
-- stocké sur le profil : l'app écrit 'pending', l'admin passe à
-- 'approved' ou 'rejected' depuis Admin → Membres.
-- ============================================================

alter table public.profiles
  add column if not exists host_status text
  check (host_status in ('pending', 'approved', 'rejected') or host_status is null);

-- Pas de nouvelle policy nécessaire :
--  · chacun peut déjà mettre à jour SON profil (demande 'pending'),
--  · l'admin met déjà à jour les profils des membres (vérif/ban) → idem ici.
