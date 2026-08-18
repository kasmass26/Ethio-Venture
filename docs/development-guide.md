# Development guide

## Prerequisites

- Flutter SDK matching the Dart constraint in `pubspec.yaml`
- A Supabase development project
- Firebase project configuration when notification work begins
- Android Studio, Xcode (for iOS), or a supported Flutter editor

## Local setup

```powershell
Copy-Item .env.example .env
flutter pub get
flutter analyze
flutter test
flutter run
```

Set `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` in `.env` before running.
See [Supabase setup](supabase-setup.md) for the configuration and key-handling
rules.

## Implementation workflow

1. Create or update a database migration and Row Level Security policies first
   when the feature stores data.
2. Add domain entities, repository contract, and focused use cases.
3. Implement data models, Supabase data source, and repository mapping.
4. Build the Cubit/BLoC and UI states: initial, loading, success, empty, and
   failure where relevant.
5. Add tests for business rules, repository mapping, and state transitions.
6. Update the relevant documentation and `.env.example` if a new public client
   configuration value is required.

## Code conventions

- Keep widgets thin; dispatch events or call Cubit methods instead of making
  backend calls in `build` methods.
- Prefer immutable domain entities and explicit result/failure handling.
- Paginate lists; never load an unbounded set of startups, messages, or
  notifications.
- Use `SupabaseService.client` through a data source. Do not initialize another
  client inside a feature.
- Format code with `dart format` and resolve analyzer warnings before review.

## Git and review

- Create focused branches, such as `feature/startup-profile` or `fix/auth-flow`.
- Keep commits small and describe their intent.
- Never commit `.env`, service-role keys, FCM server credentials, or user data.
- A pull request should describe user impact, database changes, RLS impact,
  test evidence, screenshots for UI changes, and rollback considerations.

## Release environments

Use isolated Supabase projects for development, staging, and production. Apply
migrations to staging before production and test RLS with non-administrator test
accounts. Build-specific Firebase configuration must also remain separated by
environment.
