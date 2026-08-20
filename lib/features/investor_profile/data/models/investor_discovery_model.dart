import '../../domain/entities/investor_discovery_entity.dart';

class InvestorDiscoveryModel extends InvestorDiscoveryEntity {
  const InvestorDiscoveryModel({
    required super.id,
    required super.userId,
    required super.investorType,
    super.organizationName,
    super.fullName,
    super.email,
    super.bio,
    super.preferredIndustries,
    super.preferredStages,
    super.ticketSizeMin,
    super.ticketSizeMax,
    super.geographicFocus,
    super.approvalStatus,
    required super.createdAt,
    super.matchScore,
    super.matchReasons,
    super.isSaved,
  });

  factory InvestorDiscoveryModel.fromJson(Map<String, dynamic> json) {
    String? fullName;
    String? email;
    if (json['users'] != null && json['users'] is Map) {
      final userMap = json['users'] as Map<String, dynamic>;
      fullName = userMap['full_name']?.toString();
      email = userMap['email']?.toString();
    }

    DateTime parsedCreated;
    try {
      parsedCreated = json['created_at'] != null
          ? (json['created_at'] is DateTime
              ? json['created_at'] as DateTime
              : DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now();
    } catch (_) {
      parsedCreated = DateTime.now();
    }

    return InvestorDiscoveryModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      investorType: json['investor_type']?.toString() ?? 'angel',
      organizationName: json['organization_name']?.toString(),
      fullName: fullName,
      email: email,
      bio: json['bio']?.toString(),
      preferredIndustries: _parseStringList(json['preferred_industries']),
      preferredStages: _parseStringList(json['preferred_stages']),
      ticketSizeMin: _parseDouble(json['ticket_size_min']),
      ticketSizeMax: _parseDouble(json['ticket_size_max']),
      geographicFocus: _parseStringList(json['geographic_focus']),
      approvalStatus: json['approval_status']?.toString() ?? 'approved',
      createdAt: parsedCreated,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String) {
      final str = value.trim();
      if ((str.startsWith('{') && str.endsWith('}')) ||
          (str.startsWith('[') && str.endsWith(']'))) {
        final inner = str.substring(1, str.length - 1);
        return inner
            .split(',')
            .map((s) => s.replaceAll('"', '').replaceAll("'", '').trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (str.isNotEmpty) return [str];
    }
    return const [];
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
