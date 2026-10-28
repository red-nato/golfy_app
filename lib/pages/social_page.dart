import 'package:flutter/material.dart';

import '../perfil.dart';

const _green = Color(0xFF14573A);

// Estado del semáforo: 0 = óptimo, 1 = atención, 2 = reposo.
const _etiquetas = ['Óptimo', 'Atención', 'Reposo'];
const _puntos = [Color(0xFF3FA66B), Color(0xFFF2C14E), Color(0xFFB3261E)];
const _fondos = [Color(0xFFCDEBD8), Color(0xFFF2C14E), Color(0xFFB3261E)];
const _textos = [Color(0xFF0E4A2E), Color(0xFF112017), Color(0xFFFFFFFF)];

class _Miembro {
  const _Miembro(
    this.ini,
    this.nombre,
    this.lugar,
    this.estado, {
    this.enCancha = false,
    this.enMapa = Alignment.center,
  });

  final String ini;
  final String nombre;
  final String lugar;
  final int estado;
  final bool enCancha;
  final Alignment enMapa; // posición en el mapa (solo si está en cancha)
}

// Tus amigos del grupo. "Tú" se arma aparte porque depende de tus ajustes.
const _amigos = [
  _Miembro(
    'CS',
    'Camila S.',
    'En el campo · hoyo 7',
    0,
    enCancha: true,
    enMapa: Alignment(-0.55, -0.25),
  ),
  _Miembro(
    'JL',
    'Joaquín L.',
    'En el campo · hoyo 7',
    0,
    enCancha: true,
    enMapa: Alignment(-0.4, -0.05),
  ),
  _Miembro(
    'SM',
    'Sofía M.',
    'En el rango de práctica',
    0,
    enCancha: true,
    enMapa: Alignment(0.6, 0.45),
  ),
  _Miembro('DF', 'Diego F.', 'Ubicación no compartida', 1),
  _Miembro('IP', 'Ignacia P.', 'Salió del club hace 40 min', 1),
  _Miembro('TV', 'Tomás V.', 'Ubicación no compartida', 2),
];

const _filtros = ['Todos', 'En cancha', 'Atención'];

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  int _filtro = 0;

  // Lo que tú decides compartir con el grupo.
  bool _compartirEstado = true;
  bool _compartirUbicacion = true;
  bool _compartirCarga = false;

  // Tú, con tu ubicación solo si decides compartirla.
  _Miembro get _yo => _Miembro(
    perfilNotifier.value.iniciales,
    '${perfilNotifier.value.nombre} (tú)',
    _compartirUbicacion ? 'En el rango de práctica' : 'Ubicación oculta',
    1,
    enCancha: _compartirUbicacion,
    enMapa: const Alignment(0.05, -0.55),
  );

  List<_Miembro> get _todos => [_yo, ..._amigos];

  List<_Miembro> get _visibles {
    return _todos.where((m) {
      if (_filtro == 1) return m.enCancha;
      if (_filtro == 2) return m.estado == 1;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final todos = _todos;
    final visibles = _visibles;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mi grupo',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Golf universitario · ${todos.length} jugadores · hoy',
              style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            _Mapa(miembros: todos.where((m) => m.enCancha).toList()),
            const SizedBox(height: 12),
            // Resumen del semáforo del grupo
            Row(
              children: [
                for (var e = 0; e < 3; e++) ...[
                  if (e > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _Resumen(
                      estado: e,
                      cantidad: todos.where((m) => m.estado == e).length,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Filtros
            Row(
              children: [
                for (var i = 0; i < _filtros.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _filtro = i),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == _filtro ? _green : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: i == _filtro
                            ? null
                            : Border.all(color: scheme.outline),
                      ),
                      child: Text(
                        _filtros[i],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: i == _filtro
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: i == _filtro ? Colors.white : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Lista de jugadores
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: visibles.isEmpty
                  ? const SizedBox(
                      height: 60,
                      child: Center(child: Text('Nadie por aquí todavía')),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < visibles.length; i++) ...[
                          if (i > 0)
                            Divider(height: 1, color: scheme.outlineVariant),
                          _FilaMiembro(miembro: visibles[i]),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              'LO QUE COMPARTES',
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
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                children: [
                  _Opcion(
                    titulo: 'Mi semáforo',
                    detalle: 'Tu estado de hoy, sin los motivos',
                    valor: _compartirEstado,
                    onChanged: (v) => setState(() => _compartirEstado = v),
                  ),
                  Divider(height: 1, color: scheme.outlineVariant),
                  _Opcion(
                    titulo: 'Ubicación en vivo',
                    detalle: 'Solo mientras estás en el club',
                    valor: _compartirUbicacion,
                    onChanged: (v) => setState(() => _compartirUbicacion = v),
                  ),
                  Divider(height: 1, color: scheme.outlineVariant),
                  _Opcion(
                    titulo: 'Rondas y carga semanal',
                    detalle: 'Tus sesiones y tus UA',
                    valor: _compartirCarga,
                    onChanged: (v) => setState(() => _compartirCarga = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tú decides qué compartes y puedes pausarlo cuando quieras. '
              'Los motivos de tu semáforo solo los ve tu entrenador. '
              'Entrenador: aún no hay uno vinculado.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mapa simple del club con los jugadores que están en cancha.
class _Mapa extends StatelessWidget {
  const _Mapa({required this.miembros});

  final List<_Miembro> miembros;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fondo = isDark ? const Color(0xFF1F3A2C) : const Color(0xFFDCEBDD);
    final calle = isDark ? const Color(0xFF2B4D3B) : const Color(0xFFC3DBC7);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        width: double.infinity,
        color: fondo,
        child: Stack(
          children: [
            // Calles del campo (decoración)
            Align(
              alignment: const Alignment(-0.3, -0.1),
              child: Container(
                width: 240,
                height: 56,
                decoration: BoxDecoration(
                  color: calle,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.7, 0.55),
              child: Container(
                width: 110,
                height: 50,
                decoration: BoxDecoration(
                  color: calle,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            // Jugadores
            for (final m in miembros)
              Align(
                alignment: m.enMapa,
                child: _Pin(ini: m.ini, color: _puntos[m.estado]),
              ),
            Positioned(
              left: 12,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${miembros.length} en el club · en vivo',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _Pin extends StatelessWidget {
  const _Pin({required this.ini, required this.color});

  final String ini;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: color, width: 3),
      ),
      child: Text(
        ini,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF112017),
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.estado, required this.cantidad});

  final int estado;
  final int cantidad;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$cantidad',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _puntos[estado],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _etiquetas[estado],
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaMiembro extends StatelessWidget {
  const _FilaMiembro({required this.miembro});

  final _Miembro miembro;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 64,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              miembro.ini,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  miembro.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    if (miembro.enCancha) ...[
                      Icon(Icons.location_on, size: 14, color: scheme.primary),
                      const SizedBox(width: 2),
                    ],
                    Expanded(
                      child: Text(
                        miembro.lugar,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _fondos[miembro.estado],
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _textos[miembro.estado],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _etiquetas[miembro.estado],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textos[miembro.estado],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.titulo,
    required this.detalle,
    required this.valor,
    required this.onChanged,
  });

  final String titulo;
  final String detalle;
  final bool valor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 64,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
          Switch(value: valor, activeTrackColor: _green, onChanged: onChanged),
        ],
      ),
    );
  }
}
