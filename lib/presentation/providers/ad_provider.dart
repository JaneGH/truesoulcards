import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final adsDisabledProvider = StateNotifierProvider<AdsDisabledNotifier, bool>((ref) {
  return AdsDisabledNotifier();
});

class AdsDisabledNotifier extends StateNotifier<bool> {
  AdsDisabledNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('ads_disabled') ?? false;
  }

  Future<void> disableAds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ads_disabled', true);
    state = true;
  }
}
