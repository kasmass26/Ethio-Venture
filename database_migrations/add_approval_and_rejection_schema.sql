-- ==============================================================================
-- Migration: Add approval_status, rejection_reason, and approval_date
-- Description: Adds approval workflow columns to startup_profiles and investor_profiles
-- ==============================================================================

-- 1. STARTUP PROFILES TABLE
-- Add approval_status column
ALTER TABLE public.startup_profiles 
ADD COLUMN IF NOT EXISTS approval_status TEXT NOT NULL DEFAULT 'pending'
CHECK (approval_status IN ('pending', 'approved', 'rejected'));

-- Add rejection_reason column
ALTER TABLE public.startup_profiles 
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- Add approval_date column
ALTER TABLE public.startup_profiles 
ADD COLUMN IF NOT EXISTS approval_date TIMESTAMPTZ;

-- Index for fast queries on approval_status
CREATE INDEX IF NOT EXISTS idx_startup_profiles_approval_status 
ON public.startup_profiles(approval_status);


-- 2. INVESTOR PROFILES TABLE
-- Add approval_status column
ALTER TABLE public.investor_profiles 
ADD COLUMN IF NOT EXISTS approval_status TEXT NOT NULL DEFAULT 'pending'
CHECK (approval_status IN ('pending', 'approved', 'rejected'));

-- Add rejection_reason column
ALTER TABLE public.investor_profiles 
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- Add approval_date column
ALTER TABLE public.investor_profiles 
ADD COLUMN IF NOT EXISTS approval_date TIMESTAMPTZ;

-- Index for fast queries on approval_status
CREATE INDEX IF NOT EXISTS idx_investor_profiles_approval_status 
ON public.investor_profiles(approval_status);


-- 3. COMMENTS FOR DOCUMENTATION
COMMENT ON COLUMN public.startup_profiles.approval_status IS 
'Admin approval status: pending (awaiting review), approved (live on platform), rejected (denied with rejection_reason)';

COMMENT ON COLUMN public.startup_profiles.rejection_reason IS 
'Explanation provided by admin when application is rejected';

COMMENT ON COLUMN public.startup_profiles.approval_date IS 
'Timestamp of the latest approval or rejection action';

COMMENT ON COLUMN public.investor_profiles.approval_status IS 
'Admin approval status: pending (awaiting review), approved (live on platform), rejected (denied with rejection_reason)';

COMMENT ON COLUMN public.investor_profiles.rejection_reason IS 
'Explanation provided by admin when application is rejected';

COMMENT ON COLUMN public.investor_profiles.approval_date IS 
'Timestamp of the latest approval or rejection action';
