import 'package:flutter/foundation.dart';

/// Domain entity representing an investor profile for discovery and recommendations
/// on the founder dashboard and investor catalog.
@immutable
class InvestorDiscoveryEntity {
  const InvestorDiscoveryEntity({
    required this.id,
    required this.userId,
    required this.investorType,
    this.organizationName,
    this.fullName,
    this.email,
    this.bio,
    this.preferredIndustries = const [],
    this.preferredStages = const [],
    this.ticketSizeMin,
    this.ticketSizeMax,
    this.geographicFocus = const [],
    this.approvalStatus = 'pending',
    required this.createdAt,
    this.matchScore = 50,
    this.matchReasons = const [],
    this.isSaved = false,
  });

  final String id;
  final String userId;
  final String investorType;
  final String? organizationName;
  final String? fullName;
  final String? email;
  final String? bio;
  final List<String> preferredIndustries;
  final List<String> preferredStages;
  final double? ticketSizeMin;
  final double? ticketSizeMax;
  final List<String> geographicFocus;
  final String approvalStatus;
  final DateTime createdAt;
  final int matchScore;
  final List<String> matchReasons;
  final bool isSaved;

  bool get isApproved => approvalStatus.toLowerCase().trim() == 'approved';

  /// Primary display name
  String get displayName {
    if (organizationName != null && organizationName!.trim().isNotEmpty) {
      return organizationName!.trim();
    }
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    return 'Angel Investor';
  }

  /// Secondary subtitle / contact line
  String? get subtitle {
    if (organizationName != null &&
        organizationName!.trim().isNotEmpty &&
        fullName != null &&
        fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    return null;
  }

  /// Formatted investor type label
  String get investorTypeLabel {
    final lower = investorType.toLowerCase();
    if (lower.contains('angel')) return 'Angel Investor';
    if (lower.contains('vc') || lower.contains('venture')) return 'Venture Capital';
    if (lower.contains('firm') || lower.contains('syndicate')) return 'Investment Syndicate';
    return 'Investor';
  }

  /// Formatted location
  String get locationDisplay {
    if (geographicFocus.isNotEmpty) {
      return geographicFocus.take(2).join(', ');
    }
    return 'Addis Ababa, ETH';
  }

  /// Formatted ticket size range (e.g. "$50K - $500K" or "$100K+")
  String get ticketSizeDisplay {
    if (ticketSizeMin == null && ticketSizeMax == null) {
      return 'Flexible Ticket';
    }
    if (ticketSizeMin != null && ticketSizeMax != null) {
      return '${_formatCompact(ticketSizeMin!)} - ${_formatCompact(ticketSizeMax!)}';
    }
    if (ticketSizeMin != null) {
      return '${_formatCompact(ticketSizeMin!)}+';
    }
    return 'Up to ${_formatCompact(ticketSizeMax!)}';
  }

  static String _formatCompact(double value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return '\$${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
    } else if (value >= 1000) {
      final k = value / 1000;
      return '\$${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    }
    return '\$${value.toInt()}';
  }

  InvestorDiscoveryEntity copyWith({
    int? matchScore,
    List<String>? matchReasons,
    bool? isSaved,
  }) {
    return InvestorDiscoveryEntity(
      id: id,
      userId: userId,
      investorType: investorType,
      organizationName: organizationName,
      fullName: fullName,
      email: email,
      bio: bio,
      preferredIndustries: preferredIndustries,
      preferredStages: preferredStages,
      ticketSizeMin: ticketSizeMin,
      ticketSizeMax: ticketSizeMax,
      geographicFocus: geographicFocus,
      approvalStatus: approvalStatus,
      createdAt: createdAt,
      matchScore: matchScore ?? this.matchScore,
      matchReasons: matchReasons ?? this.matchReasons,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is InvestorDiscoveryEntity &&
            id == other.id &&
            userId == other.userId &&
            matchScore == other.matchScore &&
            isSaved == other.isSaved;
  }

  @override
  int get hashCode => Object.hash(id, userId, matchScore, isSaved);
}
