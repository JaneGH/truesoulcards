import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Map<String, String>>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Map<String, String>> {
  LanguageNotifier() : super({'primary': 'en', 'secondary': 'en'}) {
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    final primary = prefs.getString('primary_language') ?? 'en';
    final secondary = prefs.getString('secondary_language') ?? 'en';
    state = {'primary': primary, 'secondary': secondary};
  }

  Future<void> setPrimaryLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('primary_language', languageCode);
    state = {'primary': languageCode, 'secondary': state['secondary']!};
  }

  Future<void> setSecondaryLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('secondary_language', languageCode);
    state = {'primary': state['primary']!, 'secondary': languageCode};
  }

  Locale get primaryLocale => Locale(state['primary']!);
  Locale get secondaryLocale => Locale(state['secondary']!);
}
