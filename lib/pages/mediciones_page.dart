import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medicion.dart';
import '../providers/mediciones_provider.dart';
import '../widgets/golf_identity.dart';
import 'nueva_medicion_page.dart';

const _green = Color(0xFF14573A);

const _tipos = ['Peso', 'IMC', 'Pulso reposo'];
const _unidades = ['kg', '', 'lpm'];

// El dato que muestra cada pestaña del selector. El pulso puede faltar.
double? _valor(Medicion m, int tipo) {
  if (tipo == 0) return m.peso;
  if (tipo == 1) return m.imc;
  return m.pulso?.toDouble();
}

// Con coma decimal: el pulso sin decimales, el resto con uno.
String _formato(double valor, int tipo) {
  return valor.toStringAsFixed(tipo == 2 ? 0 : 1).replaceAll('.', ',');
}

// Las mediciones de un tipo (Peso, IMC o Pulso), listas para dibujar.
class _Serie {
  _Serie(this.tipo, List<Medicion> todas)
    : registros = [
        for (final m in todas)
          if (_valor(m, tipo) != null) m,
      ];

  final int tipo;
  final List<Medicion> registros; // de la más reciente a la más antigua

  String get unidad => _unidades[tipo];
  Medicion get ultima => registros.first;

  String texto(Medicion m) {
    final u = unidad.isEmpty ? '' : ' $unidad';
    return '${_formato(_valor(m, tipo)!, tipo)}$u';
  }

  // Diferencia con la medición anterior, o null si hay una sola.
  String? get cambio {
    if (registros.length < 2) return null;
    final dif = _valor(registros[0], tipo)! - _valor(registros[1], tipo)!;
    final signo = dif > 0 ? '+' : (dif < 0 ? '−' : '±');
    final u = unidad.isEmpty ? '' : ' $unidad';
    return '$signo${_formato(dif.abs(), tipo)}$u vs. la anterior';
  }

  // Hasta 8 puntos para el gráfico, de la más antigua a la más reciente.
  List<Medicion> get grafico => registros.take(8).toList().reversed.toList();
}

class MedicionesPage extends StatefulWidget {
  const MedicionesPage({super.key});

  @override
  State<MedicionesPage> createState() => _MedicionesPageState();
}

class _MedicionesPageState extends State<MedicionesPage> {
  int _tipo = 0;

  @override
  void initState() {
    super.initState();
    // Pide las mediciones al aparecer la pantalla, después del primer frame:
    // cargar() avisa con notifyListeners y no se puede hacer durante un build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MedicionesProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicionesProvider>();
    final serie = _Serie(_tipo, provider.mediciones);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GolfHeading(
            title: 'Conoce tu evolución',
            subtitle: 'Pequeños cambios. Un juego más sólido.',
            icon: Icons.insights_rounded,
            hole: '02 / MEDICIONES',
          ),
          const SizedBox(height: 16),
          _Selector(
            seleccionado: _tipo,
            onChanged: (i) => setState(() => _tipo = i),
          ),
          const SizedBox(height: 16),
          if (provider.cargando && provider.mediciones.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.error != null)
            _Aviso(
              icono: Icons.cloud_off_rounded,
              texto: provider.error!,
              accion: 'Reintentar',
              onAccion: () => context.read<MedicionesProvider>().cargar(),
            )
          else if (serie.registros.isEmpty)
            _Aviso(
              icono: Icons.monitor_weight_outlined,
              texto: provider.mediciones.isEmpty
                  ? 'Aún no tienes mediciones. Registra la primera para '
                        'empezar a ver tu evolución.'
                  : 'Ninguna de tus mediciones tiene pulso registrado.',
            )
          else ...[
            _GraficoCard(serie: serie),
            const SizedBox(height: 18),
            Text(
              'Historial',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Toca una medición para editarla.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _Historial(serie: serie),
          ],
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
                child: AnimatedContainer(
                  duration: Duration(
                    milliseconds: MediaQuery.disableAnimationsOf(context)
                        ? 0
                        : 240,
                  ),
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
    final puntos = serie.grafico;
    final cambio = serie.cambio;

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
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Último registro · ${serie.ultima.fechaCorta}',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: _formato(_valor(serie.ultima, serie.tipo)!, serie.tipo),
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
              if (cambio != null)
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
                    cambio,
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
          // La línea necesita al menos dos puntos.
          if (puntos.length < 2)
            SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  'Registra otra medición para ver la línea de tu evolución.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(
                painter: _LineaPainter(
                  puntos: [for (final m in puntos) _valor(m, serie.tipo)!],
                  colorGrilla: scheme.outlineVariant,
                  colorFondoPunto: scheme.surfaceContainerLow,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final m in [puntos.first, puntos.last])
                  Text(
                    m.fechaCorta,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
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
      final y =
          margen + (maximo - puntos[i]) / rango * (size.height - margen * 2);
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
  const _Historial({required this.serie});

  final _Serie serie;

  void _editar(BuildContext context, Medicion m) {
    // La medición viaja a la pantalla del formulario por su constructor.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NuevaMedicionPage(medicion: m)),
    );
  }

  Future<void> _borrar(BuildContext context, Medicion m) async {
    // Se toman antes del await: después, este context podría ya no existir.
    final provider = context.read<MedicionesProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar esta medición?'),
        content: Text('Se borrará la medición del ${m.fechaCorta}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final error = await provider.borrar(m.id!);
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Medición borrada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filas = serie.registros;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (var i = 0; i < filas.length; i++) ...[
              if (i > 0) Divider(height: 1, color: scheme.outlineVariant),
              InkWell(
                onTap: () => _editar(context, filas[i]),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 4),
                  child: SizedBox(
                    height: 52,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            filas[i].fechaCorta,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Text(
                          serie.texto(filas[i]),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Borrar',
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                          onPressed: () => _borrar(context, filas[i]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Una tarjeta para los estados de error y vacío, con una acción opcional.
class _Aviso extends StatelessWidget {
  const _Aviso({
    required this.icono,
    required this.texto,
    this.accion,
    this.onAccion,
  });

  final IconData icono;
  final String texto;
  final String? accion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icono, size: 40, color: _green),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
          ),
          if (accion != null) ...[
            const SizedBox(height: 10),
            TextButton(onPressed: onAccion, child: Text(accion!)),
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