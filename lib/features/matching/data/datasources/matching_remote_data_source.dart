import '../../domain/entities/investor_preference_entity.dart';
import '../../domain/entities/startup_filter_params.dart';
import '../models/recommendation_model.dart';
import '../models/startup_model.dart';

abstract class MatchingRemoteDataSource {
  Future<List<StartupModel>> searchStartups(StartupFilterParams params);

  Future<List<RecommendationModel>> getRecommendations(
    String userId,
    InvestorPreferenceEntity preference,
  );
}

class MatchingRemoteDataSourceImpl implements MatchingRemoteDataSource {
  // In-memory initial dataset of realistic Ethiopian startups
  final List<StartupModel> _mockStartups = [
    StartupModel(
      id: 'st_01',
      name: 'Chapa Financial',
      tagline:
          'Modern payment gateway connecting Ethiopian merchants to global ecommerce.',
      description:
          'Chapa provides robust REST APIs and developer-first SDKs enabling businesses in Ethiopia to process digital payments seamlessly via Telebirr, CBE Birr, cards, and bank transfers.',
      industry: 'FinTech',
      fundingStage: 'Series A',
      targetAmount: 1500000.0,
      raisedAmount: 950000.0,
      location: 'Addis Ababa',
      logoUrl: 'https://via.placeholder.com/150/1B4332/FFFFFF?text=Chapa',
      pitchDeckUrl: 'https://ethioventure.com/decks/chapa.pdf',
      founderName: 'Nael Hailemariam',
      tags: const ['Payments', 'FinTech', 'API', 'Banking', 'Scaleup'],
      rating: 4.9,
      createdAt: DateTime(2025, 1, 15),
    ),
    StartupModel(
      id: 'st_02',
      name: 'Gebeya Tech',
      tagline:
          'Pan-African talent marketplace empowering software engineers and tech talent.',
      description:
          'Gebeya bridges the African tech talent gap by training, vetting, and matching world-class software engineers and tech professionals with global tech enterprises.',
      industry: 'EdTech',
      fundingStage: 'Series A',
      targetAmount: 2000000.0,
      raisedAmount: 1400000.0,
      location: 'Addis Ababa',
      logoUrl: 'https://via.placeholder.com/150/52796F/FFFFFF?text=Gebeya',
      pitchDeckUrl: 'https://ethioventure.com/decks/gebeya.pdf',
      founderName: 'Amadou Daffe',
      tags: const ['EdTech', 'Talent', 'Outsourcing', 'Pan-African'],
      rating: 4.8,
      createdAt: DateTime(2025, 2, 1),
    ),
    StartupModel(
      id: 'st_03',
      name: 'AgriEthiopia Smart Hub',
      tagline:
          'IoT-powered precision agriculture and digital marketplace for smallholders.',
      description:
          'AgriEthiopia leverages soil sensors, weather intelligence, and digital supply chains to boost crop yields by 35% and connect coffee & teff farmers directly to exporters.',
      industry: 'AgriTech',
      fundingStage: 'Seed',
      targetAmount: 500000.0,
      raisedAmount: 320000.0,
      location: 'Hawassa',
      logoUrl: 'https://via.placeholder.com/150/2D6A4F/FFFFFF?text=Agri',
      pitchDeckUrl: 'https://ethioventure.com/decks/agriethiopia.pdf',
      founderName: 'Tigist Alemayehu',
      tags: const ['AgriTech', 'IoT', 'Supply Chain', 'Coffee', 'Impact'],
      rating: 4.7,
      createdAt: DateTime(2025, 3, 10),
    ),
    StartupModel(
      id: 'st_04',
      name: 'TenaCare AI Health',
      tagline:
          'AI diagnostic platform & telemedicine solution for rural healthcare clinics.',
      description:
          'TenaCare provides handheld medical ultrasound devices backed by deep learning computer vision models to detect maternal & cardiac anomalies early in remote health posts.',
      industry: 'HealthTech',
      fundingStage: 'Seed',
      targetAmount: 750000.0,
      raisedAmount: 480000.0,
      location: 'Jimma',
      logoUrl: 'https://via.placeholder.com/150/B08968/FFFFFF?text=TenaCare',
      pitchDeckUrl: 'https://ethioventure.com/decks/tenacare.pdf',
      founderName: 'Dr. Yosef Kebede',
      tags: const ['HealthTech', 'AI', 'Telemedicine', 'MedTech'],
      rating: 4.9,
      createdAt: DateTime(2025, 4, 5),
    ),
    StartupModel(
      id: 'st_05',
      name: 'ArifPay POS Solutions',
      tagline:
          'Point of sale and mPOS terminal infrastructure for MSMEs across Ethiopia.',
      description:
          'ArifPay equips local supermarkets, pharmacy chains, and retail stores with contact-free Smart POS terminals integrated directly into national payment switches.',
      industry: 'FinTech',
      fundingStage: 'Pre-seed',
      targetAmount: 300000.0,
      raisedAmount: 180000.0,
      location: 'Addis Ababa',
      logoUrl: 'https://via.placeholder.com/150/1B1B1B/FFFFFF?text=ArifPay',
      pitchDeckUrl: 'https://ethioventure.com/decks/arifpay.pdf',
      founderName: 'Habtamu Tadesse',
      tags: const ['FinTech', 'mPOS', 'Retail', 'Payments'],
      rating: 4.6,
      createdAt: DateTime(2025, 5, 20),
    ),
    StartupModel(
      id: 'st_06',
      name: 'SunEthio Clean Energy',
      tagline:
          'Pay-As-You-Go solar home systems and mini-grids for off-grid communities.',
      description:
          'SunEthio manufactures modular solar kits powered by IoT smart meters, offering affordable micro-loans for off-grid rural households and agricultural water pumps.',
      industry: 'Renewable Energy',
      fundingStage: 'Seed',
      targetAmount: 850000.0,
      raisedAmount: 600000.0,
      location: 'Bahir Dar',
      logoUrl: 'https://via.placeholder.com/150/E9C46A/000000?text=SunEthio',
      pitchDeckUrl: 'https://ethioventure.com/decks/sunethio.pdf',
      founderName: 'Dawit Solomon',
      tags: const ['Solar', 'CleanTech', 'Off-Grid', 'IoT', 'Impact'],
      rating: 4.8,
      createdAt: DateTime(2025, 6, 12),
    ),
    StartupModel(
      id: 'st_07',
      name: 'Zemeda E-Commerce',
      tagline:
          'Social commerce and fast last-mile logistics fulfillment network.',
      description:
          'Zemeda digitizes local open markets by enabling micro-retailers to showcase goods online while leveraging electric two-wheeler delivery fleets for 60-minute doorstep delivery.',
      industry: 'E-commerce',
      fundingStage: 'Pre-seed',
      targetAmount: 250000.0,
      raisedAmount: 100000.0,
      location: 'Addis Ababa',
      logoUrl: 'https://via.placeholder.com/150/2A9D8F/FFFFFF?text=Zemeda',
      pitchDeckUrl: 'https://ethioventure.com/decks/zemeda.pdf',
      founderName: 'Marta Worku',
      tags: const ['E-commerce', 'Logistics', 'Last-Mile', 'Retail'],
      rating: 4.5,
      createdAt: DateTime(2025, 7, 1),
    ),
    StartupModel(
      id: 'st_08',
      name: 'EthioAI Mobility',
      tagline: 'Autonomous traffic management & fleet optimization platform.',
      description:
          'EthioAI optimizes public transport transit networks using computer vision and edge AI nodes placed at major urban intersections.',
      industry: 'AI / ML',
      fundingStage: 'Series B',
      targetAmount: 5000000.0,
      raisedAmount: 3200000.0,
      location: 'Addis Ababa',
      logoUrl: 'https://via.placeholder.com/150/457B9D/FFFFFF?text=EthioAI',
      pitchDeckUrl: 'https://ethioventure.com/decks/ethioai.pdf',
      founderName: 'Bereket Tsegaye',
      tags: const ['AI', 'Smart City', 'Transportation', 'DeepTech'],
      rating: 4.9,
      createdAt: DateTime(2025, 8, 2),
    ),
  ];

  @override
  Future<List<StartupModel>> searchStartups(StartupFilterParams params) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    var results = List<StartupModel>.from(_mockStartups);

    // 1. Text Query search (name, tagline, description, tags, founderName)
    if (params.query.trim().isNotEmpty) {
      final q = params.query.toLowerCase().trim();
      results = results.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.tagline.toLowerCase().contains(q) ||
            s.description.toLowerCase().contains(q) ||
            s.founderName.toLowerCase().contains(q) ||
            s.industry.toLowerCase().contains(q) ||
            s.tags.any((tag) => tag.toLowerCase().contains(q));
      }).toList();
    }

    // 2. Industry filter
    if (params.industry != null &&
        params.industry!.isNotEmpty &&
        params.industry != 'All') {
      results = results
          .where(
            (s) => s.industry.toLowerCase() == params.industry!.toLowerCase(),
          )
          .toList();
    }

    // 3. Funding Stage filter
    if (params.fundingStage != null &&
        params.fundingStage!.isNotEmpty &&
        params.fundingStage != 'All') {
      results = results
          .where(
            (s) =>
                s.fundingStage.toLowerCase() ==
                params.fundingStage!.toLowerCase(),
          )
          .toList();
    }

    // 4. Target Amount range filter
    if (params.minTargetAmount != null) {
      results = results
          .where((s) => s.targetAmount >= params.minTargetAmount!)
          .toList();
    }
    if (params.maxTargetAmount != null) {
      results = results
          .where((s) => s.targetAmount <= params.maxTargetAmount!)
          .toList();
    }

    // 5. Location filter
    if (params.location != null &&
        params.location!.isNotEmpty &&
        params.location != 'All') {
      results = results
          .where(
            (s) => s.location.toLowerCase().contains(
              params.location!.toLowerCase(),
            ),
          )
          .toList();
    }

    // 6. Sorting
    switch (params.sortBy) {
      case 'target_high':
        results.sort((a, b) => b.targetAmount.compareTo(a.targetAmount));
        break;
      case 'target_low':
        results.sort((a, b) => a.targetAmount.compareTo(b.targetAmount));
        break;
      case 'progress_high':
        results.sort(
          (a, b) => b.fundingProgressPercentage.compareTo(
            a.fundingProgressPercentage,
          ),
        );
        break;
      case 'newest':
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'relevance':
      default:
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return results;
  }

  @override
  Future<List<RecommendationModel>> getRecommendations(
    String userId,
    InvestorPreferenceEntity preference,
  ) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final List<RecommendationModel> recommendations = [];

    for (final startup in _mockStartups) {
      double score = 50.0; // Base score
      final List<String> reasons = [];
      final List<String> matchingTags = [];

      // Industry match (+25 points)
      final bool industryMatches = preference.preferredIndustries.any(
        (ind) => ind.toLowerCase() == startup.industry.toLowerCase(),
      );
      if (industryMatches) {
        score += 25.0;
        reasons.add('Industry matches your preference in ${startup.industry}');
        matchingTags.add(startup.industry);
      }

      // Funding Stage match (+15 points)
      final bool stageMatches = preference.preferredStages.any(
        (stg) => stg.toLowerCase() == startup.fundingStage.toLowerCase(),
      );
      if (stageMatches) {
        score += 15.0;
        reasons.add('${startup.fundingStage} stage fits your portfolio focus');
        matchingTags.add(startup.fundingStage);
      }

      // Target amount / ticket size check (+10 points)
      if (startup.targetAmount >= preference.minTicketSize &&
          startup.targetAmount <= preference.maxTicketSize * 5) {
        score += 10.0;
        reasons.add('Target funding is within your capital deployment range');
      }

      // Location match (+10 points)
      final bool locationMatches = preference.preferredLocations.any(
        (loc) =>
            loc.toLowerCase() == 'remote' ||
            startup.location.toLowerCase().contains(loc.toLowerCase()),
      );
      if (locationMatches) {
        score += 10.0;
        reasons.add('Based in your target region (${startup.location})');
        matchingTags.add(startup.location);
      }

      // High rating / momentum bonus
      if (startup.rating >= 4.7) {
        score += 5.0;
        reasons.add('Strong investor rating (${startup.rating}/5.0)');
      }

      // Clamp match score between 60% and 98%
      final double finalScore = score.clamp(60.0, 98.0);

      recommendations.add(
        RecommendationModel(
          startup: startup,
          matchScore: finalScore,
          matchReasons: reasons.isEmpty
              ? ['High potential growth startup in Ethiopian market']
              : reasons,
          matchingTags: matchingTags.isEmpty
              ? [startup.industry]
              : matchingTags,
        ),
      );
    }

    // Sort by highest match score first
    recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return recommendations;
  }
}
