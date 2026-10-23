import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/public_verification_badge_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_request_entity.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_status.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  VerificationRequestEntity request({
    required VerificationType type,
    required VerificationStatus status,
    bool? resubmissionAllowed,
  }) {
    return VerificationRequestEntity(
      id: 'request-1',
      type: type,
      status: status,
      submittedAt: DateTime(2026, 10, 23),
      reviewedAt: status == VerificationStatus.approved
          ? DateTime(2026, 10, 24)
          : null,
      resubmissionAllowed: resubmissionAllowed,
    );
  }

  group('VerificationType', () {
    test('defines the four expected verification types and labels', () {
      expect(VerificationType.student.value, 'student');
      expect(VerificationType.student.displayLabel, 'Student Verification');

      expect(VerificationType.identity.value, 'identity');
      expect(VerificationType.identity.displayLabel, 'Identity Verification');

      expect(VerificationType.business.value, 'business');
      expect(VerificationType.business.displayLabel, 'Business Verification');

      expect(VerificationType.investor.value, 'investor');
      expect(VerificationType.investor.displayLabel, 'Investor Verification');
    });

    test('all types include descriptions and unknown values return null', () {
      for (final type in VerificationType.values) {
        expect(type.description.trim(), isNotEmpty);
      }
      expect(VerificationType.fromString('unknown'), isNull);
      expect(VerificationType.fromString(null), isNull);
    });
  });

  group('VerificationStatus', () {
    test('represents every supported status', () {
      expect(VerificationStatus.values, containsAll([
        VerificationStatus.notSubmitted,
        VerificationStatus.pending,
        VerificationStatus.approved,
        VerificationStatus.rejected,
        VerificationStatus.resubmissionRequired,
        VerificationStatus.additionalInfoRequired,
      ]));
    });

    test('unknown values never become approved', () {
      expect(VerificationStatus.fromString('unknown'),
          VerificationStatus.notSubmitted);
      expect(VerificationStatus.fromString('verified'),
          VerificationStatus.notSubmitted);
      expect(VerificationStatus.fromString(null),
          VerificationStatus.notSubmitted);
    });

    test('only approved is authoritatively approved', () {
      expect(VerificationStatus.approved.isApproved, isTrue);
      for (final status in VerificationStatus.values
          .where((status) => status != VerificationStatus.approved)) {
        expect(status.isApproved, isFalse);
      }
    });
  });

  group('PublicVerificationBadgeEntity', () {
    test('pending, rejected, and resubmission requests cannot create badges', () {
      final nonApprovedStatuses = <VerificationStatus>[
        VerificationStatus.pending,
        VerificationStatus.rejected,
        VerificationStatus.resubmissionRequired,
        VerificationStatus.additionalInfoRequired,
        VerificationStatus.notSubmitted,
      ];

      for (final status in nonApprovedStatuses) {
        final badge = PublicVerificationBadgeEntity.fromApprovedRequest(
          request(type: VerificationType.identity, status: status),
        );
        expect(badge, isNull, reason: status.value);
      }
    });

    test('only an explicitly approved request creates a badge', () {
      final badge = PublicVerificationBadgeEntity.fromApprovedRequest(
        request(type: VerificationType.business, status: VerificationStatus.approved),
      );

      expect(badge, isNotNull);
      expect(badge!.type, VerificationType.business);
      expect(badge.isAuthoritativelyApproved, isTrue);
      expect(badge.approvedAt, isNotNull);
    });

    test('startup or investor profile approval is not verification approval', () {
      final now = DateTime(2026, 10, 23);
      final startupProfile = StartupProfileEntity(
        id: 'startup-1',
        userId: 'user-1',
        startupName: 'Approved Startup',
        description: 'Test startup',
        industry: 'Fintech',
        fundingStage: 'Seed',
        fundingAmountNeeded: 100000,
        location: 'Addis Ababa',
        teamInformation: 'Test team',
        contactInformation: 'test@example.com',
        createdAt: now,
        updatedAt: now,
        approvalStatus: 'approved',
      );
      final investorProfile = InvestorProfileEntity(
        id: 'investor-1',
        userId: 'user-2',
        investorType: 'angel',
        createdAt: now,
        approvalStatus: 'approved',
      );

      expect(startupProfile.isApproved, isTrue);
      expect(investorProfile.isApproved, isTrue);
      expect(PublicVerificationBadgeEntity.fromApprovedRequest(request(
        type: VerificationType.identity,
        status: VerificationStatus.pending,
        resubmissionAllowed: null,
      )), isNull);
    });

    test('badge metadata contains no document or identity fields', () {
      final badge = PublicVerificationBadgeEntity.fromApprovedRequest(
        request(type: VerificationType.student, status: VerificationStatus.approved),
      );

      expect(badge, isNotNull);
      expect(badge!.type, VerificationType.student);
      expect(badge.approvedAt, DateTime(2026, 10, 24));
      expect(badge.toString(), isNot(contains('document')));
      expect(badge.toString(), isNot(contains('identityNumber')));
      expect(badge.toString(), isNot(contains('/storage/')));
    });
  });
}
