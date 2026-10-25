import 'package:flutter/material.dart';
import 'bitacora_page.dart';

const _green = Color(0xFF14573A);

const _niveles = ['Sin molestia', 'Leve', 'Moderada', 'Fuerte'];
const _zonas = ['Zona lumbar', 'Codo', 'Muñeca', 'Hombro', 'Cuello'];
const _alertas = [
  'Mareo o visión borrosa',
  'Náuseas',
  'Dolor de cabeza fuerte',
  'Calambres intensos',
];

class ChequeoPage extends StatefulWidget {
  const ChequeoPage({super.key});

  @override
  State<ChequeoPage> createState() => _ChequeoPageState();
}

class _ChequeoPageState extends State<ChequeoPage> {
  // Nivel de molestia de cada zona (0 = sin molestia ... 3 = fuerte).
  final List<int> _nivel = [1, 0, 0, 0, 0];
  final List<bool> _alerta = [false, false, false, false];

  bool get _hayAlerta => _alerta.contains(true);

  void _guardarYSalir() {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Chequeo guardado')));
  }

  void _guardarYAbrirBitacora() {
    // Reemplaza esta pantalla: al volver desde la bitácora llegas a Inicio.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BitacoraPage()),
    );
  }

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
              'Chequeo post-ronda',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Marca cómo quedó tu cuerpo después de jugar.',
              style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            const _Titulo('Molestias por zona'),
            const SizedBox(height: 8),
            _Grilla([
              for (var i = 0; i < _zonas.length; i++)
                _ZonaTile(
                  zona: _zonas[i],
                  nivel: _nivel[i],
                  // Cada toque sube un nivel y vuelve a "Sin molestia".
                  onTap: () => setState(() => _nivel[i] = (_nivel[i] + 1) % 4),
                ),
              const _ZonaTile(zona: 'Otra zona', nivel: 0, detalle: 'Agregar'),
            ]),
            const SizedBox(height: 16),
            const _Titulo('Señales de alerta'),
            const SizedBox(height: 8),
            _Grilla([
              for (var i = 0; i < _alertas.length; i++)
                _AlertaTile(
                  texto: _alertas[i],
                  marcada: _alerta[i],
                  onChanged: (v) => setState(() => _alerta[i] = v),
                ),
            ]),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                // Se resalta en amarillo si marcó alguna señal de alerta.
                color: _hayAlerta
                    ? const Color(0xFFF6E2A6)
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Si marcas una señal de alerta, deja de jugar, busca sombra, '
                'toma agua y consulta a un profesional de la salud. La app '
                'apoya tu registro y no entrega diagnósticos.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: _hayAlerta
                      ? const Color(0xFF3B2E05)
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Material(
              color: scheme.inverseSurface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _guardarYAbrirBitacora,
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  child: Text(
                    'Guardar y abrir bitácora',
                    style: TextStyle(
                      color: scheme.onInverseSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: _guardarYSalir,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  foregroundColor: scheme.primary,
                ),
                child: const Text(
                  'Solo guardar chequeo',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// Ordena widgets en 2 columnas.
class _Grilla extends StatelessWidget {
  const _Grilla(this.hijos);

  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < hijos.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < hijos.length ? 8 : 0),
            child: Row(
              children: [
                Expanded(child: hijos[i]),
                const SizedBox(width: 8),
                Expanded(
                  child: i + 1 < hijos.length ? hijos[i + 1] : const SizedBox(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ZonaTile extends StatelessWidget {
  const _ZonaTile({
    required this.zona,
    required this.nivel,
    this.onTap,
    this.detalle,
  });

  final String zona;
  final int nivel;
  final VoidCallback? onTap;
  final String? detalle; // si viene, reemplaza el nombre del nivel

  // Colores de fondo y texto según el nivel de molestia.
  static const _fondos = [
    null,
    Color(0xFFF6E2A6),
    Color(0xFFF3C58E),
    Color(0xFFF2B8B5),
  ];
  static const _textos = [
    null,
    Color(0xFF3B2E05),
    Color(0xFF3B2100),
    Color(0xFF410E0B),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fondo = _fondos[nivel] ?? scheme.surfaceContainerLow;
    final texto = _textos[nivel] ?? scheme.onSurface;

    return Material(
      color: fondo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: nivel == 0
            ? BorderSide(color: scheme.outlineVariant)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap ?? () {}, // "Otra zona": luego abrir selector de zonas
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                zona,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: texto,
                ),
              ),
              Text(
                detalle ?? _niveles[nivel],
                style: TextStyle(
                  fontSize: 13,
                  color: nivel == 0 ? scheme.onSurfaceVariant : texto,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertaTile extends StatelessWidget {
  const _AlertaTile({
    required this.texto,
    required this.marcada,
    required this.onChanged,
  });

  final String texto;
  final bool marcada;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onChanged(!marcada),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Checkbox(
                value: marcada,
                activeColor: _green,
                onChanged: (v) => onChanged(v ?? false),
              ),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(fontSize: 14, height: 1.25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
