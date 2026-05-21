import 'package:truesoulcards/data/datasources/database_helper.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/data/models/custom_category.dart';

class CustomCategoryRepository {
  final DatabaseHelper dbHelper;

  CustomCategoryRepository({required this.dbHelper});

  Future<List<CustomCategory>> getByTab(CategoryTabType tabType) {
    return dbHelper.getCustomCategories(tabType);
  }

  Future<List<Category>> getCategoriesByTab(CategoryTabType tabType) async {
    final custom = await getByTab(tabType);
    return custom.map((c) => c.toCategory()).toList();
  }

  Future<CustomCategory> create({
    required String title,
    required CategoryTabType tabType,
    required int color,
    required String iconName,
    required String primaryLanguageCode,
  }) {
    return dbHelper.insertCustomCategory(
      title: title,
      tabType: tabType,
      color: color,
      iconName: iconName,
      primaryLanguageCode: primaryLanguageCode,
    );
  }

  Future<void> rename({
    required String id,
    required String title,
    required String primaryLanguageCode,
  }) {
    return dbHelper.updateCustomCategoryTitle(
      id: id,
      title: title,
      primaryLanguageCode: primaryLanguageCode,
    );
  }

  Future<void> update({
    required String id,
    required String title,
    required int color,
    required String iconName,
    required String primaryLanguageCode,
  }) {
    return dbHelper.updateCustomCategory(
      id: id,
      title: title,
      color: color,
      iconName: iconName,
      primaryLanguageCode: primaryLanguageCode,
    );
  }

  Future<void> delete(String id) {
    return dbHelper.deleteCustomCategory(id);
  }
}
