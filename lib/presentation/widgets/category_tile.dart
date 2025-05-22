import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/theme/app_colors.dart';

class CategoryTile extends ConsumerStatefulWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;
  final double borderRadius;
  final Duration animationDuration;

  const CategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.borderRadius = 16,
    this.animationDuration = const Duration(milliseconds: 300),
    super.key,
  });

  @override
  ConsumerState<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends ConsumerState<CategoryTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final languages = ref.watch(languageProvider);
    final primaryLang = languages['primary'] ?? 'en';
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;

    final backgroundColor = widget.isSelected
        ? primaryColor.withAlpha((0.85 * 255).round())
        : AppColors.backgroundLightWarmer;

    final borderColor = widget.isSelected ? primaryColor : Colors.grey.shade300;
    final textColor = widget.isSelected ? Colors.white : onSurfaceColor;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: widget.isSelected
              ? LinearGradient(
            colors: [primaryColor.withAlpha((0.6 * 255).round()), primaryColor.withAlpha((0.7 * 255).round())],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: widget.isSelected ? null : backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: widget.isSelected
              ? [
            BoxShadow(
              color: primaryColor.withAlpha((0.3 * 255).round()),
              offset: const Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            splashFactory: InkRipple.splashFactory,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Center(
                child: Text(
                  widget.category.getTitle(primaryLang),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    shadows: widget.isSelected
                        ? [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black.withAlpha((0.25 * 255).round()),
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
