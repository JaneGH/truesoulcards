import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/presentation/widgets/shared/calm_tap_scale.dart';
import 'package:truesoulcards/theme/app_colors.dart';
import 'package:truesoulcards/theme/app_decorations.dart';

class CategoryTile extends ConsumerWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;
  final double borderRadius;
  final Duration animationDuration;

  const CategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.borderRadius = 16,
    this.animationDuration = const Duration(milliseconds: 300),
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(languageProvider);
    final primaryLang = languages['primary'] ?? 'en';
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = cs.primary;

    final restingFill = AppDecorations.premiumSurfaceFill(cs, isDark: isDark);
    final borderColor = isSelected
        ? AppDecorations.selectedSurfaceBorder(cs, isDark: isDark, accent: accent)
        : AppDecorations.premiumSurfaceBorder(cs, isDark: isDark);

    final textColor = isSelected
        ? (isDark ? cs.onSurface : AppColors.darkBrown)
        : cs.onSurface;

    return CalmTapScale(
      isSelected: isSelected,
      selectedScale: 1.006,
      child: AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Color.lerp(AppColors.champagne, accent, 0.22)!,
                    Color.lerp(AppColors.goldLight, accent, 0.38)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppDecorations.premiumSurfaceSheen(isDark),
                  stops: const [0.0, 0.65],
                ),
          color: isSelected ? null : restingFill,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.35 : 1,
          ),
          boxShadow: isSelected
              ? AppDecorations.selectedSurfaceGlow(
                  isDark: isDark,
                  accent: accent,
                  strength: 1.05,
                )
              : AppDecorations.ambientCardShadow(
                  isDark: isDark,
                  elevation: 0.85,
                ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: onTap,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: textColor.withOpacity(isDark ? 0.82 : 0.78),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        category.getTitle(primaryLang),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                        textAlign: TextAlign.center,
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
