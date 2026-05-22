import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/custom_category.dart';
import 'package:truesoulcards/presentation/providers/categories_provider.dart';
import 'package:truesoulcards/presentation/providers/custom_categories_provider.dart';
import 'package:truesoulcards/presentation/providers/questions_provider.dart';
import 'package:truesoulcards/presentation/utils/category_icon_mapper.dart';

Future<void> refreshSyncedCategoryProviders(WidgetRef ref) async {
  clearCategoryIconAssetCache();

  ref.invalidate(categoriesProvider);
  ref.invalidate(userCategoriesProvider);
  ref.invalidate(questionsProvider);
  ref.invalidate(customCategoriesProvider(CategoryTabType.adults));
  ref.invalidate(customCategoriesProvider(CategoryTabType.kids));
  ref.invalidate(uploadAssignableCategoriesProvider);

  await ref.read(categoriesProvider.future);
}
