import 'package:ethioventure/core/error/failures.dart';

/// Base contract for all Use Cases in Clean Architecture.
/// An operation can return either a [Failure] or the target type [T].
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Helper Result type to encapsulate Success or Failure without external dartz dependency
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
  Failure? get failureOrNull => this is Error<T> ? (this as Error<T>).failure : null;

  R fold<R>(R Function(Failure failure) onError, R Function(T data) onSuccess) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onError((this as Error<T>).failure);
    }
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

/// For use cases that do not accept any arguments
class NoParams {
  const NoParams();
}
