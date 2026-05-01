import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:truesoulcards/data/models/question.dart';
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

    final baseSurface = Color.alphaBlend(
      colorScheme.primary.withOpacity(isDark ? 0.10 : 0.06),
      colorScheme.surface,
    );

    final glassTint = isDark
        ? colorScheme.surface.withOpacity(0.10)
        : baseSurface.withOpacity(0.75);

    final borderColor = colorScheme.outlineVariant.withOpacity(isDark ? 0.28 : 0.22);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(isDark ? 0.35 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: colorScheme.shadow.withOpacity(isDark ? 0.22 : 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: glassTint,
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
                    colors: [
                      colorScheme.surface.withOpacity(isDark ? 0.12 : 0.55),
                      colorScheme.surface.withOpacity(isDark ? 0.04 : 0.20),
                    ],
                    stops: const [0.0, 1.0],
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
                        backgroundColor:
                            colorScheme.surfaceContainerHighest.withOpacity(isDark ? 0.18 : 0.30),
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
        ),
      ),
    );
  }
}