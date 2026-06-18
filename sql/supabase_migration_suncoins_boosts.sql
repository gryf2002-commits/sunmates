-- ============================================================================
-- SunMates — SunCoins : les BOOSTS (2e usage de la monnaie, P2.17).
-- Dépend de supabase_migration_suncoins.sql (colonne profiles.coins).
-- Flagship : "🚀 Coup de projecteur" → profil mis en avant 24 h dans Découvrir.
-- Achat ATOMIQUE (déduit les coins + applique l'effet en une transaction).
-- À exécuter dans le SQL Editor de Supabase.
-- ============================================================================

alter table profiles add column if not exists boosted_until timestamptz;

create or replace function sm_buy_boost(p_boost text, p_cost int)
returns table (ok boolean, balance int, message text)
language plpgsql
security definer
set search_path = public
as $$
declare uid uuid := auth.uid(); bal int;
begin
  if uid is null then return query select false, 0, 'Non connecté'; return; end if;
  if p_cost is null or p_cost < 0 then return query select false, 0, 'Coût invalide'; return; end if;
  select coins into bal from profiles where id = uid for update;
  if bal is null then return query select false, 0, 'Profil introuvable'; return; end if;
  if bal < p_cost then return query select false, bal, 'Pas assez de SunCoins'; return; end if;

  if p_boost = 'spotlight' then
    -- Cumulable : si déjà en vedette, on prolonge de 24 h ; sinon 24 h à partir de maintenant.
    update profiles
       set coins = coins - p_cost,
           boosted_until = greatest(coalesce(boosted_until, now()), now()) + interval '24 hours'
     where id = uid;
  else
    return query select false, bal, 'Boost inconnu'; return;
  end if;

  select coins into bal from profiles where id = uid;
  return query select true, bal, 'ok';
end;
$$;

grant execute on function sm_buy_boost(text, int) to authenticated;
