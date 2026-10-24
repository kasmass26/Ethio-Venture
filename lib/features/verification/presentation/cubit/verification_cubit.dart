import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/verification_type.dart';
import '../../domain/usecases/get_current_user_verification_requests.dart';
import '../../domain/usecases/start_verification_request.dart';
import '../../domain/usecases/submit_verification_with_document.dart';
import 'verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> {
  VerificationCubit({
    required GetCurrentUserVerificationRequests getCurrentUserRequests,
    required StartVerificationRequest startVerificationRequest,
    SubmitVerificationWithDocument? submitVerificationWithDocument,
  }) : _getCurrentUserRequests = getCurrentUserRequests,
       _startVerificationRequest = startVerificationRequest,
       _submitWithDocument = submitVerificationWithDocument,
       super(const VerificationInitial());

  final GetCurrentUserVerificationRequests _getCurrentUserRequests;
  final StartVerificationRequest _startVerificationRequest;

  /// Null when Supabase Storage is not configured; the submission page guards
  /// against this and keeps the submit button disabled in that case.
  final SubmitVerificationWithDocument? _submitWithDocument;

  /// True while any submission is in flight — prevents concurrent submissions.
  bool _isSubmitting = false;

  /// Whether document submission is available (Storage bucket configured).
  bool get canSubmitWithDocument => _submitWithDocument != null;

  // ── loadRequests ────────────────────────────────────────────────────────────

  Future<void> loadRequests() async {
    emit(const VerificationLoading());
    try {
      final requests = await _getCurrentUserRequests();
      if (requests.isEmpty) {
        emit(const VerificationEmpty());
      } else {
        emit(VerificationLoaded(List.unmodifiable(requests)));
      }
    } on AppException catch (error) {
      emit(VerificationError(error.message));
    } catch (error) {
      emit(VerificationError(error.toString()));
    }
  }

  // ── submitWithDocument ──────────────────────────────────────────────────────

  /// Submits a verification request with the attached document.
  ///
  /// Emits [VerificationUploading] while the three-step sequence runs
  /// (insert request → upload file → insert metadata).  On success emits
  /// [VerificationSuccess].  On failure emits [VerificationError] with the
  /// original error message so the user can retry.
  Future<void> submitWithDocument({
    required VerificationType type,
    required Uint8List fileBytes,
    required String filename,
    required int fileSizeBytes,
  }) async {
    if (_isSubmitting) return;
    if (_submitWithDocument == null) {
      emit(
        const VerificationError(
          'Secure document storage is not configured yet. '
          'Please try again later.',
        ),
      );
      return;
    }

    _isSubmitting = true;
    emit(const VerificationUploading());

    try {
      final request = await _submitWithDocument(
        type: type,
        fileBytes: fileBytes,
        filename: filename,
        fileSizeBytes: fileSizeBytes,
      );
      emit(VerificationSuccess(request));
    } on AppException catch (error) {
      emit(VerificationError(error.message));
    } catch (error) {
      emit(VerificationError(error.toString()));
    } finally {
      _isSubmitting = false;
    }
  }

  // ── startRequest (backward compat) ─────────────────────────────────────────

  Future<void> startRequest(VerificationType type) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const VerificationSubmitting());
    try {
      final request = await _startVerificationRequest(type);
      emit(VerificationSuccess(request));
    } on AppException catch (error) {
      emit(VerificationError(error.message));
    } catch (error) {
      emit(VerificationError(error.toString()));
    } finally {
      _isSubmitting = false;
    }
  }

  /// Alias kept for callers that use the original name.
  Future<void> startVerificationRequest(VerificationType type) =>
      startRequest(type);
}
