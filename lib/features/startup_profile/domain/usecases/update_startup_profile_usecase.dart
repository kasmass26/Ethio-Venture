import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/startup_profile_entity.dart';
import '../repositories/startup_profile_repository.dart';

class UpdateStartupProfileUseCase
    implements UseCase<StartupProfileEntity, StartupProfileEntity> {
  final StartupProfileRepository repository;

  UpdateStartupProfileUseCase(this.repository);

  @override
  Future<Either<Failure, StartupProfileEntity>> call(
    StartupProfileEntity profile,
  ) {
    return repository.updateStartupProfile(profile);
  }
}
