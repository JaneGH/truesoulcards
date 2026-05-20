import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
              0.32,
            ) ??
            AppColors.backgroundDark,
        Color.lerp(
              AppColors.backgroundDark,
              AppColors.backgroundDarkWarmer,
              0.52,
            ) ??
            AppColors.backgroundDark,
      ];
    }
    return [
      AppColors.pearl,
      Color.lerp(AppColors.ivory, AppColors.pearl, 0.35) ?? AppColors.ivory,
      Color.lerp(
            AppColors.ivory,
            AppColors.backgroundLightWarmer,
            0.24,
          ) ??
          AppColors.ivory,
    ];
  }

  static List<double>? scaffoldGradientStops(bool isDark) {
    return isDark ? const [0.0, 0.55, 1.0] : const [0.0, 0.42, 1.0];
  }

  static BoxDecoration scaffoldBackground(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: scaffoldGradientColors(isDark),
        stops: scaffoldGradientStops(isDark),
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  /// Gentle focus ring for inputs nested inside premium surfaces.
  static Color premiumFocusBorder(ColorScheme cs, {required bool isDark}) {
    return Color.lerp(
      premiumSurfaceBorder(cs, isDark: isDark),
      cs.primary,
      isDark ? 0.58 : 0.68,
    )!
        .withOpacity(isDark ? 0.72 : 0.78);
  }

  /// Selected tiles and cards — warm edge without loud contrast.
  static Color selectedSurfaceBorder(
    ColorScheme cs, {
    required bool isDark,
    Color? accent,
  }) {
    final goldEdge = Color.lerp(
      AppColors.goldLight,
      accent ?? cs.primary,
      isDark ? 0.42 : 0.28,
    )!;
    return Color.lerp(
      premiumSurfaceBorder(cs, isDark: isDark),
      goldEdge,
      isDark ? 0.62 : 0.55,
    )!
        .withOpacity(isDark ? 0.58 : 0.72);
  }

  static List<BoxShadow> selectedSurfaceGlow({
    required bool isDark,
    Color? accent,
    double strength = 1,
  }) {
    final glow = accent ?? AppColors.goldAccent;
    return [
      BoxShadow(
        color: glow.withOpacity((isDark ? 0.14 : 0.10) * strength),
        blurRadius: 16 * strength,
        spreadRadius: -2,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: AppColors.edgeHighlightWarm.withOpacity(isDark ? 0.06 : 0.38),
        blurRadius: 0,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static List<BoxShadow> premiumCtaPressedShadows({double opacity = 0.09}) {
    return [
      BoxShadow(
        color: AppColors.shadowWarm.withOpacity(opacity),
        blurRadius: 10,
        offset: const Offset(0, 4),
        spreadRadius: -2,
      ),
    ];
  }

  static const LinearGradient premiumCtaGradient = LinearGradient(
    colors: [
      Color(0xFFF5ECD0),
      Color(0xFFE4CC9E),
      Color(0xFFC9A86A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.42, 1.0],
  );

  static List<BoxShadow> premiumCtaShadows({double opacity = 0.14}) {
    return [
      BoxShadow(
        color: AppColors.shadowWarm.withOpacity(opacity),
        blurRadius: 22,
        offset: const Offset(0, 9),
        spreadRadius: -2,
      ),
      BoxShadow(
        color: AppColors.glowGold.withOpacity(0.42),
        blurRadius: 14,
        offset: const Offset(0, 3),
        spreadRadius: -3,
      ),
      BoxShadow(
        color: AppColors.edgeHighlightWarm.withOpacity(0.35),
        blurRadius: 1,
        offset: const Offset(0, -0.5),
        spreadRadius: 0,
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
        color: base.withOpacity(isDark ? 0.28 : 0.10 * elevation),
        blurRadius: 20 * elevation,
        offset: Offset(0, 7 * elevation),
        spreadRadius: -3,
      ),
      BoxShadow(
        color: AppColors.edgeHighlightWarm.withOpacity(isDark ? 0.08 : 0.62),
        blurRadius: 1.5,
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
      AppColors.pearl.withOpacity(0.34),
      Color.lerp(
        AppColors.creamCeramic,
        AppColors.surfaceWarmMid,
        0.42,
      )!,
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

  /// Transparent status bar over warm ivory; dark icons read as warm brown on cream.
  static SystemUiOverlayStyle systemOverlayStyle(bool isDark) {
    if (isDark) {
      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.backgroundDark,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      );
    }
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.ivory,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }

  /// Warm brown-gray for subtitles, hints, and helper copy.
  static Color mutedText(ColorScheme cs, {required bool isDark}) {
    if (isDark) {
      return Color.lerp(cs.onSurface, AppColors.lightBrown, 0.38)!
          .withOpacity(0.78);
    }
    return AppColors.lightBrown;
  }

  /// Slightly stronger than [mutedText] for labels and section hints.
  static Color secondaryText(ColorScheme cs, {required bool isDark}) {
    if (isDark) {
      return Color.lerp(cs.onSurface, AppColors.champagne, 0.28)!
          .withOpacity(0.86);
    }
    return AppColors.mediumBrown;
  }
}
