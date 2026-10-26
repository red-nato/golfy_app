import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'providers/clima_provider.dart';
import 'screens/golfy_main.dart';
import 'theme.dart';

Future<void> main() async {
  // Deja a Flutter listo antes del await: Supabase lo necesita antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();


  await Supabase.initialize(
    url: 'https://uktdjxcvdvfbekydzgwo.supabase.co',
    publishableKey: 'sb_publishable_wi9TNZ7rU1h6-7ROYYcsqw_LWLwe3DF',
  );

  runApp(
    // Los providers envuelven el MaterialApp: los ven todas las pantallas.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClimaProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          home: const GolfyMain(),
        );
      },
    );
  }
}