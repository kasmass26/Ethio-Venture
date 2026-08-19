import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/investor_profile/domain/repositories/investor_profile_repository.dart';

class DeleteInvestorProfile implements UseCase<void, NoParams> {
  const DeleteInvestorProfile(this._repository);

  final InvestorProfileRepository _repository;

  @override
  Future<void> call([NoParams params = const NoParams()]) {
    return _repository.deleteInvestorProfile();
  }
}
