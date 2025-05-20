import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeNotifier extends StateNotifier<double> {
  static const _keyFontSize = 'fontSize';

  FontSizeNotifier() : super(22.0) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_keyFontSize);
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> setFontSize(double newSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, newSize);
    state = newSize;
  }
}

final fontSizeProvider =
StateNotifierProvider<FontSizeNotifier, double>((ref) => FontSizeNotifier());
