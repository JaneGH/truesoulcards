import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/presentation/utils/category_color_utils.dart';
import 'package:truesoulcards/presentation/utils/category_icon_mapper.dart';
import 'package:truesoulcards/presentation/widgets/shared/calm_tap_scale.dart';
import 'package:truesoulcards/theme/app_colors.dart';
import 'package:truesoulcards/theme/app_decorations.dart';

class PremiumCategoryPickCard extends ConsumerStatefulWidget {
  const PremiumCategoryPickCard({
    super.key,
    required this.category,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final Category category;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  ConsumerState<PremiumCategoryPickCard> createState() =>
      _PremiumCategoryPickCardState();
}

class _PremiumCategoryPickCardState
    extends ConsumerState<PremiumCategoryPickCard> {
  Color _tunedBase(Color base) {
    final hsl = HSLColor.fromColor(base);

    if (widget.isSelected) {
      return hsl
          .withSaturation((hsl.saturation * 1.06).clamp(0.0, 1.0))
          .withLightness((hsl.lightness * 1.03).clamp(0.0, 1.0))
          .toColor();
    }

    return hsl
        .withSaturation((hsl.saturation * 0.86).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 0.97).clamp(0.0, 1.0))
        .toColor();
  }

  double _scaleFor(Size size) {
    final shortest = math.min(size.width, size.height);
    return (shortest / 150).clamp(0.78, 1.18);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardSize = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 150,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 150,
        );

        final scale = _scaleFor(cardSize);

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final lang = ref.watch(languageProvider)['primary'] ?? 'en';

        final base = _tunedBase(Color(widget.category.color));

        final radiusValue = 28 * scale;
        final radius = BorderRadius.circular(radiusValue);

        final iconCircleSize = widget.isSelected ? 52 * scale : 48 * scale;
        final iconSize = 27 * scale;

        final checkSize = 26 * scale;
        final checkIconSize = 15 * scale;
        final checkInset = 13 * scale;

        final patternWidth =
        (cardSize.shortestSide * 0.64).clamp(80.0, 130.0);

        final patternOffsetX =
        -(cardSize.shortestSide * 0.02).clamp(2.0, 6.0);

        final patternBottom =
        -((cardSize.shortestSide * 0.015).clamp(1.0, 6.0));

        final horizontalPadding = 14 * scale;

        final titleFontSize =
            (theme.textTheme.titleMedium?.fontSize ?? 16) *
                scale.clamp(0.9, 1.08);
        const titleLineHeight = 1.26;
        final titleMaxHeight = titleFontSize * titleLineHeight * 2;
        final iconTitleGap = 7 * scale;
        final iconSlotSize = 52 * scale;

        final top = widget.isSelected
            ? categoryGradientTop(base, isDark).withOpacity(0.96)
            : categoryGradientTop(base, isDark).withOpacity(0.72);

        final mid = widget.isSelected
            ? categoryGradientMid(base, isDark).withOpacity(0.94)
            : categoryGradientMid(base, isDark).withOpacity(0.68);

        final bottom = widget.isSelected
            ? categoryGradientBottom(base, isDark).withOpacity(0.97)
            : categoryGradientBottom(base, isDark).withOpacity(0.74);

        final onCard =
        isDark ? theme.colorScheme.onSurface : AppColors.darkBrown;

        final iconColor = widget.isSelected
            ? base.darken(0.20)
            : onCard.withOpacity(isDark ? 0.82 : 0.74);

        final titleColor = widget.isSelected
            ? onCard.withOpacity(isDark ? 0.94 : 0.90)
            : onCard.withOpacity(isDark ? 0.84 : 0.82);

        return CalmTapScale(
          isSelected: widget.isSelected,
          selectedScale: 1.008,
          pressedScale: 0.975,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: widget.isSelected
                    ? Colors.white.withOpacity(0.72)
                    : Colors.white.withOpacity(0.38),
                width: widget.isSelected ? 1.25 : 1,
              ),
              boxShadow: [
                ...AppDecorations.ambientCardShadow(
                  isDark: isDark,
                  tint: widget.isSelected ? base : AppColors.shadowWarm,
                  elevation: widget.isSelected ? 1.18 : 0.92,
                ),
                if (widget.isSelected)
                  ...AppDecorations.selectedSurfaceGlow(
                    isDark: isDark,
                    accent: base,
                    strength: 0.95,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: radius,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                              AppColors.backgroundDarkWarmer,
                              AppColors.backgroundDark,
                            ]
                                : [
                              AppColors.pearl,
                              AppColors.creamCeramic,
                              AppColors.surfaceWarmMid,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [top, mid, bottom],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: AppDecorations.premiumSurfaceBlurSigma(
                            3.2 * scale,
                          ),
                          sigmaY: AppDecorations.premiumSurfaceBlurSigma(
                            3.2 * scale,
                          ),
                        ),
                        child: const SizedBox.expand(),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(
                                widget.isSelected ? 0.12 : 0.10,
                              ),
                              Colors.white.withOpacity(
                                widget.isSelected ? 0.06 : 0.08,
                              ),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.38, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.darkBrown.withOpacity(
                                isDark ? 0.10 : 0.05,
                              ),
                            ],
                            stops: const [0.62, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: patternBottom,
                        left: cardSize.width * 0.01,
                        child: IgnorePointer(
                          child: ShaderMask(
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (rect) {
                              return const LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Colors.white,
                                  Colors.white,
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.28, 1.0],
                              ).createShader(rect);
                            },
                            child: SvgPicture.asset(
                              'assets/svg/vyshyvanka_border.svg',
                              width: patternWidth,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                HSLColor.fromColor(base)
                                    .withSaturation(
                                  (HSLColor.fromColor(base).saturation *
                                      1.18)
                                      .clamp(0.0, 1.0),
                                )
                                    .withLightness(
                                  (HSLColor.fromColor(base).lightness *
                                      0.64)
                                      .clamp(0.0, 1.0),
                                )
                                    .toColor()
                                    .withOpacity(
                                  widget.isSelected ? 0.40 : 0.28,
                                ),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Align(
                            alignment: const Alignment(0, 0.04),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: iconSlotSize,
                                  height: iconSlotSize,
                                  child: Center(
                                    child: AnimatedContainer(
                                      duration:
                                      const Duration(milliseconds: 240),
                                      curve: Curves.easeOutCubic,
                                      width: iconCircleSize,
                                      height: iconCircleSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(
                                          widget.isSelected ? 0.42 : 0.30,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(
                                            widget.isSelected ? 0.54 : 0.36,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              widget.isSelected ? 0.40 : 0.26,
                                            ),
                                            blurRadius: 9 * scale,
                                            spreadRadius: -2,
                                          ),
                                          BoxShadow(
                                            color: AppColors.shadowWarm
                                                .withOpacity(
                                              widget.isSelected ? 0.10 : 0.06,
                                            ),
                                            blurRadius: 6 * scale,
                                            offset: Offset(0, 2 * scale),
                                            spreadRadius: -1,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: categoryIcon(
                                          widget.category.img,
                                          size: iconSize,
                                          color: iconColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: iconTitleGap),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: titleMaxHeight,
                                  ),
                                  child: Text(
                                    widget.category.getTitle(lang),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                    theme.textTheme.titleMedium?.copyWith(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.12,
                                      color: titleColor,
                                      height: titleLineHeight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: checkInset,
                        right: checkInset,
                        child: AnimatedOpacity(
                          opacity: widget.isSelected ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: AnimatedScale(
                            scale: widget.isSelected ? 1 : 0.78,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: IgnorePointer(
                              child: Container(
                                width: checkSize,
                                height: checkSize,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.78),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.62),
                                    width: 1.1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: categoryGlowColor(base, true)
                                          .withOpacity(0.14),
                                      blurRadius: 8 * scale,
                                      spreadRadius: -1,
                                    ),
                                    BoxShadow(
                                      color: AppColors.shadowWarm.withOpacity(
                                        0.10,
                                      ),
                                      blurRadius: 6 * scale,
                                      offset: Offset(0, 2 * scale),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: checkIconSize,
                                  color: base.darken(0.22).withOpacity(
                                    isDark ? 0.88 : 0.82,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

extension _ColorDarken on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}