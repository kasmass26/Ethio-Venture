import 'package:ethioventure/features/investor_profile/domain/entities/investor_entity.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';

sealed class MatchingState {
  const MatchingState();
}

class MatchingInitial extends MatchingState {
  const MatchingInitial();
}

class MatchingLoading extends MatchingState {
  const MatchingLoading();
}

class MatchingLoaded extends MatchingState {
  final InvestorEntity investor;
  final List<RecommendationEntity> allRecommendations;
  final List<RecommendationEntity> filteredRecommendations;
  final String selectedIndustryFilter;
  final double minScoreFilter;
  final String searchQuery;
  final bool isUpdatingPreferences;

  const MatchingLoaded({
    required this.investor,
    required this.allRecommendations,
    required this.filteredRecommendations,
    this.selectedIndustryFilter = 'All',
    this.minScoreFilter = 0.0,
    this.searchQuery = '',
    this.isUpdatingPreferences = false,
  });

  int get totalCount => allRecommendations.length;
  
  double get topScore => allRecommendations.isNotEmpty
      ? allRecommendations.first.compatibilityScore
      : 0.0;

  double get averageScore {
    if (allRecommendations.isEmpty) return 0.0;
    final sum = allRecommendations.fold(0.0, (acc, r) => acc + r.compatibilityScore);
    return sum / allRecommendations.length;
  }

  int get excellentMatchesCount =>
      allRecommendations.where((r) => r.grade == MatchGrade.excellent).length;

  int get highMatchesCount =>
      allRecommendations.where((r) => r.grade == MatchGrade.high).length;

  List<String> get availableIndustries {
    final set = <String>{'All'};
    for (final rec in allRecommendations) {
      set.add(rec.startup.industry);
    }
    return set.toList();
  }

  MatchingLoaded copyWith({
    InvestorEntity? investor,
    List<RecommendationEntity>? allRecommendations,
    List<RecommendationEntity>? filteredRecommendations,
    String? selectedIndustryFilter,
    double? minScoreFilter,
    String? searchQuery,
    bool? isUpdatingPreferences,
  }) {
    return MatchingLoaded(
      investor: investor ?? this.investor,
      allRecommendations: allRecommendations ?? this.allRecommendations,
      filteredRecommendations: filteredRecommendations ?? this.filteredRecommendations,
      selectedIndustryFilter: selectedIndustryFilter ?? this.selectedIndustryFilter,
      minScoreFilter: minScoreFilter ?? this.minScoreFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isUpdatingPreferences: isUpdatingPreferences ?? this.isUpdatingPreferences,
    );
  }
}

class MatchingError extends MatchingState {
  final String message;
  const MatchingError(this.message);
}
