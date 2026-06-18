-- ============================================================
-- SunMates — Infos pratiques des lieux partenaires (v388)
-- Horaires + fourchette de prix, saisis par l'admin, affichés
-- sur la fiche du lieu (🕐 / 💶). Champs OPTIONNELS.
-- À exécuter dans le SQL Editor de Supabase.
-- ============================================================

alter table public.partner_cafes add column if not exists hours text;
alter table public.partner_cafes add column if not exists price_range text;

-- Rien d'autre à faire : la lecture passe par le SELECT * existant
-- (RLS de lecture inchangée), l'écriture reste réservée à l'admin.
