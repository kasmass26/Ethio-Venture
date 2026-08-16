import 'package:equatable/equatable.dart';

/// Filtering parameters for startup search.
class StartupFilterParams extends Equatable {
  final String query;
  final String? industry;
  final String? fundingStage;
  final double? minTargetAmount;
  final double? maxTargetAmount;
  final String? location;
  final String
  sortBy; // 'relevance', 'target_high', 'target_low', 'progress_high', 'newest'

  const StartupFilterParams({
    this.query = '',
    this.industry,
    this.fundingStage,
    this.minTargetAmount,
    this.maxTargetAmount,
    this.location,
    this.sortBy = 'relevance',
  });

  bool get hasActiveFilters =>
      (industry != null && industry!.isNotEmpty && industry != 'All') ||
      (fundingStage != null &&
          fundingStage!.isNotEmpty &&
          fundingStage != 'All') ||
      minTargetAmount != null ||
      maxTargetAmount != null ||
      (location != null && location!.isNotEmpty && location != 'All');

  StartupFilterParams copyWith({
    String? query,
    String? industry,
    String? fundingStage,
    double? minTargetAmount,
    double? maxTargetAmount,
    String? location,
    String? sortBy,
  }) {
    return StartupFilterParams(
      query: query ?? this.query,
      industry: industry ?? this.industry,
      fundingStage: fundingStage ?? this.fundingStage,
      minTargetAmount: minTargetAmount ?? this.minTargetAmount,
      maxTargetAmount: maxTargetAmount ?? this.maxTargetAmount,
      location: location ?? this.location,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  StartupFilterParams resetFilters() {
    return StartupFilterParams(query: query, sortBy: sortBy);
  }

  @override
  List<Object?> get props => [
    query,
    industry,
    fundingStage,
    minTargetAmount,
    maxTargetAmount,
    location,
    sortBy,
  ];
}
