import 'package:flutter/material.dart';
import 'screens/golfy_main.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Se reconstruye cada vez que themeNotifier cambia.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Golfy',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          home: const GolfyMain(),
        );
      },
    );
  }
}