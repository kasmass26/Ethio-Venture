import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/startup_profile_entity.dart';
import '../repositories/startup_profile_repository.dart';

class GetStartupProfileUseCase
    implements UseCase<StartupProfileEntity, String> {
  final StartupProfileRepository repository;

  GetStartupProfileUseCase(this.repository);

  @override
  Future<Either<Failure, StartupProfileEntity>> call(String profileId) {
    return repository.getStartupProfile(profileId);
  }
}
