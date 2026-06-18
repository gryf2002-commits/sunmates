-- ============================================================
--  SunMates — MISE À JOUR : photo de profil (Supabase Storage)
--  À coller dans Supabase : menu de gauche > SQL Editor > New query > Run
--  Rejouable sans risque. Ne supprime aucune donnée.
-- ============================================================

-- 1) Colonne pour l'URL de la photo de profil
alter table profiles add column if not exists avatar_url text;

-- 2) Bucket de stockage public "avatars" (les photos sont en lecture publique)
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- 3) Règles d'accès au stockage (sur storage.objects)
--    Lecture : tout le monde peut voir les avatars (bucket public).
drop policy if exists "Avatars - lecture publique" on storage.objects;
create policy "Avatars - lecture publique"
  on storage.objects for select to public
  using (bucket_id = 'avatars');

--    Écriture : je ne peux déposer/modifier/supprimer QUE dans mon dossier
--    (le chemin du fichier commence par mon identifiant utilisateur).
drop policy if exists "Avatars - j envoie ma photo" on storage.objects;
create policy "Avatars - j envoie ma photo"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Avatars - je modifie ma photo" on storage.objects;
create policy "Avatars - je modifie ma photo"
  on storage.objects for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Avatars - je supprime ma photo" on storage.objects;
create policy "Avatars - je supprime ma photo"
  on storage.objects for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

-- ✅ Terminé. Tu peux maintenant ajouter ta photo de profil depuis l'app.
