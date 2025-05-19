import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/datasources/database_helper.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/data/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(dbHelper: DatabaseHelper.instance);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getAllCategories();
});