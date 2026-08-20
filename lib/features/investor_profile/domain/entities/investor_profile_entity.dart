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
    this.approvalStatus = 'pending',
    this.rejectionReason,
    this.approvalDate,
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
  final String approvalStatus;
  final String? rejectionReason;
  final DateTime? approvalDate;

  bool get isApproved => approvalStatus == 'approved';
  bool get isPending => approvalStatus == 'pending';
  bool get isRejected => approvalStatus == 'rejected';

  InvestorProfileEntity copyWith({
    String? id,
    String? userId,
    String? investorType,
    String? organizationName,
    String? bio,
    List<String>? preferredIndustries,
    List<String>? preferredStages,
    double? ticketSizeMin,
    double? ticketSizeMax,
    List<String>? geographicFocus,
    DateTime? createdAt,
    String? approvalStatus,
    String? rejectionReason,
    DateTime? approvalDate,
  }) {
    return InvestorProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      investorType: investorType ?? this.investorType,
      organizationName: organizationName ?? this.organizationName,
      bio: bio ?? this.bio,
      preferredIndustries: preferredIndustries ?? this.preferredIndustries,
      preferredStages: preferredStages ?? this.preferredStages,
      ticketSizeMin: ticketSizeMin ?? this.ticketSizeMin,
      ticketSizeMax: ticketSizeMax ?? this.ticketSizeMax,
      geographicFocus: geographicFocus ?? this.geographicFocus,
      createdAt: createdAt ?? this.createdAt,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvalDate: approvalDate ?? this.approvalDate,
    );
  }

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
            createdAt == other.createdAt &&
            approvalStatus == other.approvalStatus &&
            rejectionReason == other.rejectionReason &&
            approvalDate == other.approvalDate;
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
      approvalStatus,
      rejectionReason,
      approvalDate,
    );
  }
}
