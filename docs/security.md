# Security and privacy

## Security principles

- Authentication identifies a user; Row Level Security authorizes every data
  operation.
- The mobile application is an untrusted client. Any value bundled in it,
  including `.env` values, must be treated as public.
- Only Edge Functions or another trusted server environment may use privileged
  credentials or send FCM requests using server-side credentials.
- Collect the minimum personal and business data necessary for matching.

## Credentials and configuration

| Credential/configuration | Allowed location |
| --- | --- |
| Supabase URL and publishable key | Local Flutter `.env` / build configuration |
| Supabase service-role key | Supabase Edge Function secret only |
| Database password and JWT secret | Supabase project settings only; never client code |
| Firebase server credentials | Trusted server or Edge Function secret only |
| Firebase mobile configuration | Platform-specific app configuration, separated by environment |

If a private key is committed, revoke/rotate it immediately, remove it from
history according to the team's incident procedure, and notify affected owners.

## Required controls

- Enable RLS on all application tables and Storage buckets.
- Write policy tests for owner, paired-user, unrelated-user, and administrator
  cases before releasing a table or bucket.
- Validate file type and size before upload; use private buckets for pitch decks
  and issue access only through policies or short-lived signed URLs.
- Validate all Edge Function inputs and check the authenticated user explicitly.
- Rate-limit or otherwise protect sensitive flows such as sign-in, password
  reset, document upload, messaging, and match generation.
- Do not log message contents, file contents, access tokens, passwords, or
  raw device tokens in client or server logs.

## Privacy expectations

Founders must understand which profile fields and documents investors can see.
Investors must understand how their preferences affect recommendations. Provide
clear notification preferences, account deletion handling, and a retention
policy before collecting real user data.

## Incident response

1. Contain the issue: disable the affected key, account, policy, or function.
2. Preserve relevant audit information without exposing more personal data.
3. Assess scope, affected data, and user impact.
4. Fix the root cause, add regression tests, and rotate credentials when needed.
5. Notify stakeholders and users when required by the applicable policy or law.
