-- ============================================================
-- Ethio Venture
-- Verified Profiles: document metadata table, storage policies,
-- and duplicate-pending-request constraint.
--
-- Prerequisites:
--   • 20261024_create_verification_requests.sql must be applied.
--   • A private Storage bucket named 'verification-documents'
--     must be created manually via the Supabase Dashboard
--     (Storage → New bucket → Private, max size 10 MB,
--      allowed MIME types: image/jpeg,image/png,application/pdf).
--     This migration defines the row-level policies for that bucket.
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. VERIFICATION DOCUMENTS — metadata table
-- ────────────────────────────────────────────────────────────

create table if not exists public.verification_documents (
  id uuid primary key default gen_random_uuid(),

  -- The verification request this document belongs to.
  request_id uuid not null
    references public.verification_requests(id) on delete cascade,

  -- Denormalized owner for fast RLS evaluation without a JOIN.
  -- Must match verification_requests.user_id for the same request.
  user_id uuid not null
    references auth.users(id) on delete cascade,

  -- Private Storage object path: {user_id}/{request_id}/{filename}
  -- Never expose this path directly; use signed URLs only.
  storage_path text not null,

  -- Original filename provided by the user (cosmetic only).
  original_filename text not null,

  -- MIME type validated before upload ('image/jpeg','image/png','application/pdf').
  mime_type text not null
    check (mime_type in ('image/jpeg', 'image/png', 'application/pdf')),

  -- File size in bytes, enforced ≤ 10 MB (10 485 760 bytes).
  file_size_bytes bigint not null
    check (file_size_bytes > 0 and file_size_bytes <= 10485760),

  created_at timestamptz not null default now(),

  -- One document per request (single-evidence design for v1).
  constraint verification_documents_request_unique unique (request_id)
);

-- Index for lookups by owner (used by RLS and data source).
create index if not exists verification_documents_user_idx
  on public.verification_documents (user_id);

-- ────────────────────────────────────────────────────────────
-- 2. ROW LEVEL SECURITY — verification_documents
-- ────────────────────────────────────────────────────────────

alter table public.verification_documents enable row level security;

-- Owner can read their own document metadata.
create policy "verification_documents_select_own"
  on public.verification_documents
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

-- Owner can insert, but only for a request that belongs to them.
create policy "verification_documents_insert_own"
  on public.verification_documents
  for insert
  to authenticated
  with check (
    (select auth.uid()) = user_id
    and exists (
      select 1
      from public.verification_requests vr
      where vr.id = request_id
        and vr.user_id = (select auth.uid())
    )
  );

-- Intentionally no UPDATE or DELETE policies for users.
-- Document evidence is immutable once submitted; replacements
-- require a new verification request per the review workflow.

-- ────────────────────────────────────────────────────────────
-- 3. DUPLICATE-PENDING-REQUEST PREVENTION
--    Prevents a user from having two pending requests of the
--    same verification_type simultaneously without blocking
--    legitimate resubmissions (non-pending rows are ignored).
-- ────────────────────────────────────────────────────────────

create unique index if not exists
  verification_requests_user_type_pending_unique_idx
  on public.verification_requests (user_id, verification_type)
  where (status = 'pending');

-- ────────────────────────────────────────────────────────────
-- 4. STORAGE RLS POLICIES — verification-documents bucket
--
--    These policies target the Supabase Storage object table.
--    Path convention:  {user_id}/{request_id}/{sanitized_filename}
--    The first path segment (foldername[1]) equals the owner's UUID.
-- ────────────────────────────────────────────────────────────

-- Allow authenticated users to upload only to their own folder.
create policy "verification_documents_storage_insert"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'verification-documents'
    and (select auth.uid())::text = (storage.foldername(name))[1]
  );

-- Allow authenticated users to read only their own objects.
create policy "verification_documents_storage_select"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'verification-documents'
    and (select auth.uid())::text = (storage.foldername(name))[1]
  );

-- No UPDATE or DELETE policies; orphan cleanup is a server-side concern.

-- ============================================================
-- End of migration
-- ============================================================
