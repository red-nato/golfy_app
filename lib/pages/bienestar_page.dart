import 'package:flutter/material.dart';
import 'bienestar_hoy_page.dart';
import 'hidratacion_page.dart';

const _green = Color(0xFF14573A);
const _mint = Color(0xFFCFE3D4);

// Pestaña Bienestar: junta el resumen del día (cómo estás + cuánta agua llevas)
// y los accesos a registrar bienestar y al plan de hidratación.
class BienestarPage extends StatelessWidget {
  const BienestarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienestar',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cómo estás hoy y cuánta agua te falta.',
            style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          const _ResumenCard(),
          const SizedBox(height: 18),
          Text(
            'Registrar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _Acceso(
            icono: Icons.favorite_border,
            titulo: 'Bienestar de hoy',
            detalle: 'Sueño, fatiga, dolor y agua · 1 min',
            destino: const BienestarHoyPage(),
          ),
          const SizedBox(height: 10),
          _Acceso(
            icono: Icons.water_drop_outlined,
            titulo: 'Plan de hidratación',
            detalle: 'Sábado · lleva 2,6 L para la ronda',
            destino: const HidratacionPage(),
          ),
        ],
      ),
    );
  }
}

// Tarjeta verde que junta bienestar e hidratación en un solo vistazo.
class _ResumenCard extends StatelessWidget {
  const _ResumenCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESUMEN DE HOY',
            style: TextStyle(fontSize: 12, letterSpacing: 1, color: _mint),
          ),
          const Text(
            'Faltan 1,4 L de agua',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Dormiste 7,5 h, con fatiga 3 de 5 y dolor muscular 2 de 5. '
            'Termina tu agua antes de la ronda del sábado.',
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Color(0xFFEAF3EC),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: _Dato('Sueño', '7,5 h')),
              Expanded(child: _Dato('Fatiga', '3 / 5')),
              Expanded(child: _Dato('Dolor', '2 / 5')),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Agua de hoy', style: TextStyle(fontSize: 12, color: _mint)),
              Text(
                '1,2 L de 2,6 L',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 1.2 / 2.6,
              minHeight: 10,
              color: Color(0xFF7DB8E0),
              backgroundColor: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.label, this.valor);

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _mint)),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Fila grande que abre otra pantalla.
class _Acceso extends StatelessWidget {
  const _Acceso({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.destino,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final Widget destino;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destino),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: scheme.primaryContainer,
                child: Icon(icono, size: 22, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      detalle,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
