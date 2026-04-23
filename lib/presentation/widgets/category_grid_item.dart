import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';

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
    final cs = theme.colorScheme;

    final radius = BorderRadius.circular(22);
    final tint = Color(category.color).withOpacity(0.9);
    final surface = cs.surfaceVariant.withAlpha((0.90 * 255).round());
    final border = Color(category.color).withAlpha((0.28 * 255).round());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.10 * 255).round()),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSelectCategory,
              borderRadius: radius,
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  color: surface,
                  border: Border.all(
                    color: border,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          gradient: LinearGradient(
                            colors: [
                              tint.withOpacity(0.5),
                              tint.withOpacity(0.25),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withAlpha((0.08 * 255).round()),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Center(
                        child: Text(
                          category.getTitle(languages['primary']!),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
