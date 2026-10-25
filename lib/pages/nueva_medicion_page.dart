import 'package:flutter/material.dart';

const _green = Color(0xFF14573A);

class NuevaMedicionPage extends StatefulWidget {
  const NuevaMedicionPage({super.key});

  @override
  State<NuevaMedicionPage> createState() => _NuevaMedicionPageState();
}

class _NuevaMedicionPageState extends State<NuevaMedicionPage> {
  final _fecha = TextEditingController(text: 'Hoy · 8 oct 2026');
  final _peso = TextEditingController(text: '78,4');
  final _estatura = TextEditingController(text: '1,79');
  final _pulso = TextEditingController(text: '58');

  @override
  void dispose() {
    _fecha.dispose();
    _peso.dispose();
    _estatura.dispose();
    _pulso.dispose();
    super.dispose();
  }

  // Acepta coma o punto decimal: "78,4" -> 78.4
  double? _numero(String texto) {
    return double.tryParse(texto.trim().replaceAll(',', '.'));
  }

  // IMC = peso / estatura². Si falta algún dato, devuelve null.
  double? get _imc {
    final peso = _numero(_peso.text);
    final estatura = _numero(_estatura.text);
    if (peso == null || estatura == null || estatura <= 0) return null;
    return peso / (estatura * estatura);
  }

  String get _rango {
    final imc = _imc;
    if (imc == null) return 'Revisa los datos';
    if (imc < 18.5) return 'Bajo el rango normal';
    if (imc < 25) return 'Rango normal';
    return 'Sobre el rango normal';
  }

  void _guardar() {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Medición guardada')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final imc = _imc;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nueva medición',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tarda menos de un minuto. Mídete al despertar para comparar '
              'siempre en las mismas condiciones.',
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            _Campo(label: 'Fecha', controller: _fecha, soloLectura: true),
            const SizedBox(height: 14),
            _Campo(
              label: 'Peso (kg)',
              controller: _peso,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Campo(
                    label: 'Estatura (m)',
                    controller: _estatura,
                    onChanged: () => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Campo(
                    label: 'Pulso reposo (lpm)',
                    controller: _pulso,
                    onChanged: () => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? _green.withValues(alpha: 0.45)
                    : const Color(0xFFDCEBDD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IMC calculado',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF2F4A3B),
                        ),
                      ),
                      Text(
                        imc == null
                            ? '—'
                            : imc.toStringAsFixed(1).replaceAll('.', ','),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : _green,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _rango,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : _green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Material(
              color: scheme.inverseSurface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _guardar,
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  child: Text(
                    'Guardar medición',
                    style: TextStyle(
                      color: scheme.onInverseSurface,
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

class _Campo extends StatelessWidget {
  const _Campo({
    required this.label,
    required this.controller,
    this.onChanged,
    this.soloLectura = false,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback? onChanged;
  final bool soloLectura;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    OutlineInputBorder borde(Color color, double grosor) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: grosor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: soloLectura,
          onChanged: (_) => onChanged?.call(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: borde(scheme.outline, 1),
            focusedBorder: borde(_green, 2),
          ),
        ),
      ],
    );
  }
}
