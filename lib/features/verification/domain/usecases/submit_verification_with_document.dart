import 'dart:typed_data';

import '../entities/verification_request_entity.dart';
import '../entities/verification_type.dart';
import '../repositories/verification_repository.dart';

/// Submits a verification request together with supporting document evidence.
///
/// Sequences:
///   1. Insert a pending [public.verification_requests] row.
///   2. Upload [fileBytes] to the private `verification-documents` Storage
///      bucket at `{userId}/{requestId}/{sanitizedFilename}`.
///   3. Insert a [public.verification_documents] metadata row.
///
/// Returns the created [VerificationRequestEntity] on success.
/// Throws a typed [AppException] on any failure; the caller is responsible
/// for surfacing the error and offering a retry.
class SubmitVerificationWithDocument {
  const SubmitVerificationWithDocument(this._repository);

  final VerificationRepository _repository;

  Future<VerificationRequestEntity> call({
    required VerificationType type,
    required Uint8List fileBytes,
    required String filename,
    required int fileSizeBytes,
  }) {
    return _repository.submitWithDocument(
      type: type,
      fileBytes: fileBytes,
      filename: filename,
      fileSizeBytes: fileSizeBytes,
    );
  }
}
