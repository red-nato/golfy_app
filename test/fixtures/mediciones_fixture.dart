import 'package:golfy_app/models/medicion.dart';
import 'package:golfy_app/services/mediciones_service.dart';

// Un servicio que no se conecta a Supabase: entrega mediciones fijas para
// que las pruebas de la interfaz corran sin internet.
class MedicionesServiceFalso extends MedicionesService {
  @override
  Future<List<Medicion>> obtener() async {
    return [
      Medicion(
        id: '2',
        fecha: DateTime(2026, 10, 8),
        peso: 78.4,
        estatura: 1.79,
        pulso: 58,
      ),
      Medicion(
        id: '1',
        fecha: DateTime(2026, 10, 1),
        peso: 78.7,
        estatura: 1.79,
        pulso: 59,
      ),
    ];
  }
}