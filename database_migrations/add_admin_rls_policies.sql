<<<<<<< HEAD
-- ==============================================================================
-- Migration: Admin RLS Policies for Approval Workflow
-- Description: Allows the admin user to read and update approval status on ALL
--              startup_profiles and investor_profiles. Without these policies,
--              the admin's update calls are silently blocked by RLS.
-- Date: 2026-08-20
-- How to apply: Run this in Supabase Dashboard > SQL Editor
-- ==============================================================================

-- Helper function: check if the current user is the admin by email
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM auth.users
    WHERE id = auth.uid()
      AND email = 'admin@gmail.com'
  );
$$;

-- ==============================================================================
-- startup_profiles: Admin RLS Policies
-- ==============================================================================

-- Allow admin to SELECT all startup profiles (needed to list them in dashboard)
DROP POLICY IF EXISTS "admin_startup_profiles_select_all" ON public.startup_profiles;
CREATE POLICY "admin_startup_profiles_select_all"
ON public.startup_profiles
FOR SELECT
TO authenticated
USING (public.is_admin());

-- Allow admin to UPDATE approval fields on any startup profile
DROP POLICY IF EXISTS "admin_startup_profiles_update_approval" ON public.startup_profiles;
CREATE POLICY "admin_startup_profiles_update_approval"
ON public.startup_profiles
FOR UPDATE
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- ==============================================================================
-- investor_profiles: Admin RLS Policies
-- ==============================================================================

-- Allow admin to SELECT all investor profiles (needed to list them in dashboard)
DROP POLICY IF EXISTS "admin_investor_profiles_select_all" ON public.investor_profiles;
CREATE POLICY "admin_investor_profiles_select_all"
ON public.investor_profiles
FOR SELECT
TO authenticated
USING (public.is_admin());

-- Allow admin to UPDATE approval fields on any investor profile
DROP POLICY IF EXISTS "admin_investor_profiles_update_approval" ON public.investor_profiles;
CREATE POLICY "admin_investor_profiles_update_approval"
ON public.investor_profiles
FOR UPDATE
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- ==============================================================================
-- users table: Allow admin to SELECT all user records (for join queries)
-- ==============================================================================

DROP POLICY IF EXISTS "admin_users_select_all" ON public.users;
CREATE POLICY "admin_users_select_all"
ON public.users
FOR SELECT
TO authenticated
USING (public.is_admin());

-- ==============================================================================
-- VERIFY: Check that policies were created correctly
-- ==============================================================================
-- SELECT schemaname, tablename, policyname, cmd, qual, with_check
-- FROM pg_policies
-- WHERE tablename IN ('startup_profiles', 'investor_profiles', 'users')
--   AND policyname LIKE 'admin_%'
-- ORDER BY tablename, policyname;
=======
-- ============================================================
-- SQL Migration: Enable Public / Admin Read Policies for Admin Panel
-- ============================================================

-- 1. Allow public select on investor_profiles so investors can be discovered and audited
DROP POLICY IF EXISTS investor_profiles_select_public ON investor_profiles;
CREATE POLICY investor_profiles_select_public ON investor_profiles FOR SELECT USING (true);

-- 2. Allow public/admin select on conversations for admin moderation
DROP POLICY IF EXISTS conversations_select_public ON conversations;
CREATE POLICY conversations_select_public ON conversations FOR SELECT USING (true);

-- 3. Allow public/admin select on messages for admin moderation
DROP POLICY IF EXISTS messages_select_public ON messages;
CREATE POLICY messages_select_public ON messages FOR SELECT USING (true);

-- 4. Allow public/admin select on users for directory management
DROP POLICY IF EXISTS users_select_public ON users;
CREATE POLICY users_select_public ON users FOR SELECT USING (true);
>>>>>>> 46bf1ef76599389cae76cbcf0783b42957d6749a
