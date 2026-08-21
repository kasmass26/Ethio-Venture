-- ==============================================================================
-- Migration: Add rejection_count for 3-attempt resubmission limit
-- Description: Adds rejection_count column to startup_profiles and investor_profiles
-- ==============================================================================

-- 1. STARTUP PROFILES TABLE
ALTER TABLE public.startup_profiles 
ADD COLUMN IF NOT EXISTS rejection_count INT NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.startup_profiles.rejection_count IS 
'Tracks how many times this startup application has been rejected. Maximum allowed is 3.';

-- 2. INVESTOR PROFILES TABLE
ALTER TABLE public.investor_profiles 
ADD COLUMN IF NOT EXISTS rejection_count INT NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.investor_profiles.rejection_count IS 
'Tracks how many times this investor application has been rejected. Maximum allowed is 3.';

-- 3. Set existing rejected profiles to have at least 1 rejection count
UPDATE public.startup_profiles
SET rejection_count = 1
WHERE approval_status = 'rejected' AND rejection_count = 0;

UPDATE public.investor_profiles
SET rejection_count = 1
WHERE approval_status = 'rejected' AND rejection_count = 0;
