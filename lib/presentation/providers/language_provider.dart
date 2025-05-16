import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Map<String, String>>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Map<String, String>> {
  LanguageNotifier() : super({'primary': 'en', 'second': 'en'}) {
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    final primary = prefs.getString('primary_language') ?? 'en';
    final second = prefs.getString('second_language') ?? 'en';
    state = {'primary': primary, 'second': second};
  }

  Future<void> setPrimaryLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('primary_language', languageCode);
    state = {'primary': languageCode, 'second': state['second']!};
  }

  Future<void> setSecondLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('second_language', languageCode);
    state = {'primary': state['primary']!, 'second': languageCode};
  }

  Locale get primaryLocale => Locale(state['primary']!);
  Locale get secondLocale => Locale(state['second']!);
}
