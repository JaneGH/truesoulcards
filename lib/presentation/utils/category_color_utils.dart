import 'package:flutter/material.dart';

Color categoryGradientTop(Color base, bool isDark) {
  if (isDark) {
    return Color.lerp(base, Colors.white, 0.14)!;
  }
  return Color.lerp(base, Colors.white, 0.48)!;
}

Color categoryGradientMid(Color base, bool isDark) {
  if (isDark) {
    return Color.lerp(base, Colors.black, 0.14)!;
  }
  return Color.lerp(base, Colors.white, 0.22)!;
}

Color categoryGradientBottom(Color base, bool isDark) {
  if (isDark) {
    return Color.lerp(base, Colors.black, 0.28)!;
  }
  return Color.lerp(base, const Color(0xFF7A6E78), 0.18)!;
}

Color categoryGlowColor(Color base, bool selected) {
  return base.withAlpha(((selected ? 0.42 : 0.20) * 255).round());
}
