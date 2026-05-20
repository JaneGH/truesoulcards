import 'dart:ui';

import 'package:flutter/material.dart';

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
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
              colors: [
                Colors.white.withOpacity(isDark ? 0.06 : 0.42),
                Colors.transparent,
              ],
              stops: const [0.0, 0.55],
            ),
            boxShadow: [
              if (shadowColor.opacity > 0)
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: -6,
                ),
              BoxShadow(
                color: Colors.white.withOpacity(isDark ? 0.03 : 0.55),
                blurRadius: 1,
                offset: const Offset(0, -0.5),
              ),
            ],
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
