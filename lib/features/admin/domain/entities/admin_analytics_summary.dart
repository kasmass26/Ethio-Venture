import '../../../matching/domain/entities/investor_preferences_entity.dart';
import '../../../matching/domain/entities/startup_profile_entity.dart';
import '../../../matching/domain/services/match_scoring_service.dart';
import 'pending_approval_entity.dart';

class AdminAnalyticsSummary {
  const AdminAnalyticsSummary({
    required this.totalStartups,
    required this.totalInvestors,
    required this.compatibleMatches,
    required this.possibleMatches,
    required this.industryCounts,
    required this.fundingStageCounts,
  });

  final int totalStartups;
  final int totalInvestors;
  final int compatibleMatches;
  final int possibleMatches;
  final Map<String, int> industryCounts;
  final Map<String, int> fundingStageCounts;

  double? get matchRate =>
      possibleMatches == 0 ? null : compatibleMatches / possibleMatches * 100;
}

class AdminAnalyticsCalculator {
  const AdminAnalyticsCalculator({
    this.matchScoringService = const MatchScoringService(),
  });

  final MatchScoringService matchScoringService;

  AdminAnalyticsSummary calculate({
    required List<PendingApprovalEntity> pendingStartups,
    required List<PendingApprovalEntity> pendingInvestors,
    required List<PendingApprovalEntity> approvedStartups,
    required List<PendingApprovalEntity> approvedInvestors,
    required List<PendingApprovalEntity> rejectedProfiles,
  }) {
    final allStartups = [
      ...pendingStartups,
      ...approvedStartups,
      ...rejectedProfiles.where(_isStartup),
    ];
    final allInvestors = [
      ...pendingInvestors,
      ...approvedInvestors,
      ...rejectedProfiles.where(_isInvestor),
    ];

    final industryCounts = <String, int>{};
    final fundingStageCounts = <String, int>{};
    for (final startup in approvedStartups) {
      _increment(industryCounts, startup.industry);
      _increment(fundingStageCounts, startup.fundingStage);
    }

    var compatibleMatches = 0;
    final possibleMatches = approvedStartups.length * approvedInvestors.length;
    for (final startup in approvedStartups) {
      for (final investor in approvedInvestors) {
        final result = matchScoringService.score(
          startup: StartupProfileEntity(
            id: startup.id,
            userId: startup.userId,
            businessName: startup.businessName,
            industry: startup.industry,
            fundingStage: startup.fundingStage,
            location: startup.location,
            fundingAmountSought: startup.fundingAmountSought,
          ),
          prefs: InvestorPreferencesEntity(
            id: investor.id,
            userId: investor.userId,
            preferredIndustries: investor.preferredIndustries,
            preferredStages: investor.preferredStages,
            geographicFocus: investor.geographicFocus,
            ticketSizeMin: investor.ticketSizeMin,
            ticketSizeMax: investor.ticketSizeMax,
          ),
        );
        if (result.overallScore > 0) compatibleMatches++;
      }
    }

    return AdminAnalyticsSummary(
      totalStartups: allStartups.length,
      totalInvestors: allInvestors.length,
      compatibleMatches: compatibleMatches,
      possibleMatches: possibleMatches,
      industryCounts: Map.unmodifiable(industryCounts),
      fundingStageCounts: Map.unmodifiable(fundingStageCounts),
    );
  }

  static bool _isStartup(PendingApprovalEntity profile) =>
      profile.role == 'startup' || profile.role == 'founder';

  static bool _isInvestor(PendingApprovalEntity profile) =>
      profile.role == 'investor';

  static void _increment(Map<String, int> counts, String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return;
    counts.update(normalized, (count) => count + 1, ifAbsent: () => 1);
  }
}
