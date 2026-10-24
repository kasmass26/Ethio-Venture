import '../entities/verification_request_entity.dart';
import '../entities/verification_type.dart';
import '../repositories/verification_repository.dart';

class StartVerificationRequest {
  const StartVerificationRequest(this._repository);

  final VerificationRepository _repository;

  Future<VerificationRequestEntity> call(VerificationType type) {
    return _repository.startVerificationRequest(type);
  }
}
