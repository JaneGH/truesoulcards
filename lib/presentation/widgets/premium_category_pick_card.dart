import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/presentation/utils/category_color_utils.dart';
import 'package:truesoulcards/presentation/utils/category_icon_mapper.dart';
import 'package:truesoulcards/theme/app_colors.dart';

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
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = ref.watch(languageProvider)['primary'] ?? 'en';

    final base = Color(widget.category.color);
    final radius = BorderRadius.circular(28);

    final top = widget.isSelected
        ? categoryGradientTop(base, isDark).withOpacity(0.92)
        : categoryGradientTop(base, isDark).withOpacity(0.62);

    final mid = widget.isSelected
        ? categoryGradientMid(base, isDark).withOpacity(0.90)
        : categoryGradientMid(base, isDark).withOpacity(0.56);

    final bottom = widget.isSelected
        ? categoryGradientBottom(base, isDark).withOpacity(0.94)
        : categoryGradientBottom(base, isDark).withOpacity(0.60);

    final onCard = isDark ? theme.colorScheme.onSurface : AppColors.darkBrown;

    final iconColor = widget.isSelected
        ? base.darken(0.22)
        : onCard.withOpacity(isDark ? 0.82 : 0.78);

    final titleColor = widget.isSelected
        ? onCard
        : onCard.withOpacity(isDark ? 0.88 : 0.82);

    return AnimatedScale(
      scale: _pressed
          ? 0.975
          : widget.isSelected
          ? 1.012
          : 1,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: widget.isSelected
                ? Colors.white.withOpacity(0.62)
                : Colors.white.withOpacity(0.34),
            width: widget.isSelected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? base.withOpacity(0.20)
                  : Colors.black.withOpacity(0.055),
              blurRadius: widget.isSelected ? 22 : 14,
              spreadRadius: widget.isSelected ? 0.5 : 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: categoryGlowColor(base, widget.isSelected).withOpacity(
                widget.isSelected ? 0.12 : 0.05,
              ),
              blurRadius: widget.isSelected ? 10 : 4,
              spreadRadius: 0,
              offset: Offset.zero,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapCancel: () => setState(() => _pressed = false),
              onTap: () {
                setState(() => _pressed = false);
                widget.onTap();
              },
              borderRadius: radius,
              splashFactory: InkSparkle.splashFactory,
              child: Stack(
                fit: StackFit.expand,
                children: [
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
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: const SizedBox.expand(),
                  ),

                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(
                            widget.isSelected ? 0.26 : 0.34,
                          ),
                          Colors.white.withOpacity(
                            widget.isSelected ? 0.08 : 0.16,
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),


                  Positioned(
                    left: -14,
                    bottom: -10,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 68,
                      color: Colors.white.withOpacity(
                        widget.isSelected ? 0.08 : 0.045,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          width: widget.isSelected ? 52 : 48,
                          height: widget.isSelected ? 52 : 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(
                              widget.isSelected ? 0.38 : 0.24,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                widget.isSelected ? 0.48 : 0.28,
                              ),
                            ),
                          ),
                          child: Center(
                            child: categoryIcon(
                              widget.category.img,
                              size:27,
                              color: iconColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.category.getTitle(lang),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.1,
                            color: titleColor,
                            height: 1.12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 10,
                    right: 10,
                    child: AnimatedOpacity(
                      opacity: widget.isSelected ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: AnimatedScale(
                        scale: widget.isSelected ? 1 : 0.72,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        child: IgnorePointer(
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.88),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.72),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: base.withOpacity(0.26),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: base.darken(0.18),
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