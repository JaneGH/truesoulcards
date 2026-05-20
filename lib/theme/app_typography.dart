import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DM Sans: humanist sans for display and UI — calm, modern, premium.
class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final sans = GoogleFonts.dmSansTextTheme();

    TextStyle displayHeading(TextStyle? base) {
      return (base ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.02,
        height: 1.22,
      );
    }

    TextStyle sectionHeading(TextStyle? base) {
      return (base ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.04,
        height: 1.26,
      );
    }

    return sans.copyWith(
      displayLarge: displayHeading(sans.displayLarge?.copyWith(fontSize: 48)),
      displayMedium: displayHeading(sans.displayMedium?.copyWith(fontSize: 40)),
      displaySmall: displayHeading(sans.displaySmall?.copyWith(fontSize: 32)),
      headlineLarge: sectionHeading(sans.headlineLarge?.copyWith(fontSize: 28)),
      headlineMedium: sectionHeading(sans.headlineMedium?.copyWith(fontSize: 24)),
      headlineSmall: sectionHeading(sans.headlineSmall?.copyWith(fontSize: 22)),
      titleLarge: sans.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.12,
        height: 1.28,
      ),
      titleMedium: sans.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.14,
        height: 1.28,
      ),
      titleSmall: sans.titleSmall?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.16,
        height: 1.32,
      ),
      bodyLarge: sans.bodyLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      bodyMedium: sans.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.06,
        height: 1.46,
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
        letterSpacing: 0.24,
      ),
      labelMedium: sans.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelSmall: sans.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.24,
      ),
    );
  }
}
