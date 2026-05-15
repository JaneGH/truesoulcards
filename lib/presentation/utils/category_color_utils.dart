import 'package:flutter/material.dart';

Color categoryGradientTop(Color base, bool isDark) {
  if (isDark) {
    return Color.lerp(base, Colors.white, 0.12)!;
  }
  return Color.lerp(base, Colors.white, 0.42)!;
}

Color categoryGradientMid(Color base, bool isDark) {
  if (isDark) {
    return Color.lerp(base, Colors.black, 0.18)!;
  }
  return Color.lerp(base, Colors.white, 0.18)!;
}

Color categoryGradientBottom(Color base, bool isDark) {
  if (isDark) {
    return Color.lerp(base, Colors.black, 0.35)!;
  }
  return Color.lerp(base, const Color(0xFF6B5B73), 0.22)!;
}

Color categoryGlowColor(Color base, bool selected) {
  return base.withAlpha(((selected ? 0.55 : 0.28) * 255).round());
}
