# ethioventure

Flutter application for Ethio Venture.

## Supabase configuration

Before first run, copy `.env.example` to `.env` and enter this project's
Supabase URL and publishable key. The local `.env` file is intentionally not
tracked by Git.

```powershell
Copy-Item .env.example .env
flutter pub get
flutter run
```

See [the Supabase setup guide](docs/supabase-setup.md) for team workflow,
security requirements, and usage examples.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
