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
      displayLarge: displaySerif(sans.displayLarge?.copyWith(fontSize: 52)),
      displayMedium: displaySerif(sans.displayMedium?.copyWith(fontSize: 44)),
      displaySmall: displaySerif(sans.displaySmall?.copyWith(fontSize: 36)),
      headlineLarge: headingSerif(sans.headlineLarge?.copyWith(fontSize: 32)),
      headlineMedium: headingSerif(sans.headlineMedium?.copyWith(fontSize: 28)),
      headlineSmall: headingSerif(sans.headlineSmall?.copyWith(fontSize: 24)),
      titleLarge: sans.titleLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.08,
        height: 1.24,
      ),
      titleMedium: sans.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.12,
        height: 1.26,
      ),
      titleSmall: sans.titleSmall?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.18,
        height: 1.3,
      ),
      bodyLarge: sans.bodyLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.12,
        height: 1.52,
      ),
      bodyMedium: sans.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.08,
        height: 1.48,
      ),
      bodySmall: sans.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.08,
        height: 1.42,
      ),
      labelLarge: sans.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.28,
      ),
      labelMedium: sans.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.22,
      ),
      labelSmall: sans.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.28,
      ),
    );
  }
}
