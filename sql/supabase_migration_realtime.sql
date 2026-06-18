-- ============================================================
-- SunMates — Activer le Realtime (temps réel) sur les tables clés
-- ============================================================
-- Dans les nouvelles versions de Supabase, l'onglet « Replication » a disparu :
-- le temps réel s'active en ajoutant les tables à la publication « supabase_realtime ».
-- → messages instantanés, demandes de connexion, fil, défis, réactions en live.
-- À exécuter dans le SQL Editor de Supabase. Idempotent (rejouable sans risque).
-- ============================================================

-- La publication existe déjà sur tout projet Supabase ; on s'assure qu'elle est là.
do $$
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    create publication supabase_realtime;
  end if;
end $$;

-- On ajoute chaque table SI elle n'y est pas déjà (évite l'erreur « already member »).
do $$
declare
  t text;
  wanted text[] := array[
    'messages',
    'matches_connections',
    'feed_posts',
    'feed_likes',
    'feed_comments',
    'message_reactions',
    'suggestions',
    'locations_realtime'
  ];
begin
  foreach t in array wanted loop
    -- la table doit exister dans public
    if exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = t) then
      -- ... et ne pas être déjà dans la publication
      if not exists (
        select 1 from pg_publication_tables
        where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
      ) then
        execute format('alter publication supabase_realtime add table public.%I', t);
        raise notice 'Realtime activé sur %', t;
      end if;
    end if;
  end loop;
end $$;

-- Vérif : liste les tables désormais en temps réel.
select tablename as table_temps_reel
from pg_publication_tables
where pubname = 'supabase_realtime' and schemaname = 'public'
order by tablename;

-- ============================================================
-- Fin. Si une table n'apparaît pas dans le résultat, c'est qu'elle n'existe pas
-- encore (lance d'abord la migration qui la crée). Rejoue ce script ensuite.
-- ============================================================
