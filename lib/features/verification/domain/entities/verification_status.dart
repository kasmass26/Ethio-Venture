/// Backend-controlled status of a verification request.
///
/// Unknown strings intentionally fall back to [notSubmitted]. This prevents an
/// unsupported result from being interpreted as approved by the frontend.
enum VerificationStatus {
  notSubmitted('not_submitted'),
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  resubmissionRequired('resubmission_required'),
  additionalInfoRequired('additional_info_required');

  const VerificationStatus(this.value);

  final String value;

  bool get isApproved => this == VerificationStatus.approved;

  static VerificationStatus fromString(String? value) {
    if (value == null) return VerificationStatus.notSubmitted;

    final normalized = value.trim().toLowerCase().replaceAll('-', '_');
    for (final status in VerificationStatus.values) {
      if (status.value == normalized || status.name == normalized) {
        return status;
      }
    }
    return VerificationStatus.notSubmitted;
  }
}
