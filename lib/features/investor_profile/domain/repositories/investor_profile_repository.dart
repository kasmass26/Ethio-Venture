import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';

/// Repository contract for investor profile operations.
///
/// Repositories handle the mapping between data models and domain entities,
/// and orchestrate data source calls for investor profile management.
/// Exception handling is delegated to the presentation layer (BLoC/Cubit).
abstract interface class InvestorProfileRepository {
  /// Retrieves the investor profile for the current authenticated user.
  ///
  /// Returns `null` if the user has not created an investor profile yet.
  /// Throws an exception if the operation fails (network error, permissions, etc.).
  Future<InvestorProfileEntity?> getInvestorProfile();

  /// Creates a new investor profile for the current authenticated user.
  ///
  /// Throws an exception if the operation fails (e.g., profile already exists,
  /// validation error, network error, or insufficient permissions).
  Future<InvestorProfileEntity> createInvestorProfile(
    InvestorProfileEntity profile,
  );

  /// Updates the investor profile for the current authenticated user.
  ///
  /// Throws an exception if the operation fails (e.g., profile not found,
  /// validation error, network error, or insufficient permissions).
  Future<InvestorProfileEntity> updateInvestorProfile(
    InvestorProfileEntity profile,
  );

  /// Deletes the investor profile for the current authenticated user.
  ///
  /// Throws an exception if the operation fails (e.g., profile not found,
  /// network error, or insufficient permissions).
  Future<void> deleteInvestorProfile();
}
