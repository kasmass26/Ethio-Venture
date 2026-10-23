-- Migration: Create pitch_analyses table and policies for AI Pitch Analysis
-- Date: 2026-10-23
-- Description: Stores investor-grade AI evaluations, scores, feedback and recommendations for startup pitch decks.

CREATE TABLE IF NOT EXISTS public.pitch_analyses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES public.documents(id) ON DELETE CASCADE,
  startup_id UUID NOT NULL REFERENCES public.startup_profiles(id) ON DELETE CASCADE,
  overall_score INTEGER NOT NULL CHECK (overall_score >= 0 AND overall_score <= 100),
  readiness_tier TEXT NOT NULL DEFAULT 'Promising',
  executive_summary TEXT NOT NULL,
  category_scores JSONB NOT NULL DEFAULT '{}'::jsonb,
  strengths JSONB NOT NULL DEFAULT '[]'::jsonb,
  weaknesses JSONB NOT NULL DEFAULT '[]'::jsonb,
  recommendations JSONB NOT NULL DEFAULT '[]'::jsonb,
  ethiopian_market_fit TEXT,
  analyzed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for lightning fast lookups
CREATE INDEX IF NOT EXISTS idx_pitch_analyses_document_id ON public.pitch_analyses(document_id);
CREATE INDEX IF NOT EXISTS idx_pitch_analyses_startup_id ON public.pitch_analyses(startup_id);
CREATE INDEX IF NOT EXISTS idx_pitch_analyses_analyzed_at ON public.pitch_analyses(analyzed_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.pitch_analyses ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to view analyses of documents they have access to
CREATE POLICY "Allow read pitch analysis"
ON public.pitch_analyses
FOR SELECT
TO authenticated
USING (
  -- Founder owns the startup
  startup_id IN (
    SELECT id FROM public.startup_profiles WHERE user_id = auth.uid()
  )
  OR
  -- Or document is public
  document_id IN (
    SELECT id FROM public.documents WHERE is_private = false
  )
);

-- Allow founders to insert pitch analyses for their own startups
CREATE POLICY "Allow founders insert pitch analysis"
ON public.pitch_analyses
FOR INSERT
TO authenticated
WITH CHECK (
  startup_id IN (
    SELECT id FROM public.startup_profiles WHERE user_id = auth.uid()
  )
);

-- Allow founders to update/refresh pitch analysis for their own startups
CREATE POLICY "Allow founders update pitch analysis"
ON public.pitch_analyses
FOR UPDATE
TO authenticated
USING (
  startup_id IN (
    SELECT id FROM public.startup_profiles WHERE user_id = auth.uid()
  )
);

-- Allow founders to delete pitch analysis for their own startups
CREATE POLICY "Allow founders delete pitch analysis"
ON public.pitch_analyses
FOR DELETE
TO authenticated
USING (
  startup_id IN (
    SELECT id FROM public.startup_profiles WHERE user_id = auth.uid()
  )
);

COMMENT ON TABLE public.pitch_analyses IS 'Stores AI-generated evaluations and improvements for startup pitch decks.';
