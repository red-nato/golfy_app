import 'package:dio/dio.dart';

import '../models/clima.dart';

class ClimaService {
  ClimaService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.open-meteo.com/v1',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;
  static const ciudad = 'Santiago';

  Future<Clima> obtenerClima() async {
    final respuesta = await _dio.get<Map<String, dynamic>>(
      '/forecast',
      queryParameters: {
        'latitude': -33.45,
        'longitude': -70.67,
        'current':
            'temperature_2m,relative_humidity_2m,uv_index,'
            'wind_speed_10m,precipitation_probability',
        'temperature_unit': 'celsius',
        'wind_speed_unit': 'kmh',
        'timezone': 'America/Santiago',
        'forecast_days': 1,
      },
    );
    final json = respuesta.data;
    if (json == null) {
      throw const FormatException('La respuesta del clima está vacía.');
    }
    return Clima.fromJson(json);
  }
}
