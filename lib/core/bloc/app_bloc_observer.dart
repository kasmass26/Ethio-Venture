import 'package:flutter_bloc/flutter_bloc.dart';

/// Central hook for BLoC lifecycle events. Keep production logging non-sensitive.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    // Connect a privacy-safe crash-reporting service here when one is selected.
  }
}
