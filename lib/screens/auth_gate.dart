import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'golfy_main.dart';
import 'login_screen.dart';

// El login obligatorio: escucha la sesión de Supabase. Sin sesión muestra el
// login; con sesión, la app. Al entrar o salir se vuelve a dibujar solo, sin
// Navigator.pushReplacement.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, _) {
        return auth.currentSession == null
            ? const LoginScreen()
            : const GolfyMain();
      },
    );
  }
}