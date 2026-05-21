import 'package:flutter/material.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:truesoulcards/presentation/widgets/shared/calm_tap_scale.dart';
import 'package:truesoulcards/theme/app_colors.dart';
import 'package:truesoulcards/theme/app_decorations.dart';

/// Grid tile that opens the create-category flow (+ Create category).
class CreateCategoryCard extends StatelessWidget {
  const CreateCategoryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final radius = BorderRadius.circular(28);

    return CalmTapScale(
      pressedScale: 0.975,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: radius,
              color: AppDecorations.premiumSurfaceFill(cs, isDark: isDark),
              border: Border.all(
                color: AppDecorations.premiumSurfaceBorder(cs, isDark: isDark),
                width: 1.2,
              ),
              boxShadow: AppDecorations.ambientCardShadow(
                isDark: isDark,
                elevation: 0.85,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary.withOpacity(isDark ? 0.18 : 0.12),
                      border: Border.all(
                        color: cs.primary.withOpacity(0.35),
                      ),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 28,
                      color: isDark ? cs.primary : AppColors.goldDeep,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      l10n.create_category,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? cs.onSurface : AppColors.darkBrown,
                        height: 1.26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
