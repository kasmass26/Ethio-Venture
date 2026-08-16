import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/startup_filter_params.dart';
import '../../domain/usecases/search_startups_usecase.dart';
import 'startup_search_state.dart';

class StartupSearchCubit extends Cubit<StartupSearchState> {
  final SearchStartupsUseCase searchStartupsUseCase;

  StartupFilterParams currentParams = const StartupFilterParams();

  StartupSearchCubit({required this.searchStartupsUseCase})
    : super(const StartupSearchInitial());

  Future<void> loadStartups([StartupFilterParams? params]) async {
    final searchParams = params ?? currentParams;
    currentParams = searchParams;

    emit(const StartupSearchLoading());

    final result = await searchStartupsUseCase(searchParams);

    result.fold(
      (failure) => emit(StartupSearchError(failure.message)),
      (startups) =>
          emit(StartupSearchLoaded(startups: startups, params: searchParams)),
    );
  }

  Future<void> updateQuery(String query) async {
    final updated = currentParams.copyWith(query: query);
    await loadStartups(updated);
  }

  Future<void> updateIndustry(String? industry) async {
    final updated = currentParams.copyWith(industry: industry);
    await loadStartups(updated);
  }

  Future<void> applyFilter(StartupFilterParams params) async {
    await loadStartups(params);
  }

  Future<void> resetFilters() async {
    final reset = currentParams.resetFilters();
    await loadStartups(reset);
  }
}
