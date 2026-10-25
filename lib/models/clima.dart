// Open-Meteo entrega la hora local de Santiago en current.time.
class Clima {
  const Clima({
    required this.fecha,
    required this.temperatura,
    required this.humedad,
    required this.indiceUv,
    required this.viento,
    required this.probabilidadLluvia,
  });

  final DateTime fecha;
  final double temperatura;
  final double humedad;
  final double indiceUv;
  final double viento;
  final double probabilidadLluvia;

  factory Clima.fromJson(Map<String, dynamic> json) {
    final actual = json['current'];
    if (actual is! Map<String, dynamic>) {
      throw const FormatException('La respuesta no incluye el clima.');
    }
    final fecha = DateTime.tryParse(actual['time']?.toString() ?? '');
    if (fecha == null) {
      throw const FormatException('La respuesta no incluye una fecha válida.');
    }

    double numero(String campo) {
      final valor = actual[campo];
      if (valor is! num || !valor.isFinite) {
        throw FormatException('No se recibió un valor válido para $campo.');
      }
      return valor.toDouble();
    }

    return Clima(
      fecha: fecha,
      temperatura: numero('temperature_2m'),
      humedad: numero('relative_humidity_2m'),
      indiceUv: numero('uv_index'),
      viento: numero('wind_speed_10m'),
      probabilidadLluvia: numero('precipitation_probability'),
    );
  }

  String get fechaTexto {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} · '
        '${dos(fecha.hour)}:${dos(fecha.minute)} h';
  }
}
