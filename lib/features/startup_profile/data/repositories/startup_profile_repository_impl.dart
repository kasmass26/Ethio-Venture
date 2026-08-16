import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/startup_profile_entity.dart';
import '../../domain/repositories/startup_profile_repository.dart';
import '../datasources/startup_profile_remote_data_source.dart';
import '../models/startup_profile_model.dart';

class StartupProfileRepositoryImpl implements StartupProfileRepository {
  final StartupProfileRemoteDataSource remoteDataSource;

  StartupProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, StartupProfileEntity>> createStartupProfile(
    StartupProfileEntity profile,
  ) async {
    try {
      final created = await remoteDataSource.createStartupProfile(
        StartupProfileModel.fromEntity(profile),
      );
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to create startup profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, StartupProfileEntity>> getStartupProfile(
    String id,
  ) async {
    try {
      final profile = await remoteDataSource.getStartupProfile(id);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to load startup profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, StartupProfileEntity>> updateStartupProfile(
    StartupProfileEntity profile,
  ) async {
    try {
      final updated = await remoteDataSource.updateStartupProfile(
        StartupProfileModel.fromEntity(profile),
      );
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to update startup profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> uploadDocument({
    required String startupId,
    required String category,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
  }) async {
    try {
      final document = await remoteDataSource.uploadDocument(
        startupId: startupId,
        category: category,
        fileName: fileName,
        fileType: fileType,
        fileSizeBytes: fileSizeBytes,
      );
      return Right(document);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to upload document: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument({
    required String startupId,
    required String documentId,
  }) async {
    try {
      await remoteDataSource.deleteDocument(
        startupId: startupId,
        documentId: documentId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete document: ${e.toString()}'));
    }
  }
}
