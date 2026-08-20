import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_discovery_entity.dart';
import 'package:ethioventure/features/investor_profile/domain/usecases/get_approved_investors_usecase.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';

import 'recommended_investors_state.dart';

/// Cubit that drives the "Recommended Investors" rail and investor discovery for founders.
class RecommendedInvestorsCubit extends Cubit<RecommendedInvestorsState> {
  RecommendedInvestorsCubit({
    required GetApprovedInvestorsUseCase getApprovedInvestorsUseCase,
  })  : _getApprovedInvestorsUseCase = getApprovedInvestorsUseCase,
        super(const RecommendedInvestorsInitial());

  final GetApprovedInvestorsUseCase _getApprovedInvestorsUseCase;

  List<InvestorDiscoveryEntity> _allCachedInvestors = [];

  /// Loads investors from the database and ranks them against [startupProfile].
  Future<void> load([StartupProfileEntity? startupProfile]) async {
    emit(const RecommendedInvestorsLoading());
    try {
      final investors = await _getApprovedInvestorsUseCase();
      _allCachedInvestors = investors;

      if (investors.isEmpty) {
        emit(const RecommendedInvestorsEmpty());
        return;
      }

      final scored = _scoreAndSort(investors, startupProfile);
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
      final (score, reasons) = _computeScoreAndReasons(inv, startupProfile);
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

  (int, List<String>) _computeScoreAndReasons(
    InvestorDiscoveryEntity investor,
    StartupProfileEntity? startupProfile,
  ) {
    if (startupProfile == null) {
      final reasons = <String>[];
      if (investor.preferredIndustries.isNotEmpty) {
        reasons.add(investor.preferredIndustries.first);
      }
      if (investor.preferredStages.isNotEmpty) {
        reasons.add(investor.preferredStages.first);
      }
      if (reasons.isEmpty) {
        reasons.add('Verified Investor');
      }
      return (75, reasons);
    }

    int score = 0;
    final List<String> reasons = [];

    // 1. Industry Match (+40)
    final startupIndustry = startupProfile.industry.trim().toLowerCase();
    final hasIndustryMatch = investor.preferredIndustries.any((ind) {
      final i = ind.trim().toLowerCase();
      return i == startupIndustry ||
          i.contains(startupIndustry) ||
          startupIndustry.contains(i);
    });

    if (hasIndustryMatch) {
      score += 40;
      reasons.add('${startupProfile.industry} fit');
    }

    // 2. Stage Match (+35)
    final startupStage = startupProfile.fundingStage.trim().toLowerCase();
    final hasStageMatch = investor.preferredStages.any((stg) {
      final s = stg.trim().toLowerCase();
      return s == startupStage ||
          s.contains(startupStage) ||
          startupStage.contains(s);
    });

    if (hasStageMatch) {
      score += 35;
      reasons.add('${startupProfile.fundingStage} stage');
    }

    // 3. Ticket Size Match (+25)
    final min = investor.ticketSizeMin;
    final max = investor.ticketSizeMax;
    final needed = startupProfile.fundingAmountNeeded;

    if (min == null && max == null) {
      score += 15;
    } else if (min != null && max != null) {
      if (needed >= min && needed <= max) {
        score += 25;
        reasons.add('Ticket size match');
      } else if (needed >= min * 0.7 && needed <= max * 1.3) {
        score += 15;
        reasons.add('Flexible ticket');
      }
    } else if (min != null && needed >= min) {
      score += 20;
      reasons.add('Ticket size match');
    } else if (max != null && needed <= max) {
      score += 20;
      reasons.add('Ticket size match');
    }

    if (reasons.isEmpty) {
      if (investor.preferredIndustries.isNotEmpty) {
        reasons.add(investor.preferredIndustries.first);
      } else {
        reasons.add('Active Investor');
      }
    }

    final finalScore = (score == 0 ? 55 : score).clamp(20, 99);
    return (finalScore, reasons);
  }
}
