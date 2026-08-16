import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Abstract base class for all domain use cases.
/// [T] is the return type inside Either on success.
/// [Params] is the parameter class passed to call().
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use when a use case requires no input parameters.
class NoParams {
  const NoParams();
}
