# Ethio Venture

Ethio Venture is a mobile platform that helps startups present their businesses
to suitable investors and helps investors discover opportunities that align
with their industry, stage, and investment preferences.

## The problem

Fundraising and investor discovery are often fragmented and dependent on
personal networks. Startups struggle to reach relevant investors, while
investors spend significant time finding ventures that meet their criteria.
Ethio Venture creates a structured, transparent discovery and matching
experience for both sides.

## Product capabilities

- Secure authentication and role-based startup or investor accounts
- Startup and investor profiles
- Investor preferences and startup discovery filters
- Match recommendations and interaction tracking
- Direct messaging
- Pitch-deck and business-document uploads
- In-app and push notifications for matches and messages
- Administrator tools for moderation and platform operations

## Technology

| Area | Technology |
| --- | --- |
| Client | Flutter / Dart |
| Backend | Supabase (Postgres, Auth, Storage, Edge Functions) |
| Push notifications | Firebase Cloud Messaging |
| App architecture | Clean Architecture |
| State management | BLoC / Cubit |

## Documentation

- [Product requirements](docs/product-requirements.md)
- [Architecture](docs/architecture.md)
- [Database design](docs/database-design.md)
- [Development guide](docs/development-guide.md)
- [Security guide](docs/security.md)
- [Supabase setup](docs/supabase-setup.md)

## Quick start

1. Install the Flutter SDK compatible with the version in `pubspec.yaml`.
2. Copy the environment template and enter the Supabase values for your local
   development project.
3. Fetch packages and run the app.

```powershell
Copy-Item .env.example .env
flutter pub get
flutter run
```

Only use the Supabase **publishable** key in `.env`. Do not put service-role
keys, passwords, or any other private credentials in the Flutter client.

## Project status

The repository currently contains the application foundation and feature
structure. The product capabilities above are the planned scope; each should
be delivered with its database migration, Row Level Security policy, tests,
and documented acceptance criteria.

## Contributing

Read the [development guide](docs/development-guide.md) before opening a pull
request. Configuration values must stay in local `.env` files and never be
committed.
