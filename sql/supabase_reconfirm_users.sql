-- ============================================================
-- RESTAURER (re-confirmer) les comptes existants
-- À lancer dans le SQL Editor Supabase.
-- ============================================================
-- Contexte : on avait mis email_confirmed_at = NULL pour forcer la vérification
-- d'email. Comme la vérification d'email est finalement DÉSACTIVÉE pour l'instant,
-- on remet tous les comptes dans un état "confirmé" propre (pour éviter tout
-- blocage, et pour le jour où tu réactiveras la confirmation).

update auth.users
set email_confirmed_at = coalesce(email_confirmed_at, created_at, now())
where email_confirmed_at is null;

-- Vérif : il ne doit plus rester de comptes "à confirmer".
-- select count(*) filter (where email_confirmed_at is null) as a_confirmer,
--        count(*) filter (where email_confirmed_at is not null) as confirmes
-- from auth.users;
