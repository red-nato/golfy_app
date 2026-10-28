import 'package:flutter/foundation.dart';

import '../models/sesion_carga.dart';

class CargaProvider extends ChangeNotifier {
  final List<SesionCarga> _sesiones = [];

  List<SesionCarga> get sesiones {
    final resultado = [..._sesiones];
    resultado.sort((a, b) => b.fecha.compareTo(a.fecha));
    return resultado;
  }

  List<SesionCarga> get estaSemana {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final lunes = hoy.subtract(Duration(days: hoy.weekday - 1));
    final proximoLunes = lunes.add(const Duration(days: 7));

    final resultado = _sesiones.where((sesion) {
      return !sesion.fecha.isBefore(lunes) &&
          sesion.fecha.isBefore(proximoLunes);
    }).toList();

    resultado.sort((a, b) => b.fecha.compareTo(a.fecha));
    return resultado;
  }

  SesionCarga? get ultima {
    final ordenadas = sesiones;
    return ordenadas.isEmpty ? null : ordenadas.first;
  }

  int get cargaSemana {
    return estaSemana.fold<int>(
      0,
      (total, sesion) => total + sesion.carga,
    );
  }

  List<SesionCarga?> get semanaActual {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final lunes = hoy.subtract(Duration(days: hoy.weekday - 1));

    return List.generate(7, (indice) {
      final fecha = lunes.add(Duration(days: indice));

      for (final sesion in _sesiones) {
        final mismaFecha = sesion.fecha.year == fecha.year &&
            sesion.fecha.month == fecha.month &&
            sesion.fecha.day == fecha.day;

        if (mismaFecha) return sesion;
      }

      return null;
    });
  }

  void guardar({
    required DateTime fecha,
    required int tipo,
    required int minutos,
    required int esfuerzo,
  }) {
    final dia = DateTime(fecha.year, fecha.month, fecha.day);

    _sesiones.removeWhere((sesion) {
      return sesion.fecha.year == dia.year &&
          sesion.fecha.month == dia.month &&
          sesion.fecha.day == dia.day;
    });

    _sesiones.add(
      SesionCarga(
        fecha: dia,
        tipo: tipo,
        minutos: minutos,
        esfuerzo: esfuerzo,
      ),
    );

    notifyListeners();
  }

  void eliminar(DateTime fecha) {
    final dia = DateTime(fecha.year, fecha.month, fecha.day);

    _sesiones.removeWhere((sesion) {
      return sesion.fecha.year == dia.year &&
          sesion.fecha.month == dia.month &&
          sesion.fecha.day == dia.day;
    });

    notifyListeners();
  }
}