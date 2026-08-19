import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:ethioventure/features/investor_profile/domain/repositories/investor_profile_repository.dart';

class CreateInvestorProfile
    implements UseCase<InvestorProfileEntity, InvestorProfileEntity> {
  const CreateInvestorProfile(this._repository);

  final InvestorProfileRepository _repository;

  @override
  Future<InvestorProfileEntity> call(InvestorProfileEntity params) {
    return _repository.createInvestorProfile(params);
  }
}
