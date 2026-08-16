import 'package:flutter/foundation.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';
import 'package:ethioventure/features/matching/domain/repositories/matching_repository.dart';
import 'package:ethioventure/features/matching/domain/usecases/get_recommended_startups_usecase.dart';
import 'package:ethioventure/features/matching/presentation/cubit/matching_state.dart';

class MatchingCubit extends ChangeNotifier {
  final GetRecommendedStartupsUseCase getRecommendationsUseCase;
  final MatchingRepository repository;

  MatchingState _state = const MatchingInitial();
  MatchingState get state => _state;

  String _currentInvestorId = 'inv_001';
  String get currentInvestorId => _currentInvestorId;

  MatchingCubit({
    required this.getRecommendationsUseCase,
    required this.repository,
  });

  Future<void> loadRecommendations({String? investorId}) async {
    if (investorId != null) {
      _currentInvestorId = investorId;
    }

    _state = const MatchingLoading();
    notifyListeners();

    final investorResult = await repository.getInvestorProfile(_currentInvestorId);
    final recommendationsResult = await getRecommendationsUseCase(
      GetRecommendationsParams(investorId: _currentInvestorId),
    );

    if (investorResult.isFailure) {
      _state = MatchingError(investorResult.failureOrNull?.message ?? 'Failed to load investor profile');
      notifyListeners();
      return;
    }

    if (recommendationsResult.isFailure) {
      _state = MatchingError(recommendationsResult.failureOrNull?.message ?? 'Failed to calculate recommendations');
      notifyListeners();
      return;
    }

    final investor = investorResult.dataOrNull!;
    final allRecommendations = recommendationsResult.dataOrNull!;

    _state = MatchingLoaded(
      investor: investor,
      allRecommendations: allRecommendations,
      filteredRecommendations: allRecommendations,
    );
    notifyListeners();
  }

  void setIndustryFilter(String industry) {
    if (_state is! MatchingLoaded) return;
    final loaded = _state as MatchingLoaded;

    final updated = loaded.copyWith(selectedIndustryFilter: industry);
    _state = updated.copyWith(
      filteredRecommendations: _applyFilters(
        loaded.allRecommendations,
        industry,
        loaded.minScoreFilter,
        loaded.searchQuery,
      ),
    );
    notifyListeners();
  }

  void setMinScoreFilter(double minScore) {
    if (_state is! MatchingLoaded) return;
    final loaded = _state as MatchingLoaded;

    final updated = loaded.copyWith(minScoreFilter: minScore);
    _state = updated.copyWith(
      filteredRecommendations: _applyFilters(
        loaded.allRecommendations,
        loaded.selectedIndustryFilter,
        minScore,
        loaded.searchQuery,
      ),
    );
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_state is! MatchingLoaded) return;
    final loaded = _state as MatchingLoaded;

    final updated = loaded.copyWith(searchQuery: query);
    _state = updated.copyWith(
      filteredRecommendations: _applyFilters(
        loaded.allRecommendations,
        loaded.selectedIndustryFilter,
        loaded.minScoreFilter,
        query,
      ),
    );
    notifyListeners();
  }

  Future<void> toggleBookmark(String startupId) async {
    if (_state is! MatchingLoaded) return;
    final loaded = _state as MatchingLoaded;

    final updatedAll = loaded.allRecommendations.map((rec) {
      if (rec.startup.id == startupId) {
        return rec.copyWith(isBookmarked: !rec.isBookmarked);
      }
      return rec;
    }).toList();

    _state = loaded.copyWith(
      allRecommendations: updatedAll,
      filteredRecommendations: _applyFilters(
        updatedAll,
        loaded.selectedIndustryFilter,
        loaded.minScoreFilter,
        loaded.searchQuery,
      ),
    );
    notifyListeners();
  }

  Future<void> updateInvestorPreferences({
    List<String>? industries,
    List<String>? stages,
    double? minAmount,
    double? maxAmount,
    List<String>? locations,
  }) async {
    if (_state is! MatchingLoaded) return;
    final loaded = _state as MatchingLoaded;

    _state = loaded.copyWith(isUpdatingPreferences: true);
    notifyListeners();

    final updatedInvestor = loaded.investor.copyWith(
      preferredIndustries: industries ?? loaded.investor.preferredIndustries,
      preferredFundingStages: stages ?? loaded.investor.preferredFundingStages,
      minInvestmentAmount: minAmount,
      maxInvestmentAmount: maxAmount,
      preferredLocations: locations ?? loaded.investor.preferredLocations,
    );

    await repository.updateInvestorPreferences(updatedInvestor);
    await loadRecommendations(investorId: _currentInvestorId);
  }

  List<RecommendationEntity> _applyFilters(
    List<RecommendationEntity> list,
    String industry,
    double minScore,
    String query,
  ) {
    return list.where((rec) {
      // Industry filter
      if (industry != 'All' && rec.startup.industry.toLowerCase() != industry.toLowerCase()) {
        return false;
      }

      // Min score filter
      if (rec.compatibilityScore < minScore) {
        return false;
      }

      // Search query filter
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final nameMatch = rec.startup.name.toLowerCase().contains(q);
        final tagMatch = rec.startup.tagline.toLowerCase().contains(q);
        final indMatch = rec.startup.industry.toLowerCase().contains(q);
        final locMatch = rec.startup.location.toLowerCase().contains(q);
        if (!nameMatch && !tagMatch && !indMatch && !locMatch) return false;
      }

      return true;
    }).toList();
  }
}
