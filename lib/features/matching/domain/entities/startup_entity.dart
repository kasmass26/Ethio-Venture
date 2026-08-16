import 'package:equatable/equatable.dart';

/// Entity representing a Startup profile for search, filtering, and recommendations.
class StartupEntity extends Equatable {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final String industry;
  final String fundingStage; // e.g., Pre-seed, Seed, Series A, Series B
  final double targetAmount;
  final double raisedAmount;
  final String location;
  final String logoUrl;
  final String pitchDeckUrl;
  final String founderName;
  final List<String> tags;
  final double rating;
  final DateTime createdAt;

  const StartupEntity({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.industry,
    required this.fundingStage,
    required this.targetAmount,
    required this.raisedAmount,
    required this.location,
    required this.logoUrl,
    required this.pitchDeckUrl,
    required this.founderName,
    required this.tags,
    required this.rating,
    required this.createdAt,
  });

  double get fundingProgressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (raisedAmount / targetAmount).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    tagline,
    description,
    industry,
    fundingStage,
    targetAmount,
    raisedAmount,
    location,
    logoUrl,
    pitchDeckUrl,
    founderName,
    tags,
    rating,
    createdAt,
  ];
}
