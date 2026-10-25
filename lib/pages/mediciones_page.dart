import 'package:flutter/material.dart';
import 'nueva_medicion_page.dart';

const _green = Color(0xFF14573A);

// Datos de cada tipo de medición (por ahora fijos, luego vendrán de una base).
class _Serie {
  const _Serie({
    required this.ultimo,
    required this.unidad,
    required this.cambio,
    required this.puntos,
    required this.historial,
  });

  final String ultimo;
  final String unidad;
  final String cambio;
  final List<double> puntos;
  final List<List<String>> historial; // [fecha, valor]
}

const _tipos = ['Peso', 'IMC', 'Pulso reposo'];

const _series = [
  _Serie(
    ultimo: '78,4',
    unidad: 'kg',
    cambio: '−1,2 kg en 30 días',
    puntos: [79.6, 79.3, 78.9, 78.7, 78.8, 78.6, 78.5, 78.4],
    historial: [
      ['8 oct', '78,4 kg'],
      ['1 oct', '78,7 kg'],
      ['24 sep', '79,0 kg'],
    ],
  ),
  _Serie(
    ultimo: '24,5',
    unidad: '',
    cambio: '−0,4 en 30 días',
    puntos: [24.8, 24.7, 24.6, 24.6, 24.6, 24.5, 24.5, 24.5],
    historial: [
      ['8 oct', '24,5'],
      ['1 oct', '24,6'],
      ['24 sep', '24,7'],
    ],
  ),
  _Serie(
    ultimo: '58',
    unidad: 'lpm',
    cambio: '−2 lpm en 30 días',
    puntos: [60, 60, 59, 59, 60, 58, 58, 58],
    historial: [
      ['8 oct', '58 lpm'],
      ['1 oct', '59 lpm'],
      ['24 sep', '59 lpm'],
    ],
  ),
];

class MedicionesPage extends StatefulWidget {
  const MedicionesPage({super.key});

  @override
  State<MedicionesPage> createState() => _MedicionesPageState();
}

class _MedicionesPageState extends State<MedicionesPage> {
  int _tipo = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final serie = _series[_tipo];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mediciones',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _Selector(
            seleccionado: _tipo,
            onChanged: (i) => setState(() => _tipo = i),
          ),
          const SizedBox(height: 16),
          _GraficoCard(serie: serie),
          const SizedBox(height: 18),
          Text(
            'Historial',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _Historial(filas: serie.historial),
          const SizedBox(height: 16),
          const _BotonNueva(),
        ],
      ),
    );
  }
}

class _Selector extends StatelessWidget {
  const _Selector({required this.seleccionado, required this.onChanged});

  final int seleccionado;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _tipos.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == seleccionado ? _green : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _tipos[i],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: i == seleccionado
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: i == seleccionado ? Colors.white : null,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GraficoCard extends StatelessWidget {
  const _GraficoCard({required this.serie});

  final _Serie serie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final unidad = serie.unidad.isEmpty ? '' : ' ${serie.unidad}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Último registro · 8 oct',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: serie.ultimo,
                      children: [
                        TextSpan(
                          text: unidad,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 36,
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
                  color: isDark
                      ? _green.withValues(alpha: 0.5)
                      : const Color(0xFFDCEBDD),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  serie.cambio,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : _green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineaPainter(
                puntos: serie.puntos,
                colorGrilla: scheme.outlineVariant,
                colorFondoPunto: scheme.surfaceContainerLow,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final f in ['8 sep', '18 sep', '28 sep', '8 oct'])
                Text(
                  f,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Dibuja la línea del gráfico: grilla, área, línea y el punto final.
class _LineaPainter extends CustomPainter {
  _LineaPainter({
    required this.puntos,
    required this.colorGrilla,
    required this.colorFondoPunto,
  });

  final List<double> puntos;
  final Color colorGrilla;
  final Color colorFondoPunto;

  @override
  void paint(Canvas canvas, Size size) {
    const margen = 14.0;

    // Grilla horizontal.
    final grilla = Paint()
      ..color = colorGrilla
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = margen + i * (size.height - margen * 2) / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grilla);
    }

    // Convierte cada valor a una posición (x, y) dentro del dibujo.
    final minimo = puntos.reduce((a, b) => a < b ? a : b);
    final maximo = puntos.reduce((a, b) => a > b ? a : b);
    final rango = maximo == minimo ? 1.0 : maximo - minimo;

    final posiciones = <Offset>[];
    for (var i = 0; i < puntos.length; i++) {
      final x = margen + i * (size.width - margen * 2) / (puntos.length - 1);
      final y = margen + (maximo - puntos[i]) / rango * (size.height - margen * 2);
      posiciones.add(Offset(x, y));
    }

    final linea = Path()..moveTo(posiciones.first.dx, posiciones.first.dy);
    for (final p in posiciones.skip(1)) {
      linea.lineTo(p.dx, p.dy);
    }

    // Área bajo la línea.
    final area = Path.from(linea)
      ..lineTo(posiciones.last.dx, size.height)
      ..lineTo(posiciones.first.dx, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = _green.withValues(alpha: 0.15));

    // Línea.
    canvas.drawPath(
      linea,
      Paint()
        ..color = _green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Punto final.
    canvas.drawCircle(posiciones.last, 8, Paint()..color = colorFondoPunto);
    canvas.drawCircle(posiciones.last, 6, Paint()..color = _green);
  }

  @override
  bool shouldRepaint(_LineaPainter old) => old.puntos != puntos;
}

class _Historial extends StatelessWidget {
  const _Historial({required this.filas});

  final List<List<String>> filas;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < filas.length; i++) ...[
            if (i > 0) Divider(height: 1, color: scheme.outlineVariant),
            SizedBox(
              height: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(filas[i][0], style: const TextStyle(fontSize: 15)),
                  Text(
                    filas[i][1],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BotonNueva extends StatelessWidget {
  const _BotonNueva();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.inverseSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NuevaMedicionPage()),
        ),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: scheme.onInverseSurface),
              const SizedBox(width: 8),
              Text(
                'Nueva medición',
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
    );
  }
}
