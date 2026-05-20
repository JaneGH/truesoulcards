import 'package:flutter/material.dart';
import 'package:truesoulcards/presentation/widgets/glass_card.dart';

/// Glass surface that gently lifts on focus — pass the same [focusNode] to the field.
class PremiumFocusField extends StatefulWidget {
  const PremiumFocusField({
    super.key,
    required this.focusNode,
    required this.backgroundColor,
    required this.outlineColor,
    required this.shadowColor,
    required this.child,
    this.borderRadius = 20,
    this.blurSigma = 10,
    this.padding = EdgeInsets.zero,
  });

  final FocusNode focusNode;
  final Color backgroundColor;
  final Color outlineColor;
  final Color shadowColor;
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final EdgeInsets padding;

  @override
  State<PremiumFocusField> createState() => _PremiumFocusFieldState();
}

class _PremiumFocusFieldState extends State<PremiumFocusField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_syncFocus);
  }

  @override
  void didUpdateWidget(covariant PremiumFocusField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_syncFocus);
      widget.focusNode.addListener(_syncFocus);
      _syncFocus();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_syncFocus);
    super.dispose();
  }

  void _syncFocus() {
    final next = widget.focusNode.hasFocus;
    if (next != _focused) {
      setState(() => _focused = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: widget.padding,
      backgroundColor: widget.backgroundColor,
      outlineColor: widget.outlineColor,
      shadowColor: widget.shadowColor,
      borderRadius: widget.borderRadius,
      blurSigma: widget.blurSigma,
      emphasis: _focused ? 1 : 0,
      child: widget.child,
    );
  }
}
