import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _onboardingKey = 'onboarding_done';

  /// Save onboarding completed
  static Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  /// Check onboarding status
  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }
}
