-- ============================================================
-- RÉPARATION DU SCORE DE CONFIANCE (trust_score)
-- ------------------------------------------------------------
-- Pourquoi : un ancien bug (présent depuis la 1re version) faisait que le bouton
-- « Demander la vérification » ÉCRASAIT le score à 30 (au lieu d'ajouter +30).
-- Résultat : les points gagnés (check-ins, quêtes) pouvaient être perdus.
-- Le bug est corrigé dans l'app ; ce script RECALCULE le vrai score à partir des
-- données réelles, pour rendre à chacun ses points :
--   • +10 par check-in validé        (table checkpoints)
--   • + les points de chaque quête ACCOMPLIE (user_quests.status = 'completed')
--   • +30 si le profil est vérifié
--
-- Sans danger : il recalcule depuis la source → on peut le relancer autant de fois
-- qu'on veut, le résultat est toujours le même. Ne touche pas aux profils démo.
-- À exécuter dans Supabase → SQL Editor → Run.
-- ============================================================

update profiles p set trust_score =
    coalesce((select count(*) from checkpoints c where c.user_id = p.id), 0) * 10
  + coalesce((select sum(coalesce(q.points, 0))
              from user_quests uq
              join quests q on q.key = uq.quest_key
              where uq.user_id = p.id and uq.status = 'completed'), 0)
  + case when p.is_verified then 30 else 0 end
where coalesce(p.is_demo, false) = false;

-- (Facultatif) Vérifier les scores recalculés :
-- select username, trust_score, is_verified from profiles
-- where coalesce(is_demo,false) = false order by trust_score desc;
