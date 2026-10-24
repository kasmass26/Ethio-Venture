import 'package:ethioventure/features/verification/data/models/verification_request_model.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_status.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VerificationRequestModel', () {
    test('parses Supabase columns and serializes database names', () {
      final model = VerificationRequestModel.fromJson({
        'id': 'request-1',
        'verification_type': 'identity',
        'status': 'resubmission_required',
        'submitted_at': '2026-10-24T10:30:00Z',
        'reviewed_at': '2026-10-24T11:30:00Z',
        'message': 'Provide a clearer document image.',
        'resubmission_allowed': true,
        'document_path': '/private/secret/path',
      });

      expect(model.id, 'request-1');
      expect(model.type, VerificationType.identity);
      expect(model.status, VerificationStatus.resubmissionRequired);
      expect(model.submittedAt?.isUtc, isTrue);
      expect(model.reviewedAt?.isUtc, isTrue);
      expect(model.message, 'Provide a clearer document image.');
      expect(model.resubmissionAllowed, isTrue);

      final json = model.toJson();
      expect(json.keys, {
        'id',
        'verification_type',
        'status',
        'submitted_at',
        'reviewed_at',
        'message',
        'resubmission_allowed',
      });
      expect(json['verification_type'], 'identity');
      expect(json['status'], 'resubmission_required');
      expect(json.containsKey('document_path'), isFalse);
    });

    test('maps additional-info status explicitly', () {
      final model = VerificationRequestModel.fromJson({
        'id': 'request-2',
        'verification_type': 'business',
        'status': 'additional_info_required',
      });

      expect(model.status, VerificationStatus.additionalInfoRequired);
      expect(model.status.value, 'additional_info_required');
      expect(model.submittedAt, isNull);
      expect(model.reviewedAt, isNull);
      expect(model.message, isNull);
      expect(model.resubmissionAllowed, isNull);
    });

    test('unknown status does not become approved', () {
      final model = VerificationRequestModel.fromJson({
        'id': 'request-3',
        'verification_type': 'investor',
        'status': 'verified',
        'submitted_at': 'not-a-date',
        'reviewed_at': 'also-not-a-date',
      });

      expect(model.status, VerificationStatus.notSubmitted);
      expect(model.status.isApproved, isFalse);
      expect(model.submittedAt, isNull);
      expect(model.reviewedAt, isNull);
    });

    test('rejects unsupported verification types', () {
      expect(
        () => VerificationRequestModel.fromJson({
          'id': 'request-4',
          'verification_type': 'unknown',
          'status': 'pending',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
