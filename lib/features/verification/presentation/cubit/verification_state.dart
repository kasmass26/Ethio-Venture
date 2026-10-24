import 'package:flutter/foundation.dart';

import '../../domain/entities/verification_request_entity.dart';

@immutable
sealed class VerificationState {
  const VerificationState();
}

final class VerificationInitial extends VerificationState {
  const VerificationInitial();
}

final class VerificationLoading extends VerificationState {
  const VerificationLoading();
}

final class VerificationLoaded extends VerificationState {
  const VerificationLoaded(this.requests);

  final List<VerificationRequestEntity> requests;
}

final class VerificationEmpty extends VerificationState {
  const VerificationEmpty();
}

final class VerificationSubmitting extends VerificationState {
  const VerificationSubmitting();
}

/// Emitted while the document is being uploaded to Supabase Storage and the
/// metadata row is being written.  The UI should show an indeterminate
/// progress indicator and keep the submit button disabled.
final class VerificationUploading extends VerificationState {
  const VerificationUploading();
}

final class VerificationSuccess extends VerificationState {
  const VerificationSuccess(this.request);

  final VerificationRequestEntity request;
}

final class VerificationError extends VerificationState {
  const VerificationError(this.message);

  final String message;
}
