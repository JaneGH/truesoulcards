import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/category.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return await DatabaseHelper.instance.getAllCategories();
});
