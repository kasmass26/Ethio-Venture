import '../entities/verification_request_entity.dart';
import '../repositories/verification_repository.dart';

class GetCurrentUserVerificationRequests {
  const GetCurrentUserVerificationRequests(this._repository);

  final VerificationRepository _repository;

  Future<List<VerificationRequestEntity>> call() {
    return _repository.getCurrentUserRequests();
  }
}
