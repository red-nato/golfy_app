import 'package:flutter/foundation.dart';

import '../models/clima.dart';
import '../services/clima_service.dart';

class ClimaProvider extends ChangeNotifier {
  ClimaProvider({ClimaService? servicio})
    : _servicio = servicio ?? ClimaService() {
    clima = _servicio.obtenerClima();
  }

  final ClimaService _servicio;

  // Se guarda el Future, como en la clase: build no vuelve a pedir los datos.
  late Future<Clima> clima;

  void actualizar() {
    clima = _servicio.obtenerClima();
    notifyListeners();
  }
}
