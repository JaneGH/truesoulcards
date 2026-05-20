import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:truesoulcards/presentation/providers/selected_categories_provider.dart';
import 'package:truesoulcards/theme/app_decorations.dart';

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
        final allIds = categories.map((c) => c.id).toSet();
        final isAllSelected = allIds.isNotEmpty && selectedIds.length == allIds.length;
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppDecorations.premiumSurfaceFill(cs, isDark: isDark),
                    border: Border.all(
                      color: AppDecorations.premiumSurfaceBorder(cs, isDark: isDark),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppDecorations.premiumSurfaceSheen(isDark),
                      stops: const [0.0, 0.65],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppDecorations.premiumSurfaceShadow(isDark: isDark),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                        spreadRadius: -3,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.categories_settings_info_title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.categories_settings_info_description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              sliver: SliverToBoxAdapter(
                child: _AllSelectionTile(
                  title: l10n.categories_settings_all,
                  isSelected: isAllSelected,
                  onChanged: (value) async {
                    final notifier = ref.read(selectedCategoriesProvider.notifier);
                    if (value == true) {
                      await notifier.setSelectedCategories(type, allIds);
                    } else {
                      await notifier.setSelectedCategories(type, {});
                    }
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = categories[index];
                    final isSelected = selectedIds.contains(category.id);

                    return CategoryTile(
                      category: category,
                      isSelected: isSelected,
                      onTap: () => ref.read(selectedCategoriesProvider.notifier).toggleCategory(type, category.id),
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _AllSelectionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const _AllSelectionTile({
    required this.title,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(20);

    return Material(
      color: AppDecorations.premiumSurfaceFill(cs, isDark: isDark),
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () => onChanged(!isSelected),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: AppDecorations.premiumSurfaceBorder(cs, isDark: isDark),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppDecorations.premiumSurfaceSheen(isDark),
              stops: const [0.0, 0.65],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onChanged,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
