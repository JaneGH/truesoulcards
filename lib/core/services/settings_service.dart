import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyShowAnimation= 'showAnimation';
  static const _fontSize = 'font_size';
  static const _keyLanguage = 'primary_language';
  static const _keySecondaryLanguage = 'secondary_language';
  static String _categoryKey(String categoryType) => 'selected_$categoryType';

  Future<void> saveSettings({
    required bool showAnimation,

  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowAnimation, showAnimation);
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'showAnimation': prefs.getBool(_keyShowAnimation) ?? false,
      'fontSize': prefs.getDouble(_fontSize) ?? 22,
      'primary_language': prefs.getString(_keyLanguage) ?? 'en',
      'secondary_language': prefs.getString(_keySecondaryLanguage) ?? 'en',
    };
  }

  Future<String> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'en';
  }

  Future<void> saveSelectedCategories(String categoryType, List<String> categoryIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoryKey(categoryType), categoryIds);
  }

  Future<List<String>> loadSelectedCategories(String categoryType) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_categoryKey(categoryType)) ?? [];
  }

  Future<void> clearSelectedCategories(String categoryType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_categoryKey(categoryType));
  }

  Future<bool> getShowAnimation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowAnimation) ?? true;
  }

}
