-- ============================================================================
-- SunMates — recherche de pseudo INSENSIBLE AUX ACCENTS (feature phare P1.8)
-- Le ilike de Postgres distingue « José » de « jose » → on normalise avec
-- l'extension unaccent + lower() des deux côtés. RPC sécurisée (bannis exclus,
-- profils privés exclus du résultat public sauf si déjà public).
-- À exécuter dans le SQL Editor de Supabase.
-- ============================================================================

create extension if not exists unaccent;

-- Recherche par pseudo (ou début de pseudo), tolérante aux accents et à la casse.
create or replace function search_profiles(q text, p_limit int default 8)
returns table (id uuid, username text, avatar_url text, city text, is_verified boolean)
language sql
stable
security definer
set search_path = public, extensions
as $$
  select p.id, p.username, p.avatar_url, p.city, p.is_verified
  from profiles p
  where coalesce(p.banned, false) = false
    and coalesce(p.username, '') <> ''
    and unaccent(lower(p.username)) like ('%' || unaccent(lower(q)) || '%')
  order by
    -- ceux qui COMMENCENT par la recherche d'abord (plus pertinent)
    case when unaccent(lower(p.username)) like (unaccent(lower(q)) || '%') then 0 else 1 end,
    length(p.username),
    p.username
  limit greatest(1, least(coalesce(p_limit, 8), 25));
$$;

grant execute on function search_profiles(text, int) to anon, authenticated;
