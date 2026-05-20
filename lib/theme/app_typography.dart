import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Serif for display headings; sans-serif for UI copy.
class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final sans = GoogleFonts.dmSansTextTheme();
    final serif = GoogleFonts.cormorantGaramondTextTheme();

    TextStyle displaySerif(TextStyle? base) {
      return (base ?? const TextStyle()).copyWith(
        fontFamily: serif.displayLarge?.fontFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.12,
      );
    }

    TextStyle headingSerif(TextStyle? base) {
      return (base ?? const TextStyle()).copyWith(
        fontFamily: serif.headlineMedium?.fontFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.18,
      );
    }

    return sans.copyWith(
      displayLarge: displaySerif(sans.displayLarge),
      displayMedium: displaySerif(sans.displayMedium),
      displaySmall: displaySerif(sans.displaySmall),
      headlineLarge: headingSerif(sans.headlineLarge),
      headlineMedium: headingSerif(sans.headlineMedium),
      headlineSmall: headingSerif(sans.headlineSmall),
      titleLarge: sans.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.22,
      ),
      titleMedium: sans.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.24,
      ),
      titleSmall: sans.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.28,
      ),
      bodyLarge: sans.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: sans.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.45,
      ),
      bodySmall: sans.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelLarge: sans.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelMedium: sans.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
      ),
      labelSmall: sans.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }
}
