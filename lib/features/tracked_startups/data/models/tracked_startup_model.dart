import 'package:ethioventure/features/startup_profile/data/models/startup_profile_model.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/tracked_startups/domain/entities/tracked_startup_entity.dart';

/// Data model representing a row in [public.tracked_startups], with joined [StartupProfileModel].
class TrackedStartupModel extends TrackedStartupEntity {
  const TrackedStartupModel({
    required super.id,
    required super.investorUserId,
    required super.startupId,
    required super.createdAt,
    required super.startup,
  });

  factory TrackedStartupModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedCreated;
    try {
      parsedCreated = json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now();
    } catch (_) {
      parsedCreated = DateTime.now();
    }

    StartupProfileEntity startupEntity;
    final startupData = json['startup_profiles'];
    if (startupData is Map<String, dynamic>) {
      startupEntity = StartupProfileModel.fromJson(startupData);
    } else if (startupData is Map) {
      startupEntity = StartupProfileModel.fromJson(
        Map<String, dynamic>.from(startupData),
      );
    } else if (startupData is List && startupData.isNotEmpty) {
      final first = startupData.first;
      if (first is Map) {
        startupEntity = StartupProfileModel.fromJson(
          Map<String, dynamic>.from(first),
        );
      } else {
        startupEntity = _fallbackStartup(json);
      }
    } else {
      startupEntity = _fallbackStartup(json);
    }

    return TrackedStartupModel(
      id: json['id']?.toString() ?? '',
      investorUserId: json['investor_user_id']?.toString() ?? '',
      startupId: json['startup_id']?.toString() ?? '',
      createdAt: parsedCreated,
      startup: startupEntity,
    );
  }

  static StartupProfileEntity _fallbackStartup(Map<String, dynamic> json) {
    final startupId = json['startup_id']?.toString() ?? '';
    final name = json['startup_name']?.toString() ?? '';
    return StartupProfileEntity(
      id: startupId,
      userId: '',
      startupName: name.isNotEmpty ? name : 'Startup',
      description: '',
      industry: 'General',
      fundingStage: 'Seed',
      fundingAmountNeeded: 0,
      location: '',
      teamInformation: '',
      contactInformation: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'investor_user_id': investorUserId,
      'startup_id': startupId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
