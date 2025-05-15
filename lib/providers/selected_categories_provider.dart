import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_service.dart';

final selectedCategoriesProvider = AsyncNotifierProvider<SelectedCategoriesNotifier, Map<String, Set<String>>>(
      () => SelectedCategoriesNotifier(),
);

class SelectedCategoriesNotifier extends AsyncNotifier<Map<String, Set<String>>> {
  final _settingsService = SettingsService();

  @override
  Future<Map<String, Set<String>>> build() async {
    final adults = await _settingsService.loadSelectedCategories('adults');
    final kids = await _settingsService.loadSelectedCategories('kids');
    return {
      'adults': Set.from(adults),
      'kids': Set.from(kids),
    };
  }

  Future<void> toggleCategory(String type, String id) async {
    final current = state.value ?? {'adults': {}, 'kids': {}};
    final updatedSet = Set<String>.from(current[type] ?? {});
    if (updatedSet.contains(id)) {
      updatedSet.remove(id);
    } else {
      updatedSet.add(id);
    }

    final updated = {...current, type: updatedSet};
    state = AsyncValue.data(updated);
    await _settingsService.saveSelectedCategories(type, updatedSet.toList());
  }
}
