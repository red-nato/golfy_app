import 'package:golfy_app/models/clima.dart';
import 'package:golfy_app/services/clima_service.dart';

Map<String, dynamic> climaJson() => {
  'current': <String, dynamic>{
    'time': '2026-10-25T14:15',
    'temperature_2m': 22.4,
    'relative_humidity_2m': 48,
    'uv_index': 6.2,
    'wind_speed_10m': 12.5,
    'precipitation_probability': 10,
  },
};

class ClimaServiceFalso extends ClimaService {
  int consultas = 0;

  @override
  Future<Clima> obtenerClima() async {
    consultas++;
    return Clima.fromJson(climaJson());
  }
}
