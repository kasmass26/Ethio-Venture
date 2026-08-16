import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/investor_preference_entity.dart';
import '../../domain/usecases/get_recommendations_usecase.dart';
import 'recommendations_state.dart';

class RecommendationsCubit extends Cubit<RecommendationsState> {
  final GetRecommendationsUseCase getRecommendationsUseCase;

  InvestorPreferenceEntity currentPreferences =
      InvestorPreferenceEntity.defaultPreferences();

  RecommendationsCubit({required this.getRecommendationsUseCase})
    : super(const RecommendationsInitial());

  Future<void> fetchRecommendations(
    String userId, [
    InvestorPreferenceEntity? preferences,
  ]) async {
    final activePrefs = preferences ?? currentPreferences;
    currentPreferences = activePrefs;

    emit(const RecommendationsLoading());

    final result = await getRecommendationsUseCase(
      GetRecommendationsParams(userId: userId, preference: activePrefs),
    );

    result.fold(
      (failure) => emit(RecommendationsError(failure.message)),
      (recommendations) => emit(
        RecommendationsLoaded(
          recommendations: recommendations,
          preferences: activePrefs,
        ),
      ),
    );
  }

  Future<void> updatePreferences(
    String userId,
    InvestorPreferenceEntity newPreferences,
  ) async {
    await fetchRecommendations(userId, newPreferences);
  }
}
