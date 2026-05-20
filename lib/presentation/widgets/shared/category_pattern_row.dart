import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryPatternRow extends StatelessWidget {
  const CategoryPatternRow({
    super.key,
    required this.color,
    this.iconSize = 20.0,
    this.spacing = 10.0,
  });

  final Color color;
  final double iconSize;
  final double spacing;

  /// Card horizontal margin (24) × 2 + card padding (32) × 2.
  static const double _cardHorizontalInset = 112;

  static int _itemsPerRow(double maxWidth, double iconSize, double spacing) {
    final itemStride = iconSize + spacing;
    if (itemStride <= 0) return 1;
    return math.max(1, (maxWidth / itemStride).floor());
  }

  static double _effectiveMaxWidth(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    if (constraints.hasBoundedWidth && constraints.maxWidth > 0) {
      return constraints.maxWidth;
    }
    return MediaQuery.sizeOf(context).width - _cardHorizontalInset;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = _effectiveMaxWidth(context, constraints);
          final itemsPerRow = _itemsPerRow(maxWidth, iconSize, spacing);

          return SizedBox(
            width: double.infinity,
            height: iconSize,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                itemsPerRow,
                (_) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                  child: SvgPicture.asset(
                    'assets/svg/pattern.svg',
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      color,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
