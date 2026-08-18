import '../../domain/entities/startup_profile_entity.dart';
import '../../domain/repositories/startup_profile_repository.dart';
import '../datasources/startup_profile_remote_data_source.dart';
import '../models/startup_profile_model.dart';

/// Concrete implementation of [StartupProfileRepository].
///
/// Converts domain calls to data-source models and handles exception mapping.
class StartupProfileRepositoryImpl implements StartupProfileRepository {
  const StartupProfileRepositoryImpl(this._remoteDataSource);

  final StartupProfileRemoteDataSource _remoteDataSource;

  @override
  Future<StartupProfileEntity> createStartupProfile(
    StartupProfileEntity profile,
  ) async {
    final model = StartupProfileModel.fromEntity(profile);
    final resultModel = await _remoteDataSource.createProfile(model);
    return resultModel;
  }

  @override
  Future<StartupProfileEntity?> getStartupProfile(String userId) async {
    return await _remoteDataSource.getProfile(userId);
  }

  @override
  Future<StartupProfileEntity> updateStartupProfile(
    StartupProfileEntity profile,
  ) async {
    final model = StartupProfileModel.fromEntity(profile);
    final resultModel = await _remoteDataSource.updateProfile(model);
    return resultModel;
  }

  @override
  Future<void> deleteStartupProfile(String userId) async {
    await _remoteDataSource.deleteProfile(userId);
  }
}
