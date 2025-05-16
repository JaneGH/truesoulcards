import 'package:flutter/material.dart';

ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: const Color(0xFFFF6F00),
    ),
    appBarTheme: const AppBarTheme(centerTitle: false),
    fontFamily: 'Roboto',
  );
}

ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: const Color(0xFFFF6F00),
    ),
    appBarTheme: const AppBarTheme(centerTitle: false),
    fontFamily: 'Roboto',
  );
}
