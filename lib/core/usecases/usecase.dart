import 'dart:async';

/// Contract for a single domain action.
abstract interface class UseCase<Result, Params> {
  FutureOr<Result> call(Params params);
}

/// Use this for actions that need no input rather than passing `null`.
class NoParams {
  const NoParams();
}
