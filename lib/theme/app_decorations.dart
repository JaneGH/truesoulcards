import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shared visual polish tokens — shadows, gradients, glass surfaces.
class AppDecorations {
  static List<Color> scaffoldGradientColors(bool isDark) {
    if (isDark) {
      return [
        AppColors.backgroundDark,
        Color.lerp(
              AppColors.backgroundDark,
              AppColors.backgroundDarkWarmer,
              0.45,
            ) ??
            AppColors.backgroundDark,
      ];
    }
    return [
      AppColors.backgroundLight,
      Color.lerp(
            AppColors.backgroundLight,
            AppColors.backgroundLightWarmer,
            0.45,
          ) ??
          AppColors.backgroundLight,
    ];
  }

  static BoxDecoration scaffoldBackground(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: scaffoldGradientColors(isDark),
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  static const LinearGradient premiumCtaGradient = LinearGradient(
    colors: [
      Color(0xFFF2E6C8),
      Color(0xFFE0C896),
      Color(0xFFC9A86A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.45, 1.0],
  );

  static List<BoxShadow> premiumCtaShadows({double opacity = 0.12}) {
    return [
      BoxShadow(
        color: AppColors.shadowWarm.withOpacity(opacity),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: -2,
      ),
      BoxShadow(
        color: AppColors.glowGold.withOpacity(0.35),
        blurRadius: 12,
        offset: const Offset(0, 2),
        spreadRadius: -4,
      ),
    ];
  }

  static List<BoxShadow> ambientCardShadow({
    required bool isDark,
    Color? tint,
    double elevation = 1,
  }) {
    final base = tint ?? AppColors.shadowWarm;
    return [
      BoxShadow(
        color: base.withOpacity(isDark ? 0.28 : 0.08 * elevation),
        blurRadius: 18 * elevation,
        offset: Offset(0, 6 * elevation),
        spreadRadius: -4,
      ),
      BoxShadow(
        color: AppColors.edgeHighlightWarm.withOpacity(isDark ? 0.08 : 0.55),
        blurRadius: 1,
        offset: const Offset(0, -0.5),
        spreadRadius: 0,
      ),
    ];
  }

  static Color navBarSurface(bool isDark) {
    return isDark ? AppColors.glassDark : AppColors.glassLight;
  }

  /// Warm ivory/champagne card & field fill — replaces cold gray glass tints.
  static Color premiumSurfaceFill(ColorScheme cs, {required bool isDark}) {
    if (isDark) {
      return Color.lerp(
            cs.surfaceContainer,
            AppColors.backgroundDarkWarmer,
            0.38,
          ) ??
          cs.surfaceContainer;
    }
    return Color.alphaBlend(
      AppColors.pearl.withOpacity(0.52),
      Color.lerp(AppColors.champagne, AppColors.ivory, 0.32)!,
    );
  }

  static Color premiumSurfaceBorder(ColorScheme cs, {required bool isDark}) {
    final warmEdge = Color.lerp(
      AppColors.goldLight,
      AppColors.darkBeige.withOpacity(0.7),
      isDark ? 0.58 : 0.32,
    )!;
    return Color.lerp(warmEdge, cs.outlineVariant, isDark ? 0.32 : 0.42)!
        .withOpacity(isDark ? 0.34 : 0.48);
  }

  static Color premiumSurfaceShadow({required bool isDark, double strength = 1}) {
    return AppColors.shadowWarm.withOpacity(
      (isDark ? 0.22 : 0.08) * strength,
    );
  }

  /// Nested chips, icon buttons, secondary tiles inside a surface.
  static Color premiumNestedFill(ColorScheme cs, {required bool isDark}) {
    if (isDark) {
      return Color.lerp(
            cs.surfaceContainerHigh,
            AppColors.backgroundDarkWarmer,
            0.28,
          )!
          .withOpacity(0.84);
    }
    return Color.lerp(AppColors.ivory, cs.surfaceContainerHigh, 0.48) ??
        cs.surfaceContainerHigh;
  }

  /// Inset panels (dropzones, file rows, secondary buttons).
  static Color premiumInsetFill(ColorScheme cs, {required bool isDark}) {
    if (isDark) {
      return Color.lerp(cs.surface, AppColors.backgroundDarkWarmer, 0.22)!
          .withOpacity(0.68);
    }
    return Color.lerp(AppColors.pearl, cs.surfaceContainerLow, 0.55)!;
  }

  static List<Color> premiumSurfaceSheen(bool isDark) {
    if (isDark) {
      return [
        AppColors.goldLight.withOpacity(0.07),
        Colors.transparent,
      ];
    }
    return [
      AppColors.pearl.withOpacity(0.88),
      AppColors.champagne.withOpacity(0.14),
    ];
  }

  /// Soft blur — keeps depth without a frosted-glass look.
  static double premiumSurfaceBlurSigma(double requested) {
    if (requested <= 0) return 0;
    return (requested * 0.35).clamp(2.0, 6.0);
  }
}
