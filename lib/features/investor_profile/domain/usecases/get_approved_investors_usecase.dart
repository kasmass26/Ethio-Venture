import 'package:ethioventure/core/usecases/usecase.dart';
import '../entities/investor_discovery_entity.dart';
import '../repositories/investor_profile_repository.dart';

class GetApprovedInvestorsUseCase implements UseCase<List<InvestorDiscoveryEntity>, NoParams> {
  const GetApprovedInvestorsUseCase(this._repository);

  final InvestorProfileRepository _repository;

  @override
  Future<List<InvestorDiscoveryEntity>> call([NoParams? params]) async {
    return _repository.getApprovedInvestors();
  }
}
