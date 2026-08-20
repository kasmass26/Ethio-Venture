import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_discovery_entity.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/get_approved_investors_usecase.dart';
import 'package:ethioventure/features/matching/domain/services/match_scoring_service.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';

import 'recommended_investors_state.dart';

/// Cubit that drives the "Recommended Investors" rail and investor discovery for founders.
class RecommendedInvestorsCubit extends Cubit<RecommendedInvestorsState> {
  RecommendedInvestorsCubit({
    required GetApprovedInvestorsUseCase getApprovedInvestorsUseCase,
    MatchScoringService? matchScoringService,
  })  : _getApprovedInvestorsUseCase = getApprovedInvestorsUseCase,
        _matchScoringService = matchScoringService ?? const MatchScoringService(),
        super(const RecommendedInvestorsInitial());

  final GetApprovedInvestorsUseCase _getApprovedInvestorsUseCase;
  final MatchScoringService _matchScoringService;

  List<InvestorDiscoveryEntity> _allCachedInvestors = [];

  /// Loads investors from the database and ranks them against [startupProfile].
  Future<void> load([StartupProfileEntity? startupProfile]) async {
    emit(const RecommendedInvestorsLoading());
    try {
      final investors = await _getApprovedInvestorsUseCase();
      // Ensure only strictly approved profiles are visible to startups
      final approvedInvestors = investors.where((i) => i.isApproved).toList();
      _allCachedInvestors = approvedInvestors;

      if (approvedInvestors.isEmpty) {
        emit(const RecommendedInvestorsEmpty());
        return;
      }

      final scored = _scoreAndSort(approvedInvestors, startupProfile);
      emit(RecommendedInvestorsLoaded(scored));
    } catch (e) {
      debugPrint('[RecommendedInvestorsCubit] error: $e');
      emit(RecommendedInvestorsError(e.toString()));
    }
  }

  /// Re-scores already cached investors when the startup profile updates without an extra DB hit.
  void rescoreWithProfile(StartupProfileEntity? startupProfile) {
    if (_allCachedInvestors.isEmpty) return;
    final scored = _scoreAndSort(_allCachedInvestors, startupProfile);
    emit(RecommendedInvestorsLoaded(scored));
  }

  List<InvestorDiscoveryEntity> _scoreAndSort(
    List<InvestorDiscoveryEntity> investors,
    StartupProfileEntity? startupProfile,
  ) {
    final scored = investors.map((inv) {
      final (score, reasons) = _matchScoringService.scoreInvestorForStartup(
        preferredIndustries: inv.preferredIndustries,
        preferredStages: inv.preferredStages,
        ticketSizeMin: inv.ticketSizeMin,
        ticketSizeMax: inv.ticketSizeMax,
        startupIndustry: startupProfile?.industry,
        startupStage: startupProfile?.fundingStage,
        startupFundingNeeded: startupProfile?.fundingAmountNeeded,
      );
      return inv.copyWith(matchScore: score, matchReasons: reasons);
    }).toList();

    // Sort by matchScore descending, then by newest
    scored.sort((a, b) {
      final scoreCompare = b.matchScore.compareTo(a.matchScore);
      if (scoreCompare != 0) return scoreCompare;
      return b.createdAt.compareTo(a.createdAt);
    });

    return scored;
  }
}
