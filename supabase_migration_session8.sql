-- ============================================================
--  SunMates — SESSION 8 : « BFF du moment »
--  À coller dans Supabase : SQL Editor > New query > Run. Idempotent.
-- ============================================================

-- Le BFF du moment = un Mate mis en avant sur ton profil.
alter table profiles add column if not exists bff_id uuid references auth.users(id) on delete set null;

-- (La policy "Je modifie seulement mon profil" couvre déjà la mise à jour de bff_id.)
-- ✅ Terminé.
