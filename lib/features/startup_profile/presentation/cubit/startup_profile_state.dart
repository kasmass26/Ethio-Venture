import '../../domain/entities/startup_profile_entity.dart';

/// Sealed hierarchy representing all UI states for Startup Profile Management.
sealed class StartupProfileState {
  const StartupProfileState();
}

/// Initial state before any action is taken.
class StartupProfileInitial extends StartupProfileState {
  const StartupProfileInitial();
}

/// State emitted while loading/fetching a profile from Supabase.
class StartupProfileLoading extends StartupProfileState {
  const StartupProfileLoading();
}

/// State emitted when a startup profile is successfully loaded.
class StartupProfileLoaded extends StartupProfileState {
  const StartupProfileLoaded(this.profile);

  final StartupProfileEntity profile;
}

/// State emitted when the user has no startup profile created yet.
class StartupProfileEmpty extends StartupProfileState {
  const StartupProfileEmpty();
}

/// State emitted while creating or updating a profile.
class StartupProfileSubmitting extends StartupProfileState {
  const StartupProfileSubmitting();
}

/// State emitted when a creation or update operation succeeds.
class StartupProfileSuccess extends StartupProfileState {
  const StartupProfileSuccess(this.profile, this.message);

  final StartupProfileEntity profile;
  final String message;
}

/// State emitted when any operation fails.
class StartupProfileError extends StartupProfileState {
  const StartupProfileError(this.message);

  final String message;
}
