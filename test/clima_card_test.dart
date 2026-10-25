import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golfy_app/models/clima.dart';
import 'package:golfy_app/providers/clima_provider.dart';
import 'package:golfy_app/services/clima_service.dart';
import 'package:golfy_app/theme.dart';
import 'package:golfy_app/widgets/clima_card.dart';

import 'fixtures/clima_fixture.dart';

class _ServicioControlado extends ClimaService {
  final peticiones = <Completer<Clima>>[];
  @override
  Future<Clima> obtenerClima() {
    final peticion = Completer<Clima>();
    peticiones.add(peticion);
    return peticion.future;
  }
}

Widget _pantalla(
  ClimaProvider provider, {
  Widget child = const ClimaCard(),
  bool oscuro = false,
}) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      theme: oscuro ? darkTheme : lightTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  testWidgets('Carga y muestra los cinco datos y su fecha local', (
    tester,
  ) async {
    final servicio = _ServicioControlado();
    final provider = ClimaProvider(servicio: servicio);
    addTearDown(provider.dispose);
    await tester.pumpWidget(_pantalla(provider));
    expect(find.text('Consultando el clima…'), findsOneWidget);
    servicio.peticiones.single.complete(Clima.fromJson(climaJson()));
    await tester.pumpAndSettle();
    for (final texto in [
      '22,4 °C',
      '48 %',
      '6,2',
      '12,5 km/h',
      '10 %',
      'Santiago, Chile',
    ]) {
      expect(find.text(texto), findsOneWidget);
    }
    expect(find.textContaining('25/10/2026 · 14:15 h'), findsOneWidget);
    expect(find.text('Consultando el clima…'), findsNothing);
  });

  testWidgets('Un error permite reintentar y luego mostrar datos', (
    tester,
  ) async {
    final servicio = _ServicioControlado();
    final provider = ClimaProvider(servicio: servicio);
    addTearDown(provider.dispose);
    await tester.pumpWidget(_pantalla(provider));
    servicio.peticiones.first.completeError(Exception('sin conexión'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No pudimos cargar'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    expect(servicio.peticiones, hasLength(2));
    expect(find.text('Consultando el clima…'), findsOneWidget);
    servicio.peticiones.last.complete(Clima.fromJson(climaJson()));
    await tester.pumpAndSettle();
    expect(find.text('22,4 °C'), findsOneWidget);
  });

  testWidgets('Resumen y detalle comparten consulta y actualización', (
    tester,
  ) async {
    final servicio = ClimaServiceFalso();
    final provider = ClimaProvider(servicio: servicio);
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      _pantalla(
        provider,
        child: const Column(
          children: [ClimaCard(resumen: true), ClimaCard(resumen: true)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(servicio.consultas, 1);
    expect(find.text('22,4 °C · UV 6,2'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Actualizar clima').first);
    await tester.pumpAndSettle();
    expect(servicio.consultas, 2);
    expect(find.text('22,4 °C · UV 6,2'), findsNWidgets(2));
  });

  for (final oscuro in [false, true]) {
    testWidgets('Datos legibles en móvil, tema oscuro: $oscuro', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final provider = ClimaProvider(servicio: ClimaServiceFalso());
      addTearDown(provider.dispose);
      await tester.pumpWidget(_pantalla(provider, oscuro: oscuro));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
