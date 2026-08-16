import 'package:equatable/equatable.dart';
import 'startup_entity.dart';

/// Entity representing an AI/algorithm investment recommendation match.
class RecommendationEntity extends Equatable {
  final StartupEntity startup;
  final double matchScore; // Match score percentage e.g., 95.5
  final List<String> matchReasons;
  final List<String> matchingTags;

  const RecommendationEntity({
    required this.startup,
    required this.matchScore,
    required this.matchReasons,
    required this.matchingTags,
  });

  String get formattedMatchScore => '${matchScore.toStringAsFixed(0)}% Match';

  @override
  List<Object?> get props => [startup, matchScore, matchReasons, matchingTags];
}
