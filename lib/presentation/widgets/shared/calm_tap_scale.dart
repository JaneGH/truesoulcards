import 'package:flutter/material.dart';

/// Gentle press feedback for tappable surfaces — slow, calm, premium.
///
/// Wraps any child (e.g. [InkWell], [Material]) and scales down slightly on
/// pointer down. Does not handle taps itself.
class CalmTapScale extends StatefulWidget {
  const CalmTapScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.pressedScale = 0.978,
    this.selectedScale,
    this.isSelected = false,
    this.duration = const Duration(milliseconds: 160),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final bool enabled;
  final double pressedScale;
  final double? selectedScale;
  final bool isSelected;
  final Duration duration;
  final Curve curve;

  @override
  State<CalmTapScale> createState() => _CalmTapScaleState();
}

class _CalmTapScaleState extends State<CalmTapScale> {
  bool _pressed = false;

  double get _targetScale {
    if (!widget.enabled) return 1;
    if (_pressed) return widget.pressedScale;
    if (widget.isSelected && widget.selectedScale != null) {
      return widget.selectedScale!;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown:
          widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onPointerUp:
          widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onPointerCancel:
          widget.enabled ? (_) => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _targetScale,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}
