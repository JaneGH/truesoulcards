import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/custom_category.dart';
import 'package:truesoulcards/presentation/providers/categories_provider.dart';
import 'package:truesoulcards/presentation/providers/custom_categories_provider.dart';
import 'package:truesoulcards/presentation/providers/questions_provider.dart';

/// Refreshes in-memory category lists after a remote sync.
void invalidateSyncedCategoryProviders(WidgetRef ref) {
  ref.invalidate(categoriesProvider);
  ref.invalidate(userCategoriesProvider);
  ref.invalidate(questionsProvider);
  ref.invalidate(customCategoriesProvider(CategoryTabType.adults));
  ref.invalidate(customCategoriesProvider(CategoryTabType.kids));
  ref.invalidate(uploadAssignableCategoriesProvider);
}
