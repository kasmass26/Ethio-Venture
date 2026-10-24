
-- ============================================================
-- Ethio Venture
-- Verified Profiles: Verification Requests
-- ============================================================

create table public.verification_requests (
  id uuid primary key default gen_random_uuid(),

  -- The authenticated user who owns this request.
  user_id uuid not null
    references auth.users(id) on delete cascade,

  -- Must match VerificationType.value in Flutter.
  verification_type text not null
    check (
      verification_type in ('student', 'identity', 'business', 'investor')
    ),

  -- Backend-controlled verification status.
  status text not null default 'pending'
    check (
      status in (
        'pending',
        'approved',
        'rejected',
        'resubmission_required',
        'additional_info_required'
      )
    ),

  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,

  -- Safe, user-facing reviewer message. Never store raw AI output here.
  message text,

  -- Null means no confirmed resubmission decision.
  resubmission_allowed boolean,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint verification_requests_review_time_check
    check (reviewed_at is null or reviewed_at >= submitted_at)
);

-- Useful for retrieving a user's requests in chronological order.
create index verification_requests_user_submitted_idx
  on public.verification_requests (user_id, submitted_at desc);

-- Useful for authorized review workflows.
create index verification_requests_status_idx
  on public.verification_requests (status);

-- ============================================================
-- Row Level Security
-- ============================================================

alter table public.verification_requests enable row level security;

-- Users can read their own verification request metadata.
create policy "verification_requests_select_own"
on public.verification_requests
for select
to authenticated
using ((select auth.uid()) = user_id);

-- Users can submit requests only for themselves.
create policy "verification_requests_insert_own"
on public.verification_requests
for insert
to authenticated
with check (
  (select auth.uid()) = user_id
  and status = 'pending'
  and reviewed_at is null
);

-- Intentionally no user UPDATE or DELETE policies.
-- Approval and rejection must be handled by a separately authorized
-- backend review workflow, not by the requesting user.

-- ============================================================
-- End of migration
-- ============================================================
