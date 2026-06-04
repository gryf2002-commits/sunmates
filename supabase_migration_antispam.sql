-- ============================================================
-- MIGRATION ANTI-SPAM (anti-doublons côté base de données)
-- ------------------------------------------------------------
-- Pourquoi : le verrou JavaScript (once/notifyOnce dans index.html) empêche les
-- doublons côté navigateur. Ce script ajoute la même garantie CÔTÉ BASE : même si
-- une requête en double passe (réseau lent, double onglet, contournement de
-- l'appli…), PostgreSQL la refuse au lieu de créer une 2e ligne.
--
-- À exécuter UNE fois dans Supabase → SQL Editor → Run.
-- Sans danger : on nettoie d'abord les doublons existants, puis on pose l'index.
-- ============================================================

-- ------------------------------------------------------------
-- 1) DEMANDES DE CONNEXION (matches_connections)
--    Règle : une seule connexion ACTIVE (pending ou accepted) par PAIRE de
--    voyageurs, quel que soit le sens (A→B et B→A comptent comme la même paire).
-- ------------------------------------------------------------

-- 1a) On supprime les doublons déjà présents. On garde, pour chaque paire, la
--     meilleure ligne : une connexion "accepted" en priorité, sinon la plus
--     ancienne (plus petit id).
with ranked as (
  select id,
         row_number() over (
           partition by least(user_a, user_b), greatest(user_a, user_b)
           order by (status = 'accepted') desc, id asc
         ) as rn
  from matches_connections
  where status in ('pending', 'accepted')
)
delete from matches_connections
where id in (select id from ranked where rn > 1);

-- 1b) Index unique sur la paire NON ordonnée (on range toujours le plus petit
--     uuid en premier via CASE → (A,B) et (B,A) tombent sur la même clé).
--     Partiel : ne s'applique qu'aux connexions actives. Les anciennes lignes
--     (refusées/archivées) n'empêchent donc pas une nouvelle demande plus tard.
create unique index if not exists uniq_active_connection
  on matches_connections (
    (case when user_a < user_b then user_a else user_b end),
    (case when user_a < user_b then user_b else user_a end)
  )
  where status in ('pending', 'accepted');

-- ------------------------------------------------------------
-- 2) DÉFIS / QUÊTES PROPOSÉS (quest_suggestions)
--    Règle : un seul défi EN ATTENTE (pending) pour un même trio
--    (expéditeur, destinataire, quête). Une fois accepté/refusé, on peut
--    re-proposer la même quête plus tard.
-- ------------------------------------------------------------

-- 2a) Nettoyage des doublons pending (on garde le plus ancien).
with ranked as (
  select id,
         row_number() over (
           partition by from_user, to_user, quest_key
           order by id asc
         ) as rn
  from quest_suggestions
  where status = 'pending'
)
delete from quest_suggestions
where id in (select id from ranked where rn > 1);

-- 2b) Index unique partiel sur les défis en attente.
create unique index if not exists uniq_pending_suggestion
  on quest_suggestions (from_user, to_user, quest_key)
  where status = 'pending';

-- ------------------------------------------------------------
-- 3) (Optionnel) POSITIONS D'URGENCE (locations_realtime)
--    Évite qu'un clic répété sur "Alerte d'urgence" crée des dizaines de lignes
--    SOS identiques dans la même minute. On garde au plus une alerte par
--    utilisateur et par minute. (Les positions normales ne sont pas concernées.)
-- ------------------------------------------------------------
create unique index if not exists uniq_emergency_per_minute
  on locations_realtime (user_id, date_trunc('minute', created_at))
  where is_emergency = true;

-- ============================================================
-- Vérification rapide (facultatif) : liste les index créés.
-- ============================================================
-- select indexname from pg_indexes
-- where tablename in ('matches_connections','quest_suggestions','locations_realtime')
--   and indexname like 'uniq_%';
