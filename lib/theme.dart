import 'package:flutter/material.dart';

// Guarda qué tema está activo. Cualquier parte de la app puede cambiarlo.
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

const _seed = Color(0xFF14573A); // verde de tu diseño

final lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: _seed),
  scaffoldBackgroundColor: const Color(0xFFF4F6F1),
);

final darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xFF1A1A1A),
);