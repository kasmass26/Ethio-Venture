import 'package:ethioventure/features/investor_profile/domain/entities/investor_entity.dart';
import 'package:ethioventure/features/matching/domain/entities/match_score_breakdown.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_entity.dart';

/// Pure, modular compatibility scoring engine that evaluates a startup
/// against an investor's investment preferences across 4 dimensions:
/// 1. Industry (35% weight)
/// 2. Funding Stage (25% weight)
/// 3. Investment Amount (25% weight)
/// 4. Location (15% weight)
class CalculateCompatibilityUseCase {
  const CalculateCompatibilityUseCase();

  RecommendationEntity call({
    required InvestorEntity investor,
    required StartupEntity startup,
  }) {
    final reasons = <String>[];

    // 1. Industry Match (Max 35 pts)
    final (industryScore, industryReason) = _evaluateIndustry(investor, startup);
    if (industryReason != null) reasons.add(industryReason);

    // 2. Funding Stage Match (Max 25 pts)
    final (stageScore, stageReason) = _evaluateStage(investor, startup);
    if (stageReason != null) reasons.add(stageReason);

    // 3. Investment Amount Compatibility (Max 25 pts)
    final (amountScore, amountReason) = _evaluateAmount(investor, startup);
    if (amountReason != null) reasons.add(amountReason);

    // 4. Location Preference (Max 15 pts)
    final (locationScore, locationReason) = _evaluateLocation(investor, startup);
    if (locationReason != null) reasons.add(locationReason);

    final breakdown = MatchScoreBreakdown(
      industryScore: industryScore,
      stageScore: stageScore,
      amountScore: amountScore,
      locationScore: locationScore,
    );

    final totalScore = breakdown.totalScore.clamp(0.0, 100.0);

    return RecommendationEntity(
      startup: startup,
      investorId: investor.id,
      compatibilityScore: double.parse(totalScore.toStringAsFixed(1)),
      scoreBreakdown: breakdown,
      matchReasons: reasons,
      calculatedAt: DateTime.now(),
    );
  }

  // --- Dimension Evaluators ---

  (double, String?) _evaluateIndustry(InvestorEntity investor, StartupEntity startup) {
    if (investor.preferredIndustries.isEmpty ||
        investor.preferredIndustries.any((i) => i.toLowerCase() == 'any' || i.toLowerCase() == 'all')) {
      return (25.0, 'Open industry preferences — matches ${startup.industry}');
    }

    final normalizedPrefs = investor.preferredIndustries.map((e) => e.trim().toLowerCase()).toList();
    final normalizedStartupIndustry = startup.industry.trim().toLowerCase();

    // Exact primary industry match
    if (normalizedPrefs.contains(normalizedStartupIndustry)) {
      return (35.0, 'Exact Industry Match: ${startup.industry}');
    }

    // Secondary industry match
    for (final sec in startup.secondaryIndustries) {
      if (normalizedPrefs.contains(sec.trim().toLowerCase())) {
        return (20.0, 'Secondary Industry Alignment: $sec');
      }
    }

    return (0.0, null);
  }

  (double, String?) _evaluateStage(InvestorEntity investor, StartupEntity startup) {
    if (investor.preferredFundingStages.isEmpty ||
        investor.preferredFundingStages.any((s) => s.toLowerCase() == 'any' || s.toLowerCase() == 'all')) {
      return (20.0, 'Open stage preference — matches ${startup.fundingStage} stage');
    }

    final normalizedPrefs = investor.preferredFundingStages.map((e) => e.trim().toLowerCase()).toList();
    final startupStage = startup.fundingStage.trim().toLowerCase();

    // Exact stage match
    if (normalizedPrefs.contains(startupStage)) {
      return (25.0, 'Funding Stage Match: ${startup.fundingStage}');
    }

    // Check adjacent stage compatibility (e.g., Pre-Seed vs Seed, Seed vs Series A)
    if (_isAdjacentStage(normalizedPrefs, startupStage)) {
      return (12.0, 'Adjacent Stage: ${startup.fundingStage} (compatible with your focus)');
    }

    return (0.0, null);
  }

  (double, String?) _evaluateAmount(InvestorEntity investor, StartupEntity startup) {
    final min = investor.minInvestmentAmount;
    final max = investor.maxInvestmentAmount;
    final target = startup.targetFunding;

    // Investor has no specified budget constraints
    if (min == null && max == null) {
      return (20.0, 'Flexible Ticket Size — Target: ${_formatCurrency(target)}');
    }

    final effectiveMin = min ?? 0.0;
    final effectiveMax = max ?? double.infinity;

    // Exact fit within budget range
    if (target >= effectiveMin && target <= effectiveMax) {
      final rangeText = max != null
          ? '${_formatCurrency(effectiveMin)} – ${_formatCurrency(effectiveMax)}'
          : '> ${_formatCurrency(effectiveMin)}';
      return (25.0, 'Funding Target (${_formatCurrency(target)}) fits your budget range ($rangeText)');
    }

    // Within 25% boundary tolerance
    final minWithTolerance = effectiveMin * 0.75;
    final maxWithTolerance = effectiveMax * 1.25;
    if (target >= minWithTolerance && target <= maxWithTolerance) {
      return (15.0, 'Funding Target (${_formatCurrency(target)}) close to your investment range');
    }

    // Minimum ticket check size is within range
    if (startup.minTicketSize != null && startup.minTicketSize! <= effectiveMax) {
      return (15.0, 'Minimum check size (${_formatCurrency(startup.minTicketSize!)}) is within your capacity');
    }

    return (0.0, null);
  }

  (double, String?) _evaluateLocation(InvestorEntity investor, StartupEntity startup) {
    if (investor.preferredLocations.isEmpty ||
        investor.preferredLocations.any((l) =>
            l.toLowerCase() == 'any' ||
            l.toLowerCase() == 'remote' ||
            l.toLowerCase().contains('all ethiopia') ||
            l.toLowerCase().contains('all'))) {
      return (15.0, 'Flexible Location: Operating in ${startup.location}');
    }

    final normalizedPrefs = investor.preferredLocations.map((e) => e.trim().toLowerCase()).toList();
    final startupLoc = startup.location.trim().toLowerCase();

    if (normalizedPrefs.contains(startupLoc)) {
      return (15.0, 'Location Match: ${startup.location}');
    }

    // Secondary score for Ethiopian regional opportunities
    return (5.0, 'Regional Opportunity: ${startup.location}');
  }

  bool _isAdjacentStage(List<String> investorPrefs, String startupStage) {
    const stageOrder = [
      'idea',
      'concept',
      'pre-seed',
      'seed',
      'series a',
      'series b',
      'series c',
      'growth',
    ];

    final startupIndex = stageOrder.indexWhere((s) => startupStage.contains(s));
    if (startupIndex == -1) return false;

    for (final pref in investorPrefs) {
      final prefIndex = stageOrder.indexWhere((s) => pref.contains(s));
      if (prefIndex != -1 && (prefIndex - startupIndex).abs() == 1) {
        return true;
      }
    }
    return false;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }
}
