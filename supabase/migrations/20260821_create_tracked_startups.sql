-- 1. Create the tracked_startups table
CREATE TABLE IF NOT EXISTS public.tracked_startups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    investor_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    startup_id UUID NOT NULL REFERENCES public.startup_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(investor_user_id, startup_id)
);

-- 2. Indexes for efficient lookup
CREATE INDEX IF NOT EXISTS idx_tracked_startups_investor ON public.tracked_startups(investor_user_id);
CREATE INDEX IF NOT EXISTS idx_tracked_startups_startup ON public.tracked_startups(startup_id);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.tracked_startups ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies
-- Allow investors to view only their own tracked startups
CREATE POLICY "Investors can view their own tracked startups"
ON public.tracked_startups FOR SELECT
USING (auth.uid() = investor_user_id);

-- Allow investors to insert their own tracked startups
CREATE POLICY "Investors can insert their own tracked startups"
ON public.tracked_startups FOR INSERT
WITH CHECK (auth.uid() = investor_user_id);

-- Allow investors to delete (untrack) their own tracked startups
CREATE POLICY "Investors can delete their own tracked startups"
ON public.tracked_startups FOR DELETE
USING (auth.uid() = investor_user_id);
