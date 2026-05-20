import 'package:flutter/material.dart';
import 'package:truesoulcards/theme/app_colors.dart';

Color categoryGradientTop(Color base, bool isDark) {
  if (isDark) {
    return Color.lerp(base, Colors.white, 0.14)!;
  }
  return Color.lerp(
    Color.lerp(base, AppColors.creamCeramic, 0.22)!,
    Colors.white,
    0.32,
  )!;
}

Color categoryGradientMid(Color base, bool isDark) {
  if (isDark) {
    return Color.lerp(base, Colors.black, 0.14)!;
  }
  return Color.lerp(
    base,
    AppColors.surfaceWarmMid,
    0.24,
  )!;
}

Color categoryGradientBottom(Color base, bool isDark) {
  if (isDark) {
    return Color.lerp(base, Colors.black, 0.28)!;
  }
  return Color.lerp(
    base,
    AppColors.darkBeige,
    0.22,
  )!;
}

Color categoryGlowColor(Color base, bool selected) {
  return base.withAlpha(((selected ? 0.42 : 0.20) * 255).round());
}
