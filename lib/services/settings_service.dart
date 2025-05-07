import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyShowMySets = 'showMySets';
  static const _keyLanguage = 'primary_language';
  static const _keySecondLanguage = 'second_language';

  Future<void> saveSettings({
    required bool showMySets,
    // required String language,
    // required String secondLanguage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowMySets, showMySets);
    // await prefs.setString(_keyLanguage, language);
    // await prefs.setString(_keySecondLanguage, secondLanguage);
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'showMySets': prefs.getBool(_keyShowMySets) ?? false,
      'primary_language': prefs.getString(_keyLanguage) ?? 'en',
      'second_language': prefs.getString(_keySecondLanguage) ?? 'en',
    };
  }

  Future<String> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'en';
  }

}
