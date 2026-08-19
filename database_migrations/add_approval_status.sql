-- Migration: Add approval_status column to startup_profiles and investor_profiles
-- Date: 2026-08-19
-- Description: Adds approval_status field to track admin approval workflow

-- Add approval_status to startup_profiles
ALTER TABLE public.startup_profiles 
ADD COLUMN IF NOT EXISTS approval_status TEXT NOT NULL DEFAULT 'pending'
CHECK (approval_status IN ('pending', 'approved', 'rejected'));

-- Add index for faster queries on approval_status
CREATE INDEX IF NOT EXISTS idx_startup_profiles_approval_status 
ON public.startup_profiles(approval_status);

-- Add approval_status to investor_profiles (if table exists)
ALTER TABLE public.investor_profiles 
ADD COLUMN IF NOT EXISTS approval_status TEXT NOT NULL DEFAULT 'pending'
CHECK (approval_status IN ('pending', 'approved', 'rejected'));

-- Add index for faster queries on approval_status
CREATE INDEX IF NOT EXISTS idx_investor_profiles_approval_status 
ON public.investor_profiles(approval_status);

-- Update existing records to 'approved' status (so they continue to work)
UPDATE public.startup_profiles 
SET approval_status = 'approved' 
WHERE approval_status = 'pending';

UPDATE public.investor_profiles 
SET approval_status = 'approved' 
WHERE approval_status = 'pending';

-- Optional: Add a timestamp for when approval/rejection happened
ALTER TABLE public.startup_profiles 
ADD COLUMN IF NOT EXISTS approval_date TIMESTAMPTZ;

ALTER TABLE public.investor_profiles 
ADD COLUMN IF NOT EXISTS approval_date TIMESTAMPTZ;

-- Add comment to document the approval_status field
COMMENT ON COLUMN public.startup_profiles.approval_status IS 
'Admin approval status: pending (default for new signups), approved (can use app), rejected (denied access)';

COMMENT ON COLUMN public.investor_profiles.approval_status IS 
'Admin approval status: pending (default for new signups), approved (can use app), rejected (denied access)';
