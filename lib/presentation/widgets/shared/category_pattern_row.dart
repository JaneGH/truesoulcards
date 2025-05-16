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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemsPerRow = (constraints.maxWidth / (iconSize + spacing)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(itemsPerRow, (index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: SvgPicture.asset(
              'assets/svg/pattern.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: ColorFilter.mode(
                color,
                BlendMode.srcIn,
              ),
            ),
          )),
        );
      },
    );
  }
}
