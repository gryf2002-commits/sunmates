-- =============================================================================
-- SunMates — session 41 : partage de position visible 24 h (aligne base ↔ UI)
-- -----------------------------------------------------------------------------
-- Problème : l'UI promet « position visible 24 h » à ton cercle de confiance,
-- mais la policy de LECTURE de locations_realtime ne laissait voir que les
-- positions de moins d'1 h → ton cercle te « perdait » après 1 h alors que tu
-- te croyais visible 24 h (incohérence sur une promesse de SÉCURITÉ cœur).
-- La fonction de purge `sm_purge_old_locations` supprime déjà à 24 h → étendre
-- la fenêtre de lecture à 24 h est cohérent (aucune donnée gardée plus longtemps).
-- Décision Maxime (21/06) : honorer la promesse → fenêtre de lecture = 24 h.
-- =============================================================================

alter policy "Mon cercle de confiance voit mes positions"
  on public.locations_realtime
  using (
    (created_at > (now() - '24:00:00'::interval))
    and (
      (( select auth.uid() as uid) = user_id)
      or (exists (
        select 1
        from matches_connections m
        where ((m.status = 'accepted'::text)
          and (((m.user_a = ( select auth.uid() as uid)) and (m.user_b = locations_realtime.user_id))
            or ((m.user_b = ( select auth.uid() as uid)) and (m.user_a = locations_realtime.user_id))))
      ))
    )
  );
