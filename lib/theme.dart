import 'package:flutter/material.dart';

// Guarda qué tema está activo. Cualquier parte de la app puede cambiarlo.
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

const golfGreen = Color(0xFF14573A);
const golfLime = Color(0xFFD6ED8A);

ThemeData _golfTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: golfGreen,
        brightness: brightness,
      ).copyWith(
        primary: dark ? const Color(0xFFADE0B3) : golfGreen,
        primaryContainer: dark
            ? const Color(0xFF34503C)
            : const Color(0xFFE2EDCF),
        onPrimaryContainer: dark ? golfLime : golfGreen,
        secondary: dark ? golfLime : const Color(0xFF526C27),
        surface: dark ? const Color(0xFF14201A) : const Color(0xFFFAFBF6),
        surfaceContainerLow: dark ? const Color(0xFF1B2A21) : Colors.white,
        outlineVariant: dark
            ? const Color(0xFF36493B)
            : const Color(0xFFDDE5D7),
      );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 72,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: dark ? const Color(0xFF355038) : golfLime,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

final lightTheme = _golfTheme(Brightness.light);
final darkTheme = _golfTheme(Brightness.dark);
