import 'package:flutter/foundation.dart';

/// Metadata for one document row in [public.verification_documents].
///
/// The private Storage path is stored but must never be rendered in the UI
/// directly. Use a signed URL (obtained via a separate call) when the user
/// needs to preview or download the file.
@immutable
class VerificationDocumentEntity {
  const VerificationDocumentEntity({
    required this.id,
    required this.requestId,
    required this.userId,
    required this.storagePath,
    required this.originalFilename,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.createdAt,
  });

  final String id;
  final String requestId;
  final String userId;

  /// Private Storage object path: `{userId}/{requestId}/{sanitizedFilename}`.
  /// Never expose this directly to the user.
  final String storagePath;

  /// Original filename as provided by the user (display-only).
  final String originalFilename;

  /// MIME type: `image/jpeg`, `image/png`, or `application/pdf`.
  final String mimeType;

  /// File size in bytes (1 … 10 485 760).
  final int fileSizeBytes;

  final DateTime createdAt;

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
