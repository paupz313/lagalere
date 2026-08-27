-- La Galère — schéma Supabase
-- À exécuter dans l'éditeur SQL du projet Supabase (ou via `supabase db push`
-- si vous utilisez la Supabase CLI avec un projet lié).
--
-- Ce schéma exige un compte (Supabase Auth) pour déposer un dossier ou voter :
-- la lecture reste publique, mais l'écriture est réservée aux utilisateurs
-- authentifiés (voir index.html, connexion par lien magique).

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Dossiers (témoignages)
-- ---------------------------------------------------------------------------
create table if not exists public.dossiers (
  id uuid primary key default gen_random_uuid(),
  no text not null,
  cat text not null,
  title text not null,
  body text not null,
  author text not null default 'Anonyme',
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

comment on table public.dossiers is 'Témoignages soumis par des utilisateurs authentifiés.';

alter table public.dossiers enable row level security;

-- Lecture publique : tout le monde peut voir les dossiers.
create policy "dossiers_select_public"
  on public.dossiers for select
  to anon, authenticated
  using (true);

-- Écriture réservée aux utilisateurs connectés (compte requis).
create policy "dossiers_insert_authenticated"
  on public.dossiers for insert
  to authenticated
  with check (
    user_id = auth.uid()
    and char_length(title) between 1 and 90
    and char_length(body) between 1 and 600
    and char_length(coalesce(author, '')) <= 40
  );

-- Pas de policy update/delete pour anon/authenticated : seule la clé
-- "service_role" (utilisée côté serveur / dashboard, jamais dans le
-- navigateur) peut modifier ou supprimer un dossier. C'est ce qui sert de
-- modération.

-- ---------------------------------------------------------------------------
-- Votes ("tampons de solidarité")
-- ---------------------------------------------------------------------------
create table if not exists public.votes (
  dossier_id uuid not null references public.dossiers(id) on delete cascade,
  voter_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (dossier_id, voter_id)
);

comment on table public.votes is 'Un vote = une ligne, liée à un compte authentifié. La clé primaire (dossier_id, voter_id) empêche un même compte de voter deux fois sur le même dossier.';

alter table public.votes enable row level security;

create policy "votes_select_public"
  on public.votes for select
  to anon, authenticated
  using (true);

create policy "votes_insert_authenticated"
  on public.votes for insert
  to authenticated
  with check (voter_id = auth.uid());

-- Vue pratique : nombre de votes par dossier.
create or replace view public.dossier_votes as
  select dossier_id, count(*)::int as votes
  from public.votes
  group by dossier_id;

-- ---------------------------------------------------------------------------
-- Données de démonstration (FACULTATIF)
-- ---------------------------------------------------------------------------
-- Ne pas insérer en production : présenter du contenu inventé comme si
-- c'étaient de vrais témoignages induirait les premiers visiteurs en erreur.
-- Chaque ligne demanderait de toute façon un user_id valide (compte réel)
-- puisque la colonne est obligatoire.
