import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: AppColors.lightBrownOrange,
    ),
    appBarTheme: const AppBarTheme(centerTitle: false),
    fontFamily: 'Roboto',
  );
}

ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: AppColors.darkBrownOrange,
    ),
    appBarTheme: const AppBarTheme(centerTitle: false),
    fontFamily: 'Roboto',
  );
}
