import 'package:flutter/material.dart';
import 'chequeo_page.dart';

const _green = Color(0xFF14573A);

const _pasos = [
  'Reposo y movilidad suave',
  'Rango corto con wedges',
  'Rango completo con driver',
  'Ronda de 9 hoyos',
  'Ronda de 18 hoyos',
];

class BitacoraPage extends StatefulWidget {
  const BitacoraPage({super.key});

  @override
  State<BitacoraPage> createState() => _BitacoraPageState();
}

class _BitacoraPageState extends State<BitacoraPage> {
  // Cantidad de pasos ya completados. Con 1, el paso actual es el 2.
  int _completados = 1;

  bool get _terminado => _completados >= _pasos.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bitácora de lesiones',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACTIVA · DESDE EL 6 OCT',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 0.8,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Zona lumbar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6E2A6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Leve',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B2E05),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Retorno gradual al juego',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < _pasos.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _Paso(
                      numero: i + 1,
                      texto: _pasos[i],
                      completado: i < _completados,
                      actual: i == _completados,
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (_terminado)
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: _green),
                        SizedBox(width: 8),
                        Text(
                          'Retorno completo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _completados++),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.primary,
                          side: BorderSide(color: scheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Completar paso ${_completados + 1}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'HISTORIAL',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                children: [
                  const _FilaHistorial(
                    zona: 'Codo derecho',
                    detalle: '12 – 26 sep · Moderada',
                  ),
                  Divider(height: 1, color: scheme.outlineVariant),
                  const _FilaHistorial(
                    zona: 'Muñeca izquierda',
                    detalle: '3 – 10 jun · Leve',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Material(
              color: scheme.inverseSurface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChequeoPage()),
                ),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: scheme.onInverseSurface),
                      const SizedBox(width: 8),
                      Text(
                        'Registrar lesión',
                        style: TextStyle(
                          color: scheme.onInverseSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

// Un paso del retorno: hecho (check), actual (borde verde) o pendiente.
class _Paso extends StatelessWidget {
  const _Paso({
    required this.numero,
    required this.texto,
    required this.completado,
    required this.actual,
  });

  final int numero;
  final String texto;
  final bool completado;
  final bool actual;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completado ? _green : Colors.transparent,
            border: completado
                ? null
                : Border.all(
                    color: actual ? _green : scheme.outline,
                    width: actual ? 2 : 1,
                  ),
          ),
          child: completado
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  '$numero',
                  style: TextStyle(
                    fontSize: 13,
                    color: actual ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 15,
              fontWeight: actual ? FontWeight.w600 : FontWeight.w400,
              color: actual ? null : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilaHistorial extends StatelessWidget {
  const _FilaHistorial({required this.zona, required this.detalle});

  final String zona;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                zona,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                detalle,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          Text(
            'Alta',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
