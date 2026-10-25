import 'package:flutter/material.dart';

import '../perfil.dart';
import '../widgets/golf_identity.dart';
import '../widgets/clima_card.dart';
import '../theme.dart';
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
          const _CourseWelcome(),
          const SizedBox(height: 18),
          const _StatusCard(),
          const SizedBox(height: 18),
          Text(
            'Tu rutina fuera del green',
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
                  icon: Icons.sports_golf_rounded,
                  label: 'Chequeo post-ronda',
                  onTap: () => _abrir(context, const ChequeoPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _NextRoundCard(),
          const SizedBox(height: 14),
          const ClimaCard(resumen: true),
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
                    'UN BUEN DÍA PARA JUGAR',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
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

class _CourseWelcome extends StatelessWidget {
  const _CourseWelcome();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF103D2B), Color(0xFF1C563B)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const copy = Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.sports_golf_rounded, size: 17, color: golfLime),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'CADA DÍA, UN MEJOR JUEGO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: golfLime,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Text(
                  'Tu mejor ronda\nempieza contigo.',
                  style: TextStyle(
                    fontSize: 32,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Cuida tu cuerpo. Encuentra tu ritmo.\nDisfruta el recorrido.',
                  style: TextStyle(color: _mint, height: 1.5, fontSize: 14),
                ),
                SizedBox(height: 16),
              ],
            ),
          );
          if (constraints.maxWidth >= 580) {
            return const Row(
              children: [
                Expanded(child: copy),
                Expanded(child: SizedBox(height: 230, child: FairwayScene())),
              ],
            );
          }
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              copy,
              SizedBox(height: 158, child: FairwayScene()),
            ],
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF26352B)
            : const Color(0xFFEAF0DF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, color: scheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTADO HOY',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Atención',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: dark
                            ? const Color(0xFFF4CB6C)
                            : const Color(0xFF93600B),
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const _Semaforo(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tu carga de esta semana va 38 % sobre tu promedio. '
            'Baja la intensidad en el rango antes de la ronda del sábado.',
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: Theme.of(context).colorScheme.outlineVariant,
            height: 1,
          ),
          const SizedBox(height: 14),
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
      width: 12,
      height: 12,
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
        color: Colors.black.withValues(alpha: 0.06),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
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
      color: scheme.primary,
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
              Icon(Icons.spa_rounded, color: scheme.onPrimary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Registrar cómo estoy · 1 min',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: scheme.onPrimary),
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
              const SizedBox(height: 14),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Icon(Icons.north_east_rounded, size: 16, color: scheme.primary),
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
              Icon(
                Icons.golf_course_rounded,
                color: isDark ? _mint : _green,
                size: 30,
              ),
              const SizedBox(width: 12),
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
                      '18 hoyos · ver plan de agua',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: 'Ver plan de agua',
                child: Icon(
                  Icons.water_drop_outlined,
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
