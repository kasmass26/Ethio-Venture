# Supabase setup

## One-time local setup

1. In the Supabase Dashboard, open **Project Settings > API**.
2. Copy `.env.example` to `.env` in the repository root.
3. Set `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` from that page.
4. Run `flutter pub get`, then start the app normally.
5. Apply `supabase/migrations/20260818180000_create_users_trigger.sql` using
   the Supabase CLI or the Dashboard SQL Editor. It creates a `users` record
   automatically whenever an Auth user is created.

## Email confirmation

If **Confirm email** is enabled in **Authentication > Providers > Email**, a
new account cannot sign in until its confirmation link has been opened. The
app now explains this after registration and returns the user to sign in. For
local testing, it may be disabled in the development project; keep it enabled
in production and configure redirect URLs in the Supabase Dashboard.

The app fails at startup with a clear message if either required value is blank
or still contains the example placeholder.

## Team workflow

- `.env` is deliberately ignored by Git. Each developer creates their own file.
- `.env.example` is the shared contract. When a new public client setting is
  introduced, add its placeholder and documentation in the same pull request.
- Use separate Supabase projects for development, staging, and production.
  Team members should point their local `.env` to the development project.
- Keep `APP_ENV` aligned with the selected project so logs and UI behaviour are
  unambiguous.
- Rotate a publishable key through the Supabase Dashboard, then notify the team
  to update their local `.env` files. Never commit someone else's values.

## Security boundary

`SUPABASE_PUBLISHABLE_KEY` is intended for client applications; it does not
grant administrative access by itself. It is still bundled into the app, just
like the project URL. Never put a `service_role` key, database password, JWT
secret, or third-party private token in Flutter environment files. Put
privileged work in Supabase Edge Functions or another server-side service, and
protect database tables with Row Level Security policies.

## Using Supabase in a feature

Import `core/supabase/supabase_service.dart` and use the shared client:

```dart
final session = SupabaseService.client.auth.currentSession;
final response = await SupabaseService.client
    .from('users')
    .select()
    .eq('id', session!.user.id)
    .maybeSingle();
```

The client is initialized once in `main.dart`; feature code should not create a
second `SupabaseClient`.
