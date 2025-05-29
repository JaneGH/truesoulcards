import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/theme/app_colors.dart';

class CategoryGridItem extends ConsumerWidget {
  const CategoryGridItem({
    super.key,
    required this.category,
    required this.onSelectCategory,
  });

  final Category category;
  final void Function() onSelectCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(languageProvider);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onSelectCategory,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Color(category.color).withAlpha((0.8 * 255).round()),
              Color(category.color).withAlpha((0.95 * 255).round()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(category.color).withAlpha((0.4 * 255).round()),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            category.getTitle(languages['primary']!),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge!.copyWith(
              fontSize: theme.textTheme.bodyLarge!.fontSize! + 2,
              color: AppColors.darkBrown,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
