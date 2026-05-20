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
    /// 0 = resting, 1 = focused or emphasized (subtle border + depth lift).
    this.emphasis = 0,
  });

  final Widget child;
  final Color backgroundColor;
  final Color outlineColor;
  final Color shadowColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double blurSigma;
  final double emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final effectiveBlur = AppDecorations.premiumSurfaceBlurSigma(blurSigma);
    final sheen = AppDecorations.premiumSurfaceSheen(isDark);
    final t = emphasis.clamp(0.0, 1.0);
    final borderColor = Color.lerp(
      outlineColor,
      AppDecorations.premiumFocusBorder(cs, isDark: isDark),
      t,
    )!;
    final shadowStrength = 1 + (t * 0.22);

    Widget surface = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: 1 + (t * 0.15),
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
              color: shadowColor.withOpacity(
                (shadowColor.opacity * shadowStrength).clamp(0.0, 1.0),
              ),
              blurRadius: 20 * shadowStrength,
              offset: Offset(0, 10 * shadowStrength),
              spreadRadius: -5,
            ),
          if (t > 0.05)
            BoxShadow(
              color: AppColors.glowGold.withOpacity(isDark ? 0.08 : 0.06),
              blurRadius: 12,
              spreadRadius: -3,
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
