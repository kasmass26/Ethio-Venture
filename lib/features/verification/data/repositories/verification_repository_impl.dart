import '../../domain/entities/public_verification_badge_entity.dart';
import '../../domain/entities/verification_request_entity.dart';
import '../../domain/entities/verification_type.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  const VerificationRepositoryImpl({required this.remoteDataSource});

  final VerificationRemoteDataSource remoteDataSource;

  @override
  Future<List<VerificationRequestEntity>> getCurrentUserRequests() async {
    final models = await remoteDataSource.getCurrentUserRequests();
    return models.cast<VerificationRequestEntity>();
  }

  @override
  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  ) {
    return remoteDataSource.getPublicApprovedBadges(profileId);
  }

  @override
  Future<VerificationRequestEntity> startVerificationRequest(
    VerificationType type,
  ) async {
    final model = await remoteDataSource.startVerificationRequest(type);
    return model;
  }
}
