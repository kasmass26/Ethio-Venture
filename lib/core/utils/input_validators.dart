/// Shared form validators used across auth, startup, and investor
/// profile forms so validation copy stays consistent app-wide.
class InputValidators {
  InputValidators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? notEmpty(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? positiveNumber(
    String? value, {
    String field = 'Funding amount',
  }) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final numValue = double.tryParse(value.trim());
    if (numValue == null) return 'Enter a valid number for $field';
    if (numValue <= 0) return '$field must be greater than zero';
    return null;
  }
}
