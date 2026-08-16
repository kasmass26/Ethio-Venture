import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/document_entity.dart';
import '../entities/startup_profile_entity.dart';

abstract class StartupProfileRepository {
  /// Create a new startup profile for the authenticated user
  Future<Either<Failure, StartupProfileEntity>> createStartupProfile(
    StartupProfileEntity profile,
  );

  /// Get startup profile details (by profile ID or currently authenticated user)
  Future<Either<Failure, StartupProfileEntity>> getStartupProfile(String id);

  /// Update startup profile details
  Future<Either<Failure, StartupProfileEntity>> updateStartupProfile(
    StartupProfileEntity profile,
  );

  /// Upload pitch deck or business document
  Future<Either<Failure, DocumentEntity>> uploadDocument({
    required String startupId,
    required String category,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
  });

  /// Delete uploaded document
  Future<Either<Failure, void>> deleteDocument({
    required String startupId,
    required String documentId,
  });
}
