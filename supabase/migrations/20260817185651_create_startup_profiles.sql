-- ============================================================
-- Ethio Venture
-- #5 Startup Profile Management
-- ============================================================

create table public.startup_profiles (
  id uuid primary key default gen_random_uuid(),

  -- The authenticated Supabase user who owns this startup profile.
  user_id uuid not null references auth.users(id) on delete cascade,

  -- Basic startup information.
  startup_name text not null,
  description text not null,
  industry text not null,
  funding_stage text not null,

  -- Funding amount requested by the startup.
  funding_amount_needed numeric(15, 2) not null,

  -- Location and team information.
  location text not null,
  team_information text not null,

  -- Contact information.
  contact_information text not null,

  -- Audit timestamps.
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  -- A user can own only one startup profile.
  constraint startup_profiles_user_id_unique unique (user_id),

  -- Funding amount must be positive.
  constraint startup_profiles_funding_amount_positive
    check (funding_amount_needed > 0),

  -- Prevent empty/whitespace-only required text values.
  constraint startup_profiles_name_not_empty
    check (length(trim(startup_name)) > 0),

  constraint startup_profiles_description_not_empty
    check (length(trim(description)) > 0),

  constraint startup_profiles_industry_not_empty
    check (length(trim(industry)) > 0),

  constraint startup_profiles_funding_stage_not_empty
    check (length(trim(funding_stage)) > 0),

  constraint startup_profiles_location_not_empty
    check (length(trim(location)) > 0),

  constraint startup_profiles_team_information_not_empty
    check (length(trim(team_information)) > 0),

  constraint startup_profiles_contact_information_not_empty
    check (length(trim(contact_information)) > 0)
);

-- ============================================================
-- Index
-- ============================================================

create index startup_profiles_industry_idx
  on public.startup_profiles (industry);

create index startup_profiles_funding_stage_idx
  on public.startup_profiles (funding_stage);

-- ============================================================
-- Row Level Security
-- ============================================================

alter table public.startup_profiles enable row level security;

-- A startup user can view their own profile.
create policy "startup_profiles_select_own"
on public.startup_profiles
for select
to authenticated
using (auth.uid() = user_id);

-- A startup user can create a profile only for themselves.
create policy "startup_profiles_insert_own"
on public.startup_profiles
for insert
to authenticated
with check (auth.uid() = user_id);

-- A startup user can update only their own profile.
create policy "startup_profiles_update_own"
on public.startup_profiles
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- A startup user can delete only their own profile.
create policy "startup_profiles_delete_own"
on public.startup_profiles
for delete
to authenticated
using (auth.uid() = user_id);
