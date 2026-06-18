-- ============================================================
-- SunMates — « Mon voyage » v2 : matching par DISTANCE (en plus du nom de ville)
-- ============================================================
-- Gère « Lisbonne » vs « Lisbon » : si les deux voyages ont des coordonnées (géocodées
-- à l'ajout), on matche quand ils sont à moins de ~40 km ; sinon repli sur le nom exact.
-- Haversine en SQL pur (aucune extension). create or replace → remplace la v1. Idempotent.
-- À exécuter dans le SQL Editor de Supabase.
-- ============================================================

create or replace function overlapping_travelers()
returns table (trip_id bigint, user_id uuid, city text, country text, start_date date, end_date date)
language sql security definer set search_path = public as $$
  select t.id, t.user_id, t.city, t.country, t.start_date, t.end_date
  from trips t
  join trips me on me.user_id = auth.uid()
  where t.user_id <> auth.uid()
    and (
      lower(trim(t.city)) = lower(trim(me.city))                       -- même nom de ville
      or (
        t.lat is not null and t.lng is not null and me.lat is not null and me.lng is not null
        and 6371 * acos(least(1, greatest(-1,
              sin(radians(me.lat)) * sin(radians(t.lat))
              + cos(radians(me.lat)) * cos(radians(t.lat)) * cos(radians(t.lng - me.lng))
            ))) < 40                                                    -- ... ou à moins de ~40 km
      )
    )
    and t.start_date <= me.end_date
    and t.end_date   >= me.start_date                                   -- chevauchement de dates
    and t.end_date   >= current_date                                   -- pas de voyages passés
    and not exists (select 1 from profiles p where p.id = t.user_id and coalesce(p.banned,false) = true)
  order by t.start_date;
$$;
grant execute on function overlapping_travelers() to authenticated;

-- ============================================================
-- Fin. Le front géocode la ville à l'ajout (Nominatim) → lat/lng/pays remplis.
-- ============================================================
