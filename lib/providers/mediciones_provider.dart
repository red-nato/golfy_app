import 'package:flutter/foundation.dart';

import '../models/medicion.dart';
import '../services/mediciones_service.dart';

// Las mediciones de quien inició sesión. Las comparten la pestaña Mediciones
// (que las muestra) y el formulario (que las crea y edita).
class MedicionesProvider extends ChangeNotifier {
  // El servicio se puede reemplazar en las pruebas por uno falso.
  MedicionesProvider({MedicionesService? servicio})
    : _servicio = servicio ?? MedicionesService();

  final MedicionesService _servicio;

  List<Medicion> mediciones = [];
  bool cargando = false;
  String? error;

  // La más reciente: la lista viene ordenada por fecha, de nueva a antigua.
  Medicion? get ultima => mediciones.isEmpty ? null : mediciones.first;

  // Carga desde cero. Vacía la lista primero para no mostrar ni un instante
  // las mediciones de otro usuario que haya usado la app antes.
  Future<void> cargar() async {
    mediciones = [];
    await _traer();
  }

  Future<void> _traer() async {
    cargando = true;
    error = null;
    notifyListeners();
    try {
      mediciones = await _servicio.obtener();
    } catch (_) {
      error = 'No se pudieron cargar tus mediciones.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // Sin id es nueva (crear); con id ya existe (editar).
  // Devuelve null si salió bien, o el texto del error.
  Future<String?> guardar(Medicion medicion) async {
    try {
      if (medicion.id == null) {
        await _servicio.crear(medicion);
      } else {
        await _servicio.editar(medicion);
      }
    } catch (_) {
      return 'No se pudo guardar la medición. Revisa tu conexión.';
    }
    await _traer();
    return null;
  }

  Future<String?> borrar(String id) async {
    try {
      await _servicio.borrar(id);
    } catch (_) {
      return 'No se pudo borrar la medición.';
    }
    // Ya se borró en Supabase: la quitamos de la lista sin volver a pedirla.
    mediciones = mediciones.where((m) => m.id != id).toList();
    notifyListeners();
    return null;
  }
}