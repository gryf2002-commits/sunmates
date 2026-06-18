-- ============================================================================
-- SunMates — Migration session 12
-- Onboarding « du futur » : on retient si l'utilisateur a déjà vu l'accueil guidé.
-- À lancer dans le SQL Editor de Supabase (sans danger, idempotent).
-- ============================================================================

-- Colonne qui mémorise que l'onboarding a été terminé (par défaut : pas encore vu).
alter table profiles add column if not exists onboarded boolean not null default false;

-- Rien d'autre : la policy "update" de profiles permet déjà à chacun de modifier
-- SA propre ligne, donc l'app peut passer onboarded = true pour l'utilisateur connecté.
