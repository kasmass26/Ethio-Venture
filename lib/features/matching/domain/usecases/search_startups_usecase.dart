import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/startup_entity.dart';
import '../entities/startup_filter_params.dart';
import '../repositories/matching_repository.dart';

class SearchStartupsUseCase
    implements UseCase<List<StartupEntity>, StartupFilterParams> {
  final MatchingRepository repository;

  SearchStartupsUseCase(this.repository);

  @override
  Future<Either<Failure, List<StartupEntity>>> call(
    StartupFilterParams params,
  ) {
    return repository.searchStartups(params);
  }
}
