-- ============================================================
-- SunMates — Déconnexion forcée de TOUS + reconfirmation d'email
-- À lancer dans : Supabase → SQL Editor (un bloc à la fois)
-- ============================================================
-- Ce que ça fait, en clair :
--   1) On COUPE toutes les sessions actives → tout le monde est déconnecté
--      (à la prochaine ouverture de l'appli, ils retombent sur l'écran de connexion).
--   2) On remet email_confirmed_at à NULL → chaque compte redevient "non confirmé".
--      Du coup, pour se reconnecter, il faut d'abord cliquer le lien reçu par mail.
--
-- ⚠️ AVANT de lancer : la confirmation d'email DOIT être activée côté Supabase
--    (Authentication → Sign In / Providers → Email → "Confirm email" = ON),
--    ET un SMTP custom doit envoyer les mails (sinon personne ne reçoit le lien).
--    Voir le guide GUIDE_confirmation_email.md.
--
-- ⚠️ Ça te concerne AUSSI (toi l'admin). Choisis l'option 2a (toi inclus) ou 2b (toi exclu).


-- ------------------------------------------------------------
-- ÉTAPE 1 — Couper toutes les sessions actives (déconnexion immédiate)
-- ------------------------------------------------------------
-- Supprimer les sessions invalide les jetons : au prochain rafraîchissement,
-- l'appli considère l'utilisateur comme déconnecté.
delete from auth.sessions;

-- (Variante : tout le monde SAUF toi, pour rester connecté le temps de vérifier)
-- delete from auth.sessions
-- where user_id <> (select id from auth.users where email = 'maxime.durao@delta-business.school');


-- ------------------------------------------------------------
-- ÉTAPE 2 — Forcer la reconfirmation d'email
-- ------------------------------------------------------------

-- ---- 2a) TOUS les comptes, TOI COMPRIS ----
update auth.users
set email_confirmed_at = null
where email_confirmed_at is not null;

-- ---- 2b) Variante : exclure ton compte admin (dé-commente, et commente 2a) ----
-- update auth.users
-- set email_confirmed_at = null
-- where email_confirmed_at is not null
--   and email <> 'maxime.durao@delta-business.school';


-- ------------------------------------------------------------
-- ÉTAPE 3 — Vérification (lance ce SELECT après)
-- ------------------------------------------------------------
select
  count(*) filter (where email_confirmed_at is not null) as confirmes,
  count(*) filter (where email_confirmed_at is null)     as a_confirmer
from auth.users;
-- Attendu : "a_confirmer" = nombre de comptes à reconfirmer, "confirmes" = 0 (ou 1 si tu t'es exclu).


-- ============================================================
-- EN CAS DE PÉPIN (annuler / re-confirmer tout le monde) :
-- utilise le fichier supabase_reconfirm_users.sql
-- ============================================================
