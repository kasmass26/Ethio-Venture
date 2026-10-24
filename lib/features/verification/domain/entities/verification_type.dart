/// Supported verification categories.
///
enum VerificationType {
  student('student', 'Student Verification',
      'Verify your current or prior educational status.'),
  identity('identity', 'Identity Verification',
      'Verify your identity with a supported government-issued document.'),
  business('business', 'Business Verification',
      'Verify a registered business or organization.'),
  investor('investor', 'Investor Verification',
      'Verify relevant investor identity and organization information.');

  const VerificationType(this.value, this.displayLabel, this.description);

  final String value;
  final String displayLabel;
  final String description;

  static VerificationType? fromString(String? value) {
    if (value == null) return null;

    final normalized = value.trim().toLowerCase().replaceAll('-', '_');
    for (final type in VerificationType.values) {
      if (type.value == normalized) return type;
    }
    return null;
  }
}
