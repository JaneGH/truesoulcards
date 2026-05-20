import 'package:flutter/material.dart';
import 'package:truesoulcards/data/models/question.dart';
import 'package:truesoulcards/theme/app_colors.dart';
import 'package:truesoulcards/theme/app_decorations.dart';
import 'package:truesoulcards/theme/app_icons.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final String languageCode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const QuestionCard({
    super.key,
    required this.question,
    required this.languageCode,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(26);

    final surfaceFill = AppDecorations.premiumSurfaceFill(
      colorScheme,
      isDark: isDark,
    );
    final borderColor = AppDecorations.premiumSurfaceBorder(
      colorScheme,
      isDark: isDark,
    );
    final sheen = AppDecorations.premiumSurfaceSheen(isDark);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppDecorations.premiumSurfaceShadow(isDark: isDark),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.edgeHighlightWarm.withOpacity(isDark ? 0.10 : 0.48),
            blurRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: surfaceFill,
        child: InkWell(
          onTap: onTap,
          onLongPress: onDelete,
          borderRadius: radius,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: borderColor),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: sheen,
                stops: const [0.0, 0.65],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      question.getText(languageCode),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: colorScheme.onSurface.withOpacity(isDark ? 0.92 : 0.95),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(AppIcons.delete, size: AppIconSizes.sm),
                  onPressed: onDelete,
                  tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                  color: colorScheme.onSurfaceVariant.withOpacity(isDark ? 0.88 : 0.82),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  style: IconButton.styleFrom(
                    backgroundColor: AppDecorations.premiumNestedFill(
                      colorScheme,
                      isDark: isDark,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
