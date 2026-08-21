import 'package:flutter/foundation.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';

/// Domain representation of a tracked startup in [public.tracked_startups].
@immutable
class TrackedStartupEntity {
  const TrackedStartupEntity({
    required this.id,
    required this.investorUserId,
    required this.startupId,
    required this.createdAt,
    required this.startup,
  });

  /// Primary key of the tracked_startups row.
  final String id;

  /// Foreign key → auth.users.id of the investor.
  final String investorUserId;

  /// Foreign key → public.startup_profiles.id.
  final String startupId;

  /// Timestamp when the startup was tracked.
  final DateTime createdAt;

  /// Associated startup profile entity.
  final StartupProfileEntity startup;

  /// Startup display name.
  String get name => startup.startupName;

  /// Formatted funding goal label (e.g., "Seeking $500K • Seed").
  String get fundingGoalLabel {
    final formattedAmount = _formatFunding(startup.fundingAmountNeeded);
    final stage = startup.fundingStage.trim();

    if (formattedAmount.isNotEmpty && stage.isNotEmpty) {
      return 'Seeking $formattedAmount • $stage';
    } else if (formattedAmount.isNotEmpty) {
      return 'Seeking $formattedAmount';
    } else if (stage.isNotEmpty) {
      return 'Stage: $stage';
    }
    return 'Seeking Investment';
  }

  /// Calculates funding / development progress percentage based on stage & funding data.
  int get progressPercent {
    final stage = startup.fundingStage.toLowerCase();
    if (stage.contains('series b') || stage.contains('series c') || stage.contains('growth')) {
      return 95;
    } else if (stage.contains('series a')) {
      return 80;
    } else if (stage.contains('seed') && !stage.contains('pre')) {
      return 65;
    } else if (stage.contains('pre-seed') || stage.contains('pre seed') || stage.contains('mvp') || stage.contains('early')) {
      return 45;
    } else if (stage.contains('idea') || stage.contains('concept')) {
      return 25;
    }
    return 50;
  }

  static String _formatFunding(double amount) {
    if (amount <= 0) return '';
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return '\$${m == m.truncateToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      final k = amount / 1000;
      return '\$${k == k.truncateToDouble() ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}k';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackedStartupEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          investorUserId == other.investorUserId &&
          startupId == other.startupId &&
          createdAt == other.createdAt &&
          startup == other.startup;

  @override
  int get hashCode => Object.hash(id, investorUserId, startupId, createdAt, startup);
}
