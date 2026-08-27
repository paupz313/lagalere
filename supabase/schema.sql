-- La Galère — schéma Supabase
-- À exécuter dans l'éditeur SQL du projet Supabase (ou via `supabase db push`
-- si vous utilisez la Supabase CLI avec un projet lié).

-- Extension pour la génération d'UUID (activée par défaut sur la plupart des
-- projets Supabase récents, mais on s'assure qu'elle l'est).
create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Table des dossiers (témoignages)
-- ---------------------------------------------------------------------------
create table if not exists public.dossiers (
  id uuid primary key default gen_random_uuid(),
  no text not null,
  cat text not null,
  title text not null,
  body text not null,
  author text not null default 'Anonyme',
  created_at timestamptz not null default now()
);

comment on table public.dossiers is 'Témoignages soumis par les citoyens.';

alter table public.dossiers enable row level security;

-- Lecture publique : tout le monde peut voir les dossiers.
create policy "dossiers_select_public"
  on public.dossiers for select
  to anon, authenticated
  using (true);

-- Écriture publique : tout visiteur peut déposer un dossier.
-- (La modération se fait a posteriori — voir le doc projet "checklist mise en ligne".)
create policy "dossiers_insert_public"
  on public.dossiers for insert
  to anon, authenticated
  with check (
    char_length(title) between 1 and 90
    and char_length(body) between 1 and 600
    and char_length(coalesce(author, '')) <= 40
  );

-- Pas de policy update/delete pour anon/authenticated : seule la clé
-- "service_role" (utilisée côté serveur / dashboard, jamais dans le
-- navigateur) peut modifier ou supprimer un dossier. C'est ce qui sert de
-- modération.

-- ---------------------------------------------------------------------------
-- Table des votes ("tampons de solidarité")
-- ---------------------------------------------------------------------------
create table if not exists public.votes (
  dossier_id uuid not null references public.dossiers(id) on delete cascade,
  voter_id text not null,
  created_at timestamptz not null default now(),
  primary key (dossier_id, voter_id)
);

comment on table public.votes is 'Un vote = une ligne. La clé primaire (dossier_id, voter_id) empêche un même voter_id de voter deux fois sur le même dossier.';

alter table public.votes enable row level security;

create policy "votes_select_public"
  on public.votes for select
  to anon, authenticated
  using (true);

create policy "votes_insert_public"
  on public.votes for insert
  to anon, authenticated
  with check (char_length(voter_id) between 1 and 64);

-- Vue pratique : nombre de votes par dossier.
create or replace view public.dossier_votes as
  select dossier_id, count(*)::int as votes
  from public.votes
  group by dossier_id;

-- ---------------------------------------------------------------------------
-- Données de démonstration (FACULTATIF)
-- ---------------------------------------------------------------------------
-- Les 8 témoignages ci-dessous sont FICTIFS — écrits comme exemples pendant
-- le prototypage. Ne les insérez que pour un environnement de test/démo.
-- Pour un vrai lancement public, laissez cette section commentée (ou
-- supprimez ces lignes une fois de vrais témoignages arrivés) : présenter du
-- contenu inventé comme si c'étaient de vrais témoignages induirait les
-- premiers visiteurs en erreur.
--
-- insert into public.dossiers (no, cat, title, body, author, created_at) values
-- ('N°26-041207', 'Transport & permis', 'La carte grise que je n''ai jamais eue, sauf sur le PV', 'J''ai vendu ma voiture en 2023...', 'ExPropriétaireDeLA-812-XY', '2026-07-14'),
-- ('N°26-033981', 'Impôts & fiscalité', 'Deux avis d''imposition, deux montants, un seul contribuable', 'Reçu le même jour deux avis d''imposition différents...', 'PatateDuFisc', '2026-06-02');
