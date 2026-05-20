import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_decorations.dart';
import 'app_typography.dart';

ThemeData _buildTheme({required Brightness brightness}) {
  final isDark = brightness == Brightness.dark;
  final textTheme = AppTypography.textTheme(brightness);

  final colorScheme = isDark
      ? const ColorScheme.dark(
          primary: AppColors.goldMid,
          onPrimary: Color(0xFF2A2218),
          primaryContainer: Color(0xFF3D3229),
          onPrimaryContainer: AppColors.goldLight,
          secondary: AppColors.darkBeige,
          onSecondary: Color(0xFF2A2218),
          secondaryContainer: Color(0xFF4A3F36),
          onSecondaryContainer: AppColors.champagne,
          surface: AppColors.backgroundDark,
          onSurface: Color(0xFFF5EDE4),
          surfaceContainerLowest: Color(0xFF0F0D0B),
          surfaceContainerLow: Color(0xFF1A1614),
          surfaceContainer: Color(0xFF221E1B),
          surfaceContainerHigh: Color(0xFF2A2521),
          surfaceContainerHighest: Color(0xFF332D28),
          onSurfaceVariant: Color(0xFFB8A99A),
          outline: Color(0xFF5C5048),
          outlineVariant: Color(0xFF3D3530),
          shadow: Color(0xFF000000),
          scrim: Color(0x99000000),
        )
      : const ColorScheme.light(
          primary: AppColors.goldDeep,
          onPrimary: AppColors.darkBrown,
          primaryContainer: AppColors.champagne,
          onPrimaryContainer: AppColors.darkBrown,
          secondary: AppColors.darkBeige,
          onSecondary: AppColors.darkBrown,
          secondaryContainer: AppColors.lightBeige,
          onSecondaryContainer: AppColors.darkBrown,
          surface: AppColors.ivory,
          onSurface: AppColors.darkBrown,
          surfaceContainerLowest: AppColors.pearl,
          surfaceContainerLow: Color(0xFFF7F1E8),
          surfaceContainer: Color(0xFFF0E8DC),
          surfaceContainerHigh: Color(0xFFE8DFD2),
          surfaceContainerHighest: Color(0xFFDFD4C6),
          onSurfaceVariant: AppColors.lightBrown,
          outline: Color(0xFFD4C8B8),
          outlineVariant: Color(0xFFE8DFD2),
          shadow: AppColors.shadowWarm,
          scrim: Color(0x663D3229),
        );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 56,
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: AppDecorations.systemOverlayStyle(isDark),
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        fontSize: 23,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.06,
        height: 1.28,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? colorScheme.surfaceContainerHighest.withOpacity(0.42)
          : AppColors.pearl,
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: AppDecorations.mutedText(colorScheme, isDark: isDark),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppDecorations.premiumSurfaceBorder(
            colorScheme,
            isDark: isDark,
          ),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppDecorations.premiumSurfaceBorder(
            colorScheme,
            isDark: isDark,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.primary.withOpacity(isDark ? 0.62 : 0.72),
          width: 1.2,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withOpacity(0.65),
      thickness: 1,
    ),
    iconTheme: IconThemeData(
      color: colorScheme.onSurfaceVariant,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 2,
      highlightElevation: 4,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.onPrimary;
        }
        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary.withOpacity(isDark ? 0.65 : 0.72);
        }
        return colorScheme.surfaceContainerHighest
            .withOpacity(isDark ? 0.5 : 0.55);
      }),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 3.5,
      activeTrackColor: colorScheme.primary.withOpacity(isDark ? 0.55 : 0.58),
      inactiveTrackColor: colorScheme.onSurface.withOpacity(0.1),
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withOpacity(0.1),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: textTheme.labelLarge,
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}

ThemeData get lightTheme => _buildTheme(brightness: Brightness.light);

ThemeData get darkTheme => _buildTheme(brightness: Brightness.dark);
