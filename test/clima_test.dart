import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfy_app/models/clima.dart';
import 'package:golfy_app/providers/clima_provider.dart';
import 'package:golfy_app/services/clima_service.dart';

import 'fixtures/clima_fixture.dart';

class _RespuestaApi implements HttpClientAdapter {
  _RespuestaApi(this.json, {this.estado = 200});
  final Map<String, dynamic> json;
  final int estado;
  RequestOptions? peticion;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    peticion = options;
    return ResponseBody.fromString(
      jsonEncode(json),
      estado,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('Convierte valores JSON mixtos y conserva la hora de Santiago', () {
    final clima = Clima.fromJson(climaJson());
    expect(clima.temperatura, 22.4);
    expect(clima.humedad, 48.0);
    expect(clima.indiceUv, 6.2);
    expect(clima.viento, 12.5);
    expect(clima.probabilidadLluvia, 10.0);
    expect(clima.fechaTexto, '25/10/2026 · 14:15 h');
  });

  test('Rechaza respuestas vacías, fechas inválidas y valores nulos', () {
    expect(() => Clima.fromJson({}), throwsFormatException);
    final json = climaJson();
    json['current']['time'] = 'sin fecha';
    expect(() => Clima.fromJson(json), throwsFormatException);
    final incompleto = climaJson();
    incompleto['current']['uv_index'] = null;
    expect(() => Clima.fromJson(incompleto), throwsFormatException);
  });

  test(
    'El servicio consulta Santiago, unidades y las cinco variables',
    () async {
      final adaptador = _RespuestaApi(climaJson());
      final dio = Dio(BaseOptions(baseUrl: 'https://api.open-meteo.com/v1'))
        ..httpClientAdapter = adaptador;
      final clima = await ClimaService(dio: dio).obtenerClima();
      expect(clima.temperatura, 22.4);
      final peticion = adaptador.peticion!;
      expect(peticion.uri.path, '/v1/forecast');
      expect(peticion.queryParameters['latitude'], -33.45);
      expect(peticion.queryParameters['longitude'], -70.67);
      expect(peticion.queryParameters['timezone'], 'America/Santiago');
      expect(peticion.queryParameters['temperature_unit'], 'celsius');
      expect(peticion.queryParameters['wind_speed_unit'], 'kmh');
      expect(
        (peticion.queryParameters['current'] as String).split(','),
        hasLength(5),
      );
      dio.close();
    },
  );

  test(
    'El servicio propaga los errores HTTP para mostrarlos en pantalla',
    () async {
      final dio = Dio()
        ..httpClientAdapter = _RespuestaApi({'error': true}, estado: 503);
      await expectLater(
        ClimaService(dio: dio).obtenerClima(),
        throwsA(isA<DioException>()),
      );
      dio.close();
    },
  );

  test(
    'Provider conserva el Future y solo actualiza cuando se lo piden',
    () async {
      final servicio = ClimaServiceFalso();
      final provider = ClimaProvider(servicio: servicio);
      addTearDown(provider.dispose);
      final primero = provider.clima;
      await primero;
      expect(provider.clima, same(primero));
      expect(servicio.consultas, 1);
      var avisos = 0;
      provider.addListener(() => avisos++);
      provider.actualizar();
      await provider.clima;
      expect(provider.clima, isNot(same(primero)));
      expect(servicio.consultas, 2);
      expect(avisos, 1);
    },
  );
}
