
import 'package:truesoulcards/data/datasources/database_helper.dart';
import 'package:truesoulcards/data/models/category.dart';

class CategoryRepository {
  final DatabaseHelper dbHelper;

  CategoryRepository({required this.dbHelper});

  Future<List<Category>> getAllCategories() {
    return dbHelper.getAllCategories();
  }

  Future<List<Category>> getCategoriesByIds(List<String> ids) {
    return dbHelper.getCategoriesByIds(ids);
  }
}