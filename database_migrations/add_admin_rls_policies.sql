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
