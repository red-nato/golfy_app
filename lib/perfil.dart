import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Datos básicos del jugador. Se guardan en perfilNotifier para que Inicio y
// Perfil muestren siempre lo mismo (igual que themeNotifier en theme.dart).
class Perfil {
  const Perfil({
    required this.nombre,
    required this.edad,
    required this.peso,
    required this.estatura,
    required this.handicap,
    required this.manoDerecha,
  });

  final String nombre;
  final int edad;
  final double peso; // kg
  final double estatura; // m
  final double handicap;
  final bool manoDerecha;

  factory Perfil.fromUser(User? user) {
    final metadata = user?.userMetadata ?? const <String, dynamic>{};
    final email = user?.email ?? '';
    final nombre =
        _texto(metadata['full_name']) ??
        _texto(metadata['name']) ??
        _nombreDesdeCorreo(email) ??
        'Jugador';

    return Perfil(
      nombre: nombre,
      edad: _entero(metadata['age'], 22),
      peso: _decimal(metadata['weight_kg'], 78.4),
      estatura: _decimal(metadata['height_m'], 1.79),
      handicap: _decimal(metadata['handicap'], 8.4),
      manoDerecha: metadata['right_handed'] is bool
          ? metadata['right_handed'] as bool
          : true,
    );
  }

  // "Matías R." -> "Matías"
  String get primerNombre => nombre.trim().split(' ').first;

  // "Matías R." -> "MR"
  String get iniciales {
    final palabras = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (palabras.isEmpty) return '?';
    return palabras.take(2).map((p) => p[0]).join().toUpperCase();
  }

  double get imc => peso / (estatura * estatura);
}

String? _texto(Object? value) {
  final texto = value?.toString().trim();
  return texto == null || texto.isEmpty ? null : texto;
}

String? _nombreDesdeCorreo(String correo) {
  final local = correo.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
  final nombre = local
      .split(RegExp(r'\s+'))
      .where((parte) => parte.isNotEmpty)
      .map((parte) => '${parte[0].toUpperCase()}${parte.substring(1)}')
      .join(' ')
      .trim();
  return nombre.isEmpty ? null : nombre;
}

double _decimal(Object? value, double fallback) {
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

int _entero(Object? value, int fallback) {
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

// Número con coma decimal: 78.4 -> "78,4"
String coma(double v, [int decimales = 1]) {
  return v.toStringAsFixed(decimales).replaceAll('.', ',');
}

final perfilNotifier = ValueNotifier<Perfil>(
  const Perfil(
    nombre: 'Jugador',
    edad: 22,
    peso: 78.4,
    estatura: 1.79,
    handicap: 8.4,
    manoDerecha: true,
  ),
);
