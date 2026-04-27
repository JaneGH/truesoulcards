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
    this.blurSigma = 10,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: outlineColor),
            boxShadow: [
              if (shadowColor.opacity > 0)
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 22,
                  offset: const Offset(0, 14),
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
