import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../providers/language_provider.dart';
import '../providers/selected_categories_provider.dart';
import 'category_tile.dart';

class SavedCategoryGrid extends ConsumerWidget {
  final String type;
  final List<Category> categories;

  const SavedCategoryGrid({required this.type, required this.categories, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAsync = ref.watch(selectedCategoriesProvider);
    return selectedAsync.when(
      data: (selectedMap) {
        final selectedIds = selectedMap[type] ?? {};

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedIds.contains(category.id);

            return CategoryTile(
              category: category,
              isSelected: isSelected,
              onTap: () => ref.read(selectedCategoriesProvider.notifier)
                  .toggleCategory(type, category.id),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
