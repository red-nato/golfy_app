import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/auth_provider.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  // Estado local de esta pantalla: va con setState, no en un provider.
  bool _verClave = false;
  bool _registro = false; // false = Entrar, true = Crear cuenta

  // algo @ algo . algo
  static final _correoValido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _correoCtrl.dispose();
    _claveCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    // Corre todos los validator; si alguno devuelve un texto, no sigue.
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final correo = _correoCtrl.text.trim();
    final clave = _claveCtrl.text;
    final error = _registro
        ? await auth.registrar(correo, clave)
        : await auth.entrar(correo, clave);

    // Si entró, el AuthGate ya cambió de pantalla y esta dejó de existir.
    if (!mounted) return;

    if (error != null) {
      _aviso(error);
      return;
    }
    // Con "Confirm email" activo en Supabase, la cuenta se crea sin sesión.
    if (_registro && Supabase.instance.client.auth.currentSession == null) {
      _aviso('Cuenta creada. Confirma tu correo y luego entra.');
      setState(() => _registro = false);
    }
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(texto)));
  }

  InputDecoration _decoracion(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cargando = context.watch<AuthProvider>().cargando;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: golfGreen,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.golf_course_rounded,
                          color: golfLime,
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'golfy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        color: scheme.primary,
                      ),
                    ),
                    Text(
                      _registro
                          ? 'Crea tu cuenta para guardar tus mediciones'
                          : 'Entra para ver tus mediciones',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: _decoracion('Correo', Icons.email_outlined),
                      validator: (value) {
                        final texto = value?.trim() ?? '';
                        if (texto.isEmpty) return 'Escribe tu correo';
                        if (!_correoValido.hasMatch(texto)) {
                          return 'Correo no válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _claveCtrl,
                      obscureText: !_verClave,
                      decoration: _decoracion('Contraseña', Icons.lock_outline)
                          .copyWith(
                            suffixIcon: IconButton(
                              tooltip: _verClave ? 'Ocultar' : 'Mostrar',
                              icon: Icon(
                                _verClave
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  setState(() => _verClave = !_verClave),
                            ),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Escribe tu contraseña';
                        }
                        // Supabase pide al menos 6 caracteres por defecto.
                        if (value.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    if (_registro) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmarCtrl,
                        obscureText: !_verClave,
                        decoration: _decoracion(
                          'Confirmar contraseña',
                          Icons.lock_reset,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Repite tu contraseña';
                          }
                          if (value != _claveCtrl.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 22),
                    FilledButton(
                      // null deshabilita el botón mientras espera a Supabase.
                      onPressed: cargando ? null : _enviar,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_registro ? 'Crear cuenta' : 'Entrar'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: cargando
                          ? null
                          : () => setState(() {
                              _registro = !_registro;
                              _confirmarCtrl.clear();
                            }),
                      child: Text(
                        _registro
                            ? '¿Ya tienes cuenta? Entra'
                            : '¿No tienes cuenta? Créala',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}