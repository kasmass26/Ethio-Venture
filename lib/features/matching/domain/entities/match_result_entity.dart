import 'startup_profile_entity.dart';

/// The outcome of running the compatibility scoring algorithm between
/// a single startup and the authenticated investor.
class MatchResultEntity {
  final StartupProfileEntity startup;

  /// Overall compatibility score 0–100.
  final int overallScore;

  /// Whether industry preference matched.
  final bool industryMatch;

  /// Whether funding stage preference matched.
  final bool stageMatch;

  /// Whether the startup's funding target falls within the investor's
  /// ticket range.
  final bool amountCompatible;

  /// Whether the startup's location matches a preferred location.
  final bool locationMatch;

  const MatchResultEntity({
    required this.startup,
    required this.overallScore,
    required this.industryMatch,
    required this.stageMatch,
    required this.amountCompatible,
    required this.locationMatch,
  });

  /// Human-readable summary of why this startup was recommended.
  List<String> get matchReasons {
    final reasons = <String>[];
    if (industryMatch) reasons.add('Industry match');
    if (stageMatch) reasons.add('Funding stage match');
    if (amountCompatible) reasons.add('Investment amount compatible');
    if (locationMatch) reasons.add('Location match');
    return reasons;
  }
}
