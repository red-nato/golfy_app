import 'package:flutter/material.dart';
import 'hidratacion_page.dart';

const _green = Color(0xFF14573A);
const _blue = Color(0xFF2F7FB8);
const _metaAgua = 2.6; // litros

// Muestra un número con coma decimal: 7.5 -> "7,5".
String _coma(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

class BienestarHoyPage extends StatefulWidget {
  const BienestarHoyPage({super.key});

  @override
  State<BienestarHoyPage> createState() => _BienestarHoyPageState();
}

class _BienestarHoyPageState extends State<BienestarHoyPage> {
  double _sueno = 7.5;
  int _fatiga = 3;
  int _dolor = 2;
  double _agua = 1.2;

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
            'Bienestar de hoy',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cuatro respuestas, menos de un minuto.',
            style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              children: [
                // 1. Sueño
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Horas de sueño',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          _BotonRedondo(
                            icono: Icons.remove,
                            onTap: () => setState(
                              () => _sueno = (_sueno - 0.5).clamp(0.0, 14.0).toDouble(),
                            ),
                          ),
                          SizedBox(
                            width: 64,
                            child: Text(
                              '${_coma(_sueno)} h',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _BotonRedondo(
                            icono: Icons.add,
                            onTap: () => setState(
                              () => _sueno = (_sueno + 0.5).clamp(0.0, 14.0).toDouble(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                // 2. Fatiga
                _Escala(
                  titulo: 'Fatiga',
                  ayuda: '1 fresco · 5 agotado',
                  valor: _fatiga,
                  onChanged: (n) => setState(() => _fatiga = n),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                // 3. Dolor muscular
                _Escala(
                  titulo: 'Dolor muscular',
                  ayuda: '1 nada · 5 mucho',
                  valor: _dolor,
                  onChanged: (n) => setState(() => _dolor = n),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                // 4. Agua
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Agua de hoy',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${_coma(_agua)} L',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                TextSpan(text: ' de ${_coma(_metaAgua)} L'),
                              ],
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (_agua / _metaAgua).clamp(0.0, 1.0).toDouble(),
                          minHeight: 10,
                          color: _blue,
                          backgroundColor: scheme.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _BotonAgua(
                              texto: '+ 250 ml',
                              onTap: () => setState(() => _agua += 0.25),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _BotonAgua(
                              texto: '+ 500 ml',
                              onTap: () => setState(() => _agua += 0.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Material(
                              color: theme.brightness == Brightness.dark
                                  ? _green.withValues(alpha: 0.5)
                                  : const Color(0xFFDCEBDD),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HidratacionPage(),
                                  ),
                                ),
                                child: Container(
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Ver plan',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : _green,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Material(
            color: scheme.inverseSurface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bienestar guardado')),
                );
              },
              child: Container(
                height: 54,
                alignment: Alignment.center,
                child: Text(
                  'Guardar bienestar',
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
    ));
  }
}

// Pregunta con escala del 1 al 5 (fatiga, dolor muscular).
class _Escala extends StatelessWidget {
  const _Escala({
    required this.titulo,
    required this.ayuda,
    required this.valor,
    required this.onChanged,
  });

  final String titulo;
  final String ayuda;
  final int valor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ayuda,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var n = 1; n <= 5; n++) ...[
                if (n > 1) const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(n),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: n == valor ? _green : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: n == valor
                            ? null
                            : Border.all(color: scheme.outline),
                      ),
                      child: Text(
                        '$n',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: n == valor
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: n == valor ? Colors.white : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonAgua extends StatelessWidget {
  const _BotonAgua({required this.texto, required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _BotonRedondo extends StatelessWidget {
  const _BotonRedondo({required this.icono, required this.onTap});

  final IconData icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outline),
        ),
        child: Icon(icono, size: 22),
      ),
    );
  }
}
