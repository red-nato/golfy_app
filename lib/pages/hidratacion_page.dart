import 'package:flutter/material.dart';

import '../widgets/clima_card.dart';

const _hoyos = [3, 6, 9, 12, 15, 18];

class HidratacionPage extends StatefulWidget {
  const HidratacionPage({super.key});

  @override
  State<HidratacionPage> createState() => _HidratacionPageState();
}

class _HidratacionPageState extends State<HidratacionPage> {
  bool _recordatorios = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Colores propios de esta pantalla (azul agua y arena), con versión oscura.
    final azul = isDark ? const Color(0xFF7DB8E0) : const Color(0xFF1F628F);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan de hidratación',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Plan de ejemplo · 18 hoyos',
              style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            const ClimaCard(),
            const SizedBox(height: 14),
            // Cuánta agua llevar y cuándo tomarla
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agua del plan de ejemplo',
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '2,6 L',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                      color: azul,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ejemplo para 4 h 30 min de juego. '
                    'Esta cantidad no se calcula a partir del clima.',
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Toma 250 ml cada 3 hoyos',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      // Línea que une los hoyos
                      Positioned(
                        left: 18,
                        right: 18,
                        top: 17,
                        child: Container(
                          height: 2,
                          color: azul.withValues(alpha: 0.3),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final h in _hoyos)
                            Column(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF1F628F),
                                  ),
                                  child: Text(
                                    '$h',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'hoyo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                children: [
                  const _Fila('Antes de salir', '500 ml'),
                  Divider(height: 1, color: scheme.outlineVariant),
                  const _Fila('Al terminar, con electrolitos', '500 ml'),
                  Divider(height: 1, color: scheme.outlineVariant),
                  const _Fila('Con UV alto: bloqueador y gorra', 'cada 2 h'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'El clima corresponde a hoy en Santiago. El plan de agua es '
              'referencial y no cambia al actualizar el clima.',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Material(
              color: _recordatorios
                  ? scheme.primaryContainer
                  : scheme.inverseSurface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _recordatorios = !_recordatorios),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  child: Text(
                    _recordatorios
                        ? 'Recordatorios de agua activados'
                        : 'Activar recordatorios de agua',
                    style: TextStyle(
                      color: _recordatorios
                          ? scheme.onPrimaryContainer
                          : scheme.onInverseSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(this.label, this.valor);

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          const SizedBox(width: 8),
          Text(
            valor,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
