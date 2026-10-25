import 'package:flutter/material.dart';
import '../perfil.dart';
import 'bitacora_page.dart';
import 'chequeo_page.dart';
import 'hidratacion_page.dart';
import 'social_page.dart';

const _green = Color(0xFF14573A);
const _mint = Color(0xFFCFE3D4);

// Abre otra pantalla encima de Inicio (la flecha de volver viene sola).
void _abrir(BuildContext context, Widget pantalla) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key, required this.onPerfil});

  // Cambia a la pestaña Perfil (la define GolfyMain).
  final VoidCallback onPerfil;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(onPerfil: onPerfil),
          const SizedBox(height: 18),
          const _StatusCard(),
          const SizedBox(height: 18),
          Text(
            'Registro de hoy',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const _PrimaryAction(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.groups_outlined,
                  label: 'Mi grupo',
                  onTap: () => _abrir(context, const SocialPage()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionCard(
                  icon: Icons.fact_check_outlined,
                  label: 'Chequeo post-ronda',
                  onTap: () => _abrir(context, const ChequeoPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _NextRoundCard(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onPerfil});

  final VoidCallback onPerfil;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Se actualiza solo cuando editas el perfil.
    return ValueListenableBuilder<Perfil>(
      valueListenable: perfilNotifier,
      builder: (context, perfil, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jueves 8 de octubre',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Hola, ${perfil.primerNombre}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Al tocar el avatar se abre la pestaña Perfil.
            Tooltip(
              message: 'Ir a mi perfil',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPerfil,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    perfil.iniciales,
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Semaforo(),
              SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESTADO HOY',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      color: _mint,
                    ),
                  ),
                  Text(
                    'Atención',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Tu carga de esta semana va 38 % sobre tu promedio. '
            'Baja la intensidad en el rango antes de la ronda del sábado.',
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Color(0xFFEAF3EC),
            ),
          ),
          SizedBox(height: 16),
          Divider(color: Colors.white24, height: 1),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _Stat('Carga semanal', '1.310 UA')),
              Expanded(child: _Stat('Bienestar', '7,2 / 10')),
              Expanded(child: _Stat('Molestias', '1 activa')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Semaforo extends StatelessWidget {
  const _Semaforo();

  Widget _dot(Color color, {bool active = false}) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color : color.withValues(alpha: 0.35),
        boxShadow: active
            ? [BoxShadow(color: color.withValues(alpha: 0.35), spreadRadius: 3)]
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(const Color(0xFF3FA66B)),
          _dot(const Color(0xFFF2C14E), active: true), // amarillo activo
          _dot(const Color(0xFFE5584F)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _mint)),
        const SizedBox(height: 2),
        Text(
          value,
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

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.inverseSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrir(context, const BitacoraPage()),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registrar cómo estoy · 1 min',
                style: TextStyle(
                  color: scheme.onInverseSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.arrow_forward, color: scheme.onInverseSurface),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: scheme.primaryContainer,
                child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
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

class _NextRoundCard extends StatelessWidget {
  const _NextRoundCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sand = isDark ? const Color(0xFF3A3524) : const Color(0xFFEFE8D2);

    return Material(
      color: sand,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrir(context, const HidratacionPage()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRÓXIMA RONDA · SÁBADO',
                      style: TextStyle(fontSize: 12, letterSpacing: 0.8),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '18 hoyos · 26 °C · UV alto',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Plan de agua',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? _mint : _green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}