import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:golfy_app/main.dart';
import 'package:golfy_app/providers/clima_provider.dart';
import 'package:golfy_app/screens/golfy_main.dart';
import 'package:golfy_app/theme.dart';
import 'package:golfy_app/widgets/golf_identity.dart';

import 'fixtures/clima_fixture.dart';

Widget _app({ClimaServiceFalso? servicio}) => ChangeNotifierProvider(
  create: (_) => ClimaProvider(servicio: servicio ?? ClimaServiceFalso()),
  // Sin Supabase: las pruebas entran directo a la app.
  child: const MyApp(home: GolfyMain()),
);

void main() {
  for (final width in [360.0, 840.0, 1440.0]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('Recorrido sin desbordes: $width, $mode', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(() => themeNotifier.value = ThemeMode.system);
        themeNotifier.value = mode;
        await tester.pumpWidget(_app());
        await tester.pump(const Duration(milliseconds: 900));
        expect(find.byType(FairwayScene), findsOneWidget);
        expect(tester.takeException(), isNull);
        for (final label in [
          'Mediciones',
          'Carga',
          'Bienestar',
          'Perfil',
          'Inicio',
        ]) {
          await tester.tap(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text(label),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 900));
          expect(tester.takeException(), isNull, reason: label);
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  testWidgets('Cambiar de pestaña conserva la selección de medición', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 500));
    Future<void> abrir(String label) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    await abrir('Mediciones');
    await tester.tap(find.text('Pulso reposo'));
    await tester.pump(const Duration(milliseconds: 300));
    await abrir('Perfil');
    await abrir('Mediciones');
    expect(find.textContaining('58', findRichText: true), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Movimiento reducido deja el campo estático', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('Inicio e Hidratación usan la misma consulta de clima', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final servicio = ClimaServiceFalso();
    await tester.pumpWidget(_app(servicio: servicio));
    await tester.pumpAndSettle();
    expect(servicio.consultas, 1);
    expect(find.text('22,4 °C · UV 6,2'), findsOneWidget);
    final ronda = find.text('PRÓXIMA RONDA · SÁBADO');
    await tester.ensureVisible(ronda);
    await tester.tap(ronda);
    await tester.pumpAndSettle();
    expect(find.text('22,4 °C'), findsOneWidget);
    expect(find.text('12,5 km/h'), findsOneWidget);
    expect(servicio.consultas, 1);
    await tester.tap(find.byTooltip('Actualizar clima').last);
    await tester.pumpAndSettle();
    expect(servicio.consultas, 2);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('22,4 °C · UV 6,2'), findsOneWidget);
    expect(servicio.consultas, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
