import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/presentation/providers/categories_provider.dart';
import 'package:truesoulcards/presentation/providers/selected_categories_provider.dart';

/// Current Adults / Kids tab index on the category picker (0 = adults, 1 = kids).
final categoryPickerTabIndexProvider = StateProvider<int>((ref) => 0);

/// Play action registered by [CategoriesScreen] in play mode; invoked from [MainScreen].
final categoriesPlayInvokerProvider = StateProvider<void Function()?>(
  (ref) => null,
);

final playModeSelectedCountProvider = Provider<int>((ref) {
  final tab = ref.watch(categoryPickerTabIndexProvider);
  final selectedAsync = ref.watch(selectedCategoriesProvider);
  final categoriesAsync = ref.watch(categoriesProvider);
  return selectedAsync.when(
    data: (selectedMap) => categoriesAsync.when(
      data: (all) {
        final tabType = tab == 0 ? 'adults' : 'kids';
        final tabCats =
            all.where((c) => c.subcategory.toLowerCase() == tabType).toList();
        final selectedIds = selectedMap[tabType] ?? {};
        return tabCats.where((c) => selectedIds.contains(c.id)).length;
      },
      loading: () => 0,
      error: (_, __) => 0,
    ),
    loading: () => 0,
    error: (_, __) => 0,
  );
});
