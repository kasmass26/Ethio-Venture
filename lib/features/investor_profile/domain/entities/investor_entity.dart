/// Represents an Investor and their investment thesis/preferences.
class InvestorEntity {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String companyName;
  final String bio;
  final String? avatarUrl;
  
  // Investment Preference Criteria
  final List<String> preferredIndustries;
  final List<String> preferredFundingStages;
  final double? minInvestmentAmount;
  final double? maxInvestmentAmount;
  final List<String> preferredLocations;
  final DateTime createdAt;

  const InvestorEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.companyName,
    required this.bio,
    this.avatarUrl,
    this.preferredIndustries = const [],
    this.preferredFundingStages = const [],
    this.minInvestmentAmount,
    this.maxInvestmentAmount,
    this.preferredLocations = const [],
    required this.createdAt,
  });

  /// Check if the investor has specified any preferences
  bool get hasPreferences =>
      preferredIndustries.isNotEmpty ||
      preferredFundingStages.isNotEmpty ||
      minInvestmentAmount != null ||
      maxInvestmentAmount != null ||
      preferredLocations.isNotEmpty;

  InvestorEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? companyName,
    String? bio,
    String? avatarUrl,
    List<String>? preferredIndustries,
    List<String>? preferredFundingStages,
    double? minInvestmentAmount,
    double? maxInvestmentAmount,
    List<String>? preferredLocations,
    DateTime? createdAt,
  }) {
    return InvestorEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      companyName: companyName ?? this.companyName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferredIndustries: preferredIndustries ?? this.preferredIndustries,
      preferredFundingStages: preferredFundingStages ?? this.preferredFundingStages,
      minInvestmentAmount: minInvestmentAmount ?? this.minInvestmentAmount,
      maxInvestmentAmount: maxInvestmentAmount ?? this.maxInvestmentAmount,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
