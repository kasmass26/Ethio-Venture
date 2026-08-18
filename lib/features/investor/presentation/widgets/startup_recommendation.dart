/// A startup surfaced to the investor in the "Recommended for You" rail.
class StartupRecommendation {
  final String id;
  final String name;
  final String tagline;
  final List<String> tags;
  final int matchScore;
  final String? logoUrl;

  const StartupRecommendation({
    required this.id,
    required this.name,
    required this.tagline,
    required this.tags,
    required this.matchScore,
    this.logoUrl,
  });
}