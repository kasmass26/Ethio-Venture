import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage using SharedPreferences
class StorageService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// Initialize the storage service
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// Check if the user has completed onboarding
  bool hasCompletedOnboarding() {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// Mark onboarding as completed
  Future<bool> setOnboardingCompleted() {
    return _prefs.setBool(_keyOnboardingCompleted, true);
  }

  /// Clear onboarding state (useful for testing or reset)
  Future<bool> clearOnboardingState() {
    return _prefs.remove(_keyOnboardingCompleted);
  }

  /// Clear all stored data
  Future<bool> clearAll() {
    return _prefs.clear();
  }
}
