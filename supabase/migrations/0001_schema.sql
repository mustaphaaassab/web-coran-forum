-- Schéma initial : profils, groupes, membres, récitations.
-- RLS (Row Level Security) de base : à affiner au fur et à mesure des règles de gestion.

-- ===================== PROFILS (étend auth.users) =====================

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nom_complet text not null,
  role text not null default 'membre' check (role in ('admin', 'professeur', 'membre')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Fonction utilitaire (security definer) pour éviter la récursion RLS sur profiles.
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  );
$$;

create policy "profiles_select_own_or_admin"
  on public.profiles for select
  using (id = auth.uid() or public.is_admin());

create policy "profiles_update_own"
  on public.profiles for update
  using (id = auth.uid());

-- Création automatique du profil à l'inscription (trigger sur auth.users).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, nom_complet)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'nom_complet', new.email));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ===================== GROUPES DE RÉCITATION =====================

create table if not exists public.groupes (
  id bigint generated always as identity primary key,
  nom text not null,
  professeur_id uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.groupes enable row level security;

create policy "groupes_select_authenticated"
  on public.groupes for select
  to authenticated
  using (true);

create policy "groupes_write_admin"
  on public.groupes for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- ===================== APPARTENANCE AUX GROUPES (many-to-many) =====================

create table if not exists public.groupe_membres (
  groupe_id bigint not null references public.groupes (id) on delete cascade,
  membre_id uuid not null references public.profiles (id) on delete cascade,
  date_adhesion timestamptz not null default now(),
  primary key (groupe_id, membre_id)
);

alter table public.groupe_membres enable row level security;

create policy "groupe_membres_select_authenticated"
  on public.groupe_membres for select
  to authenticated
  using (true);

create policy "groupe_membres_write_admin_or_self"
  on public.groupe_membres for all
  to authenticated
  using (public.is_admin() or membre_id = auth.uid())
  with check (public.is_admin() or membre_id = auth.uid());

-- ===================== RÉFÉRENTIEL CORANIQUE =====================

create table if not exists public.sourates (
  id smallint primary key,
  nom text not null
);

create table if not exists public.hizbs (
  id smallint primary key
);

-- Le tomon est l'unité de base : 1/8 de hizb => 60 * 8 = 480 tomons.
create table if not exists public.tomons (
  id smallint primary key,
  hizb_id smallint not null references public.hizbs (id),
  position_dans_hizb smallint not null check (position_dans_hizb between 1 and 8)
);

-- Un tomon peut être partagé entre deux sourates (S1/S2) : chacune compte alors
-- pour une demi-part (fraction = 0.5). Un tomon entièrement dans une seule
-- sourate a une seule ligne avec fraction = 1.
-- IMPORTANT : cette table doit être peuplée avec les données exactes de
-- l'ancienne application (la subdivision en 1/8 de hizb n'est pas un découpage
-- standard publié, c'est une convention propre à l'application existante).
create table if not exists public.tomon_sourate (
  tomon_id smallint not null references public.tomons (id),
  sourate_id smallint not null references public.sourates (id),
  fraction numeric(3, 2) not null check (fraction in (0.5, 1.0)),
  primary key (tomon_id, sourate_id)
);

alter table public.sourates enable row level security;
alter table public.hizbs enable row level security;
alter table public.tomons enable row level security;
alter table public.tomon_sourate enable row level security;

create policy "referentiel_lecture_publique_sourates"
  on public.sourates for select using (true);
create policy "referentiel_lecture_publique_hizbs"
  on public.hizbs for select using (true);
create policy "referentiel_lecture_publique_tomons"
  on public.tomons for select using (true);
create policy "referentiel_lecture_publique_tomon_sourate"
  on public.tomon_sourate for select using (true);

-- ===================== RÉCITATIONS =====================

create table if not exists public.recitations (
  id bigint generated always as identity primary key,
  membre_id uuid not null references public.profiles (id) on delete cascade,
  groupe_id bigint not null references public.groupes (id) on delete cascade,
  tomon_id smallint not null references public.tomons (id),
  type text not null check (type in ('ancienne', 'nouvelle')),
  date_recitation date,
  created_at timestamptz not null default now(),
  constraint date_obligatoire_si_nouvelle
    check (type <> 'nouvelle' or date_recitation is not null)
);

alter table public.recitations enable row level security;

create policy "recitations_select_own_or_group_staff"
  on public.recitations for select
  to authenticated
  using (
    membre_id = auth.uid()
    or public.is_admin()
    or exists (
      select 1 from public.groupes g
      where g.id = recitations.groupe_id and g.professeur_id = auth.uid()
    )
  );

create policy "recitations_insert_own"
  on public.recitations for insert
  to authenticated
  with check (membre_id = auth.uid());

create policy "recitations_update_own"
  on public.recitations for update
  to authenticated
  using (membre_id = auth.uid())
  with check (membre_id = auth.uid());

create policy "recitations_delete_own_or_admin"
  on public.recitations for delete
  to authenticated
  using (membre_id = auth.uid() or public.is_admin());
