-- ============================================================
-- RLS for conversations and messages
-- ============================================================
-- Schema column names (authoritative — must match Dart data sources):
--
--   conversations
--     id            uuid  PK
--     startup_id    uuid  → startup_profiles.id
--     investor_id   uuid  → investor_profiles.id
--     created_at    timestamptz
--
--   messages
--     id                uuid  PK
--     conversation_id   uuid  → conversations.id
--     sender_id         uuid  → startup_profiles.id OR investor_profiles.id
--     content           text
--     sent_at           timestamptz
--     read_at           timestamptz  nullable
--
--   startup_profiles
--     id          uuid  PK
--     user_id     uuid  → auth.users.id   (owner link)
--     …
--
--   investor_profiles
--     id          uuid  PK
--     user_id     uuid  → auth.users.id   (owner link)
--     …
--
-- A user participates in a conversation when their startup_profiles.id
-- equals conversations.startup_id, OR their investor_profiles.id equals
-- conversations.investor_id.
--
-- Helper functions are used to avoid repeating the profile-ID lookups
-- inside each policy expression, keeping policies readable and fast.
-- ============================================================

-- ── helper: resolve current user's startup_profiles.id ────────────────────
CREATE OR REPLACE FUNCTION auth_startup_profile_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT id FROM startup_profiles WHERE user_id = auth.uid() LIMIT 1;
$$;

-- ── helper: resolve current user's investor_profiles.id ───────────────────
CREATE OR REPLACE FUNCTION auth_investor_profile_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT id FROM investor_profiles WHERE user_id = auth.uid() LIMIT 1;
$$;

-- ============================================================
-- conversations
-- ============================================================

ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS conversations_select_participant ON conversations;
DROP POLICY IF EXISTS conversations_insert_participant ON conversations;
DROP POLICY IF EXISTS conversations_update_participant ON conversations;
DROP POLICY IF EXISTS conversations_delete_participant ON conversations;

-- SELECT: a user may read a conversation only if they are the startup
-- or investor participant.
CREATE POLICY conversations_select_participant
  ON conversations
  FOR SELECT
  USING (
    startup_id  = auth_startup_profile_id()
    OR investor_id = auth_investor_profile_id()
  );

-- INSERT: the inserting user must be one of the two participants.
-- This prevents users from creating conversations on behalf of others.
CREATE POLICY conversations_insert_participant
  ON conversations
  FOR INSERT
  WITH CHECK (
    startup_id  = auth_startup_profile_id()
    OR investor_id = auth_investor_profile_id()
  );

-- UPDATE / DELETE remain server-controlled; clients may not alter
-- conversation metadata directly.
CREATE POLICY conversations_update_participant
  ON conversations
  FOR UPDATE
  USING (false);

CREATE POLICY conversations_delete_participant
  ON conversations
  FOR DELETE
  USING (false);

-- ============================================================
-- messages
-- ============================================================

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS messages_select_participant ON messages;
DROP POLICY IF EXISTS messages_insert_sender      ON messages;
DROP POLICY IF EXISTS messages_update_none        ON messages;
DROP POLICY IF EXISTS messages_delete_none        ON messages;

-- SELECT: a user may read messages only in conversations they belong to.
CREATE POLICY messages_select_participant
  ON messages
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversations c
      WHERE c.id = messages.conversation_id
        AND (
          c.startup_id  = auth_startup_profile_id()
          OR c.investor_id = auth_investor_profile_id()
        )
    )
  );

-- INSERT: sender_id must be the current user's startup or investor
-- profile ID, AND the user must be a participant in the conversation.
CREATE POLICY messages_insert_sender
  ON messages
  FOR INSERT
  WITH CHECK (
    (
      sender_id = auth_startup_profile_id()
      OR sender_id = auth_investor_profile_id()
    )
    AND EXISTS (
      SELECT 1 FROM conversations c
      WHERE c.id = messages.conversation_id
        AND (
          c.startup_id  = auth_startup_profile_id()
          OR c.investor_id = auth_investor_profile_id()
        )
    )
  );

-- UPDATE / DELETE are disallowed for all users.
CREATE POLICY messages_update_none
  ON messages
  FOR UPDATE
  USING (false);

CREATE POLICY messages_delete_none
  ON messages
  FOR DELETE
  USING (false);

-- ============================================================
-- startup_profiles
-- ============================================================
-- Any authenticated user may read all startup profiles (needed by the
-- recommendations / matching feature).
-- Only the owning founder may write their own startup profile.

ALTER TABLE startup_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS startup_profiles_select_any    ON startup_profiles;
DROP POLICY IF EXISTS startup_profiles_select_own    ON startup_profiles;
DROP POLICY IF EXISTS startup_profiles_insert_owner  ON startup_profiles;
DROP POLICY IF EXISTS startup_profiles_update_owner  ON startup_profiles;
DROP POLICY IF EXISTS startup_profiles_delete_owner  ON startup_profiles;
-- Drop stale policies that used the old profile_id / status column names.
DROP POLICY IF EXISTS startup_profiles_select_published ON startup_profiles;

-- SELECT: all authenticated users can read startup profiles so investors
-- receive recommendations.
CREATE POLICY startup_profiles_select_any
  ON startup_profiles
  FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- INSERT / UPDATE / DELETE: only the owner (user_id = auth.uid()) may
-- modify their own startup profile.
CREATE POLICY startup_profiles_insert_owner
  ON startup_profiles
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY startup_profiles_update_owner
  ON startup_profiles
  FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY startup_profiles_delete_owner
  ON startup_profiles
  FOR DELETE
  USING (user_id = auth.uid());

-- ============================================================
-- investor_profiles
-- ============================================================
-- Investors may read and write only their own profile.
-- Startup founders (and the investor themselves) need to read investor
-- profiles to resolve participant names in conversations.

ALTER TABLE investor_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS investor_profiles_select_authenticated ON investor_profiles;
DROP POLICY IF EXISTS investor_profiles_insert_owner         ON investor_profiles;
DROP POLICY IF EXISTS investor_profiles_update_owner         ON investor_profiles;
DROP POLICY IF EXISTS investor_profiles_delete_owner         ON investor_profiles;

-- SELECT: all authenticated users may read investor profiles so
-- conversation participant names can be resolved.
CREATE POLICY investor_profiles_select_authenticated
  ON investor_profiles
  FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY investor_profiles_insert_owner
  ON investor_profiles
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY investor_profiles_update_owner
  ON investor_profiles
  FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY investor_profiles_delete_owner
  ON investor_profiles
  FOR DELETE
  USING (user_id = auth.uid());
