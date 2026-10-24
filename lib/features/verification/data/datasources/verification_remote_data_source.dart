import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show FileOptions, PostgrestException, StorageException, SupabaseClient;

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/public_verification_badge_entity.dart';
import '../../domain/entities/verification_request_entity.dart';
import '../../domain/entities/verification_status.dart';
import '../../domain/entities/verification_type.dart';
import '../models/verification_document_model.dart';
import '../models/verification_request_model.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kBucket = 'verification-documents';
const _kMaxBytes = 10 * 1024 * 1024; // 10 MB

/// Maps lowercase file extension → MIME type for the three allowed formats.
const _kMimeTypes = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'pdf': 'application/pdf',
};

// ── Abstract interface ─────────────────────────────────────────────────────────

abstract interface class VerificationRemoteDataSource {
  /// Returns all verification requests belonging to the authenticated user,
  /// ordered by submission date descending.
  Future<List<VerificationRequestModel>> getCurrentUserRequests();

  /// Creates a pending request, uploads [fileBytes] to private Storage, and
  /// inserts the document-metadata row — in that sequence.
  ///
  /// Failure handling:
  ///  • Request insert fails → throws, nothing uploaded.
  ///  • Upload fails after request insert → throws; orphaned request row
  ///    remains so the user can retry.
  ///  • Metadata insert fails after upload → throws; Storage object is kept
  ///    for a future retry.
  Future<VerificationRequestModel> submitWithDocument({
    required VerificationType type,
    required Uint8List fileBytes,
    required String filename,
    required int fileSizeBytes,
  });

  /// Inserts a minimal pending request row without uploading a document.
  /// Kept for backward compatibility with the existing cubit flow.
  Future<VerificationRequestModel> startVerificationRequest(
    VerificationType type,
  );

  /// Returns public approved-badge data for [profileId].
  /// Only reads [verification_type] and [reviewed_at]; no private data.
  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  );
}

// ── Supabase implementation ────────────────────────────────────────────────────

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  VerificationRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  // ── getCurrentUserRequests ──────────────────────────────────────────────────

  @override
  Future<List<VerificationRequestModel>> getCurrentUserRequests() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException(message: 'User not authenticated');
    }

    try {
      final response = await _client
          .from(ApiEndpoints.verificationRequests)
          .select()
          .eq('user_id', userId)
          .order('submitted_at', ascending: false);

      return (response as List)
          .cast<Map<String, dynamic>>()
          .map(VerificationRequestModel.fromJson)
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } on FormatException catch (e) {
      throw ServerException(
        message: 'Invalid verification request data: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to load verification requests: $e',
      );
    }
  }

  // ── submitWithDocument ──────────────────────────────────────────────────────

  @override
  Future<VerificationRequestModel> submitWithDocument({
    required VerificationType type,
    required Uint8List fileBytes,
    required String filename,
    required int fileSizeBytes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException(message: 'User not authenticated');
    }

    // Client-side size guard before hitting the network.
    if (fileSizeBytes <= 0 || fileSizeBytes > _kMaxBytes) {
      throw const ServerException(
        message: 'File must be between 1 byte and 10 MB.',
      );
    }

    // Derive MIME type from the file extension.
    final ext =
        filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
    final mimeType = _kMimeTypes[ext];
    if (mimeType == null) {
      throw const ServerException(
        message: 'Only PDF, JPG, and PNG files are accepted.',
      );
    }

    // ── Step 1: insert the request row ────────────────────────────────────────
    VerificationRequestModel request;
    try {
      final row = await _client
          .from(ApiEndpoints.verificationRequests)
          .insert({
            'user_id': userId,
            'verification_type': type.value,
            'status': 'pending',
          })
          .select()
          .single();
      request = VerificationRequestModel.fromJson(
        Map<String, dynamic>.from(row as Map),
      );
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw ServerException(
          message:
              'You already have a pending ${type.displayLabel} request. '
              'Wait for it to be reviewed before resubmitting.',
        );
      }
      throw ServerException(
        message: 'Could not create verification request: ${e.message}',
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(
        message: 'Could not create verification request: $e',
      );
    }

    // ── Step 2: upload document to private Storage ────────────────────────────
    // Path: {userId}/{requestId}/{sanitizedFilename}
    final sanitized = _sanitizeFilename(filename);
    final storagePath = '$userId/${request.id}/$sanitized';

    try {
      await _client.storage.from(_kBucket).uploadBinary(
        storagePath,
        fileBytes,
        fileOptions: FileOptions(contentType: mimeType, upsert: false),
      );
    } on StorageException catch (e) {
      debugPrint('[Verification] Storage upload failed: ${e.message}');
      throw ServerException(message: 'Document upload failed: ${e.message}');
    } catch (e) {
      debugPrint('[Verification] Storage upload unexpected error: $e');
      throw ServerException(message: 'Document upload failed: $e');
    }

    // ── Step 3: insert document-metadata row ──────────────────────────────────
    final doc = VerificationDocumentModel(
      id: '',         // generated by DB
      requestId: request.id,
      userId: userId,
      storagePath: storagePath,
      originalFilename: filename,
      mimeType: mimeType,
      fileSizeBytes: fileSizeBytes,
      createdAt: DateTime.now(),
    );

    try {
      await _client
          .from('verification_documents')
          .insert(doc.toInsertJson());
    } on PostgrestException catch (e) {
      debugPrint(
        '[Verification] Document metadata insert failed: ${e.message}',
      );
      throw ServerException(
        message:
            'Document uploaded but metadata could not be saved: ${e.message}',
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      debugPrint('[Verification] Document metadata unexpected error: $e');
      throw ServerException(
        message: 'Document uploaded but metadata could not be saved: $e',
      );
    }

    return request;
  }

  // ── startVerificationRequest ────────────────────────────────────────────────

  @override
  Future<VerificationRequestModel> startVerificationRequest(
    VerificationType type,
  ) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException(message: 'User not authenticated');
    }

    try {
      final row = await _client
          .from(ApiEndpoints.verificationRequests)
          .insert({
            'user_id': userId,
            'verification_type': type.value,
            'status': 'pending',
          })
          .select()
          .single();
      return VerificationRequestModel.fromJson(
        Map<String, dynamic>.from(row as Map),
      );
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw ServerException(
          message: 'You already have a pending ${type.displayLabel} request.',
        );
      }
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } on FormatException catch (e) {
      throw ServerException(
        message: 'Invalid verification request data: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to start verification request: $e',
      );
    }
  }

  // ── getPublicApprovedBadges ─────────────────────────────────────────────────

  @override
  Future<List<PublicVerificationBadgeEntity>> getPublicApprovedBadges(
    String profileId,
  ) async {
    // Only 'approved' rows are selected; only type + reviewed_at are read.
    try {
      final rows = await _client
          .from(ApiEndpoints.verificationRequests)
          .select('verification_type, reviewed_at')
          .eq('user_id', profileId)
          .eq('status', VerificationStatus.approved.value);

      final badges = <PublicVerificationBadgeEntity>[];
      for (final row in (rows as List).cast<Map<String, dynamic>>()) {
        final type =
            VerificationType.fromString(row['verification_type']?.toString());
        if (type == null) continue;

        final reviewedAt = row['reviewed_at'] != null
            ? DateTime.tryParse(row['reviewed_at'].toString())
            : null;

        final badge = PublicVerificationBadgeEntity.fromApprovedRequest(
          _ApprovedRequestAdapter(type: type, reviewedAt: reviewedAt),
        );
        if (badge != null) badges.add(badge);
      }
      return badges;
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to load verification badges: ${e.message}',
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to load verification badges: $e',
      );
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Removes characters unsafe in Storage paths; keeps alphanumerics,
  /// hyphens, underscores, and dots.
  static String _sanitizeFilename(String filename) =>
      filename.replaceAll(RegExp(r'[^\w.\-]'), '_');
}

// ── Private adapter ────────────────────────────────────────────────────────────
// PublicVerificationBadgeEntity.fromApprovedRequest reads .status, .type,
// .reviewedAt — this minimal adapter satisfies that contract.

class _ApprovedRequestAdapter extends VerificationRequestEntity {
  const _ApprovedRequestAdapter({
    required super.type,
    super.reviewedAt,
  }) : super(
         id: '',
         status: VerificationStatus.approved,
       );
}
