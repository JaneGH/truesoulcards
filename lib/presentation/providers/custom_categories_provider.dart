import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/custom_category.dart';
import 'package:truesoulcards/presentation/providers/categories_provider.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';

final customCategoriesProvider =
    FutureProvider.family<List<CustomCategory>, CategoryTabType>((ref, tab) async {
  final repository = ref.watch(customCategoryRepositoryProvider);
  return repository.getByTab(tab);
});

class CustomCategoriesController {
  CustomCategoriesController(this._ref);

  final Ref _ref;

  void _invalidate() {
    _ref.invalidate(categoriesProvider);
    _ref.invalidate(userCategoriesProvider);
    _ref.invalidate(customCategoriesProvider(CategoryTabType.adults));
    _ref.invalidate(customCategoriesProvider(CategoryTabType.kids));
  }

  Future<CustomCategory> create({
    required String title,
    required CategoryTabType tabType,
    required int color,
    required String iconName,
  }) async {
    final lang = _ref.read(languageProvider)['primary'] ?? 'en';
    final repository = _ref.read(customCategoryRepositoryProvider);
    final created = await repository.create(
      title: title,
      tabType: tabType,
      color: color,
      iconName: iconName,
      primaryLanguageCode: lang,
    );
    _invalidate();
    return created;
  }

  Future<void> rename({required String id, required String title}) async {
    final lang = _ref.read(languageProvider)['primary'] ?? 'en';
    await _ref.read(customCategoryRepositoryProvider).rename(
          id: id,
          title: title,
          primaryLanguageCode: lang,
        );
    _invalidate();
  }

  Future<void> update({
    required String id,
    required String title,
    required int color,
    required String iconName,
  }) async {
    final lang = _ref.read(languageProvider)['primary'] ?? 'en';
    await _ref.read(customCategoryRepositoryProvider).update(
          id: id,
          title: title,
          color: color,
          iconName: iconName,
          primaryLanguageCode: lang,
        );
    _invalidate();
  }

  Future<void> delete(String id) async {
    await _ref.read(customCategoryRepositoryProvider).delete(id);
    _invalidate();
  }
}

final customCategoriesControllerProvider = Provider<CustomCategoriesController>((ref) {
  return CustomCategoriesController(ref);
});
