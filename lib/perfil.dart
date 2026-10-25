import 'package:flutter/material.dart';

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

// Número con coma decimal: 78.4 -> "78,4"
String coma(double v, [int decimales = 1]) {
  return v.toStringAsFixed(decimales).replaceAll('.', ',');
}

final perfilNotifier = ValueNotifier<Perfil>(
  const Perfil(
    nombre: 'Matías R.',
    edad: 22,
    peso: 78.4,
    estatura: 1.79,
    handicap: 8.4,
    manoDerecha: true,
  ),
);
