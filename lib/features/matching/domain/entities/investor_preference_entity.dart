import 'package:equatable/equatable.dart';

/// Investor preference entity used by recommendation matching engine.
class InvestorPreferenceEntity extends Equatable {
  final List<String> preferredIndustries;
  final List<String> preferredStages;
  final double minTicketSize;
  final double maxTicketSize;
  final List<String> preferredLocations;

  const InvestorPreferenceEntity({
    required this.preferredIndustries,
    required this.preferredStages,
    required this.minTicketSize,
    required this.maxTicketSize,
    required this.preferredLocations,
  });

  factory InvestorPreferenceEntity.defaultPreferences() {
    return const InvestorPreferenceEntity(
      preferredIndustries: ['FinTech', 'AgriTech', 'HealthTech', 'AI / ML'],
      preferredStages: ['Seed', 'Series A'],
      minTicketSize: 10000,
      maxTicketSize: 500000,
      preferredLocations: ['Addis Ababa', 'Remote', 'Regional Hubs'],
    );
  }

  InvestorPreferenceEntity copyWith({
    List<String>? preferredIndustries,
    List<String>? preferredStages,
    double? minTicketSize,
    double? maxTicketSize,
    List<String>? preferredLocations,
  }) {
    return InvestorPreferenceEntity(
      preferredIndustries: preferredIndustries ?? this.preferredIndustries,
      preferredStages: preferredStages ?? this.preferredStages,
      minTicketSize: minTicketSize ?? this.minTicketSize,
      maxTicketSize: maxTicketSize ?? this.maxTicketSize,
      preferredLocations: preferredLocations ?? this.preferredLocations,
    );
  }

  @override
  List<Object?> get props => [
    preferredIndustries,
    preferredStages,
    minTicketSize,
    maxTicketSize,
    preferredLocations,
  ];
}
