/// Represents a Startup showcasing on Ethio Venture for fundraising.
class StartupEntity {
  final String id;
  final String founderId;
  final String name;
  final String tagline;
  final String description;
  final String industry;
  final List<String> secondaryIndustries;
  final String fundingStage;
  final double targetFunding;
  final double? minTicketSize;
  final String location;
  final String? logoUrl;
  final String? website;
  final String? pitchDeckUrl;
  final Map<String, dynamic> tractionHighlights;
  final DateTime createdAt;

  const StartupEntity({
    required this.id,
    required this.founderId,
    required this.name,
    required this.tagline,
    required this.description,
    required this.industry,
    this.secondaryIndustries = const [],
    required this.fundingStage,
    required this.targetFunding,
    this.minTicketSize,
    required this.location,
    this.logoUrl,
    this.website,
    this.pitchDeckUrl,
    this.tractionHighlights = const {},
    required this.createdAt,
  });

  StartupEntity copyWith({
    String? id,
    String? founderId,
    String? name,
    String? tagline,
    String? description,
    String? industry,
    List<String>? secondaryIndustries,
    String? fundingStage,
    double? targetFunding,
    double? minTicketSize,
    String? location,
    String? logoUrl,
    String? website,
    String? pitchDeckUrl,
    Map<String, dynamic>? tractionHighlights,
    DateTime? createdAt,
  }) {
    return StartupEntity(
      id: id ?? this.id,
      founderId: founderId ?? this.founderId,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      secondaryIndustries: secondaryIndustries ?? this.secondaryIndustries,
      fundingStage: fundingStage ?? this.fundingStage,
      targetFunding: targetFunding ?? this.targetFunding,
      minTicketSize: minTicketSize ?? this.minTicketSize,
      location: location ?? this.location,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      pitchDeckUrl: pitchDeckUrl ?? this.pitchDeckUrl,
      tractionHighlights: tractionHighlights ?? this.tractionHighlights,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
