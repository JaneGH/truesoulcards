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
        color: Colors.white.withOpacity(isDark ? 0.04 : 0.65),
        blurRadius: 1,
        offset: const Offset(0, -0.5),
        spreadRadius: 0,
      ),
    ];
  }

  static Color navBarSurface(bool isDark) {
    return isDark
        ? AppColors.glassDark
        : AppColors.glassLight;
  }
}
