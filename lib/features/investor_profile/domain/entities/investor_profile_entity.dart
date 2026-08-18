import 'package:flutter/foundation.dart';

/// Domain representation of a row in [public.investor_profiles].
///
/// [userId] references [public.users.id] and is unique per profile.
@immutable
class InvestorProfileEntity {
  const InvestorProfileEntity({
    required this.id,
    required this.userId,
    required this.investorType,
    this.organizationName,
    this.bio,
    this.preferredIndustries = const [],
    this.preferredStages = const [],
    this.ticketSizeMin,
    this.ticketSizeMax,
    this.geographicFocus = const [],
    required this.createdAt,
  }) : assert(
         ticketSizeMin == null ||
             ticketSizeMax == null ||
             ticketSizeMax >= ticketSizeMin,
         'ticketSizeMax must be greater than or equal to ticketSizeMin',
       );

  final String id;
  final String userId;
  final String investorType;
  final String? organizationName;
  final String? bio;
  final List<String> preferredIndustries;
  final List<String> preferredStages;
  final double? ticketSizeMin;
  final double? ticketSizeMax;
  final List<String> geographicFocus;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is InvestorProfileEntity &&
            id == other.id &&
            userId == other.userId &&
            investorType == other.investorType &&
            organizationName == other.organizationName &&
            bio == other.bio &&
            listEquals(preferredIndustries, other.preferredIndustries) &&
            listEquals(preferredStages, other.preferredStages) &&
            ticketSizeMin == other.ticketSizeMin &&
            ticketSizeMax == other.ticketSizeMax &&
            listEquals(geographicFocus, other.geographicFocus) &&
            createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      investorType,
      organizationName,
      bio,
      Object.hashAll(preferredIndustries),
      Object.hashAll(preferredStages),
      ticketSizeMin,
      ticketSizeMax,
      Object.hashAll(geographicFocus),
      createdAt,
    );
  }
}
