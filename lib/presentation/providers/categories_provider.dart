import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/datasources/database_helper.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/data/models/custom_category.dart';
import 'package:truesoulcards/data/repositories/category_repository.dart';
import 'package:truesoulcards/data/repositories/custom_category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(dbHelper: DatabaseHelper.instance);
});

final customCategoryRepositoryProvider = Provider<CustomCategoryRepository>((ref) {
  return CustomCategoryRepository(dbHelper: DatabaseHelper.instance);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getAllCategories();
});

final userCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final customRepository = ref.watch(customCategoryRepositoryProvider);
  final allCategories = await repository.getAllCategories();

  final legacy = allCategories.where((cat) => cat.id.startsWith('usr_'));
  final customAdults =
      await customRepository.getCategoriesByTab(CategoryTabType.adults);
  final customKids =
      await customRepository.getCategoriesByTab(CategoryTabType.kids);

  return [...legacy, ...customAdults, ...customKids];
});

List<Category> mergeTabCategories({
  required List<Category> source,
  required int tabIndex,
}) {
  final tabKey = tabIndex == 0 ? 'adults' : 'kids';
  return source.where((c) => c.subcategory.toLowerCase() == tabKey).toList()
    ..sort((a, b) {
      final aCustom = isCustomCategoryId(a.id);
      final bCustom = isCustomCategoryId(b.id);
      if (aCustom != bCustom) return aCustom ? 1 : -1;
      return a.getTitle('en').compareTo(b.getTitle('en'));
    });
}

final defaultCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  return await DatabaseHelper.instance.loadDefaultCategories();
});