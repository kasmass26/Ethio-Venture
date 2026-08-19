import '../entities/startup_profile_entity.dart';

/// Abstract contract for Startup Profile operations.
///
/// This interface lives strictly in the Domain Layer. It defines all
/// startup profile actions required by business use cases without depending
/// on Supabase SDK or specific data implementations.
abstract interface class StartupProfileRepository {
  /// Creates a new startup profile record.
  Future<StartupProfileEntity> createStartupProfile(StartupProfileEntity profile);

  /// Fetches the startup profile for a given [userId].
  /// Returns `null` if no profile exists for the user yet.
  Future<StartupProfileEntity?> getStartupProfile(String userId);

  /// Updates an existing startup profile record.
  Future<StartupProfileEntity> updateStartupProfile(StartupProfileEntity profile);

  /// Deletes the startup profile for a given [userId].
  Future<void> deleteStartupProfile(String userId);
}
