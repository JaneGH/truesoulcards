import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:truesoulcards/theme/app_colors.dart';
import 'package:truesoulcards/theme/app_decorations.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.outlineColor,
    required this.shadowColor,
    required this.borderRadius,
    required this.padding,
    this.blurSigma = 12,
  });

  final Widget child;
  final Color backgroundColor;
  final Color outlineColor;
  final Color shadowColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBlur = AppDecorations.premiumSurfaceBlurSigma(blurSigma);
    final sheen = AppDecorations.premiumSurfaceSheen(isDark);

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: outlineColor,
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: sheen,
          stops: const [0.0, 0.62],
        ),
        boxShadow: [
          if (shadowColor.opacity > 0)
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          BoxShadow(
            color: AppColors.edgeHighlightWarm.withOpacity(isDark ? 0.12 : 0.55),
            blurRadius: 0,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: AppColors.shadowWarm.withOpacity(isDark ? 0.06 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (effectiveBlur > 0) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: effectiveBlur,
          sigmaY: effectiveBlur,
        ),
        child: surface,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: surface,
    );
  }
}
