import 'dart:math' show max;

import 'package:flutter/material.dart';

import '../widgets/golf_identity.dart';

const _green = Color(0xFF14573A);
const _mint = Color(0xFFCFE3D4);

const _tipos = ['Rango', 'Putting', 'Ronda', 'Gimnasio'];
const _dias = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];
const _letras = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
const _hoy = 3; // jueves
const _promedio = 949; // promedio semanal de las últimas 4 semanas (UA)

// Una sesión de entrenamiento. Carga = minutos × esfuerzo percibido (UA).
class _Sesion {
  const _Sesion(this.tipo, this.minutos, this.esfuerzo);

  final int tipo; // posición en _tipos
  final int minutos;
  final int esfuerzo;

  int get carga => minutos * esfuerzo;
}

// 1310 -> "1.310"
String _miles(int n) {
  final s = n.toString();
  if (s.length <= 3) return s;
  return '${s.substring(0, s.length - 3)}.${s.substring(s.length - 3)}';
}

class CargaPage extends StatefulWidget {
  const CargaPage({super.key});

  @override
  State<CargaPage> createState() => _CargaPageState();
}

class _CargaPageState extends State<CargaPage> {
  // Sesión registrada en cada día de la semana (null = nada registrado).
  final List<_Sesion?> _semana = [
    const _Sesion(0, 60, 6), // lunes · Rango · 360 UA
    const _Sesion(2, 90, 5), // martes · Ronda · 450 UA
    const _Sesion(3, 100, 5), // miércoles · Gimnasio · 500 UA
    null,
    null,
    null,
    null,
  ];

  // Valores del formulario.
  int _tipo = 0;
  int _minutos = 90;
  int _esfuerzo = 6;

  bool _abierto = false; // formulario desplegado
  int? _editando; // día que se está modificando (null = registrando hoy)

  int get _total => _semana.fold<int>(0, (suma, s) => suma + (s?.carga ?? 0));
  int get _cargaForm => _minutos * _esfuerzo;

  void _cambiarMinutos(int delta) {
    setState(() => _minutos = (_minutos + delta).clamp(10, 240).toInt());
  }

  void _guardar() {
    final dia = _editando ?? _hoy;
    setState(() {
      _semana[dia] = _Sesion(_tipo, _minutos, _esfuerzo);
      _editando = null;
      _abierto = false;
    });
  }

  void _cancelarEdicion() {
    setState(() {
      _editando = null;
      _abierto = false;
    });
  }

  // Tocar una barra: si hay sesión, ofrece modificar o eliminar.
  Future<void> _tocarBarra(int dia) async {
    final sesion = _semana[dia];

    if (sesion == null) {
      // Barra vacía de hoy: abre el formulario.
      if (dia == _hoy && _editando == null) setState(() => _abierto = true);
      return;
    }

    final accion = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => _OpcionesSesion(dia: _dias[dia], sesion: sesion),
    );
    if (!mounted || accion == null) return;

    if (accion == 'eliminar') {
      setState(() {
        _semana[dia] = null;
        if (_editando == dia) _editando = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sesión eliminada')));
    } else if (accion == 'modificar') {
      setState(() {
        _tipo = sesion.tipo;
        _minutos = sesion.minutos;
        _esfuerzo = sesion.esfuerzo;
        _editando = dia;
        _abierto = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesionHoy = _semana[_hoy];
    final registradaHoy = sesionHoy != null && _editando == null;
    // La barra "fantasma" de hoy solo se ve mientras abres el formulario.
    final previa = (_abierto && _editando == null && sesionHoy == null)
        ? _cargaForm
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GolfHeading(
            title: 'Encuentra tu ritmo',
            subtitle: 'Del rango al green, cada sesión cuenta.',
            icon: Icons.sports_golf_rounded,
            hole: '03 / CARGA',
          ),
          const SizedBox(height: 14),
          _SemanaCard(
            semana: _semana,
            total: _total,
            previa: previa,
            onTapBarra: _tocarBarra,
          ),
          const SizedBox(height: 14),
          _Alerta(total: _total),
          const SizedBox(height: 14),
          if (registradaHoy)
            _TarjetaRegistrada(sesion: sesionHoy)
          else
            _tarjetaFormulario(context),
        ],
      ),
    );
  }

  // Tarjeta desplegable "Registrar sesión".
  Widget _tarjetaFormulario(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final editando = _editando;

    return Material(
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado: al tocarlo se despliega o se pliega.
          InkWell(
            onTap: editando != null
                ? null
                : () => setState(() => _abierto = !_abierto),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          editando != null
                              ? 'Modificar sesión · ${_dias[editando]}'
                              : 'Registrar sesión de hoy',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!_abierto)
                          Text(
                            'Toca para abrir el formulario',
                            style: TextStyle(
                              fontSize: 13,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (editando == null)
                    AnimatedRotation(
                      turns: _abierto ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.expand_more),
                    ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _abierto
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _campos(context),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  // Los campos del formulario (tipo, duración, esfuerzo y guardar).
  Widget _campos(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final editando = _editando != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tipo de sesión
        Row(
          children: [
            for (var i = 0; i < _tipos.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: _Opcion(
                  texto: _tipos[i],
                  activa: i == _tipo,
                  onTap: () => setState(() => _tipo = i),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        // Duración
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Duración',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                _BotonRedondo(
                  icono: Icons.remove,
                  onTap: () => _cambiarMinutos(-10),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '$_minutos min',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _BotonRedondo(
                  icono: Icons.add,
                  onTap: () => _cambiarMinutos(10),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Esfuerzo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Esfuerzo percibido',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            Text(
              '1 muy suave · 10 máximo',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _FilaEsfuerzo(
          numeros: const [1, 2, 3, 4, 5],
          seleccionado: _esfuerzo,
          onChanged: (n) => setState(() => _esfuerzo = n),
        ),
        const SizedBox(height: 6),
        _FilaEsfuerzo(
          numeros: const [6, 7, 8, 9, 10],
          seleccionado: _esfuerzo,
          onChanged: (n) => setState(() => _esfuerzo = n),
        ),
        const SizedBox(height: 14),
        // Guardar
        Material(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _guardar,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              child: Text(
                '${editando ? 'Guardar cambios' : 'Guardar'} · '
                '$_minutos min × $_esfuerzo = $_cargaForm UA',
                style: TextStyle(
                  color: scheme.onInverseSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        if (editando)
          Center(
            child: TextButton(
              onPressed: _cancelarEdicion,
              child: const Text('Cancelar'),
            ),
          ),
      ],
    );
  }
}

// Gráfico de la semana: una barra por día. Se pueden tocar.
class _SemanaCard extends StatelessWidget {
  const _SemanaCard({
    required this.semana,
    required this.total,
    required this.previa,
    required this.onTapBarra,
  });

  final List<_Sesion?> semana;
  final int total;
  final int? previa; // carga del formulario, para la barra fantasma de hoy
  final ValueChanged<int> onTapBarra;

  static const _alturaMax = 80.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // La barra más alta define la escala (mínimo 500 UA).
    final mayor = semana.fold<int>(0, (m, s) => max(m, s?.carga ?? 0));
    final tope = max(500, max(mayor, previa ?? 0)).toDouble();
    final hayAlguna = semana.any((s) => s != null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(
                'Esta semana',
                style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              ),
              Text.rich(
                TextSpan(
                  text: '${_miles(total)} ',
                  children: [
                    TextSpan(
                      text: 'UA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: _alturaMax + 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTapBarra(i),
                      child: _columna(context, i, tope),
                    ),
                  ),
              ],
            ),
          ),
          if (hayAlguna)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Toca una barra para modificar o eliminar la sesión',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  // Barra llena si hay sesión, con borde si es la vista previa de hoy.
  Widget _columna(BuildContext context, int i, double tope) {
    final scheme = Theme.of(context).colorScheme;
    final sesion = semana[i];
    final esHoy = i == _hoy;

    Widget barra = const SizedBox(width: 30, height: 0);
    if (sesion != null) {
      barra = Container(
        width: 30,
        height: sesion.carga / tope * _alturaMax,
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    } else if (esHoy && previa != null) {
      barra = Container(
        width: 30,
        height: (previa! / tope * _alturaMax).clamp(8.0, _alturaMax).toDouble(),
        decoration: BoxDecoration(
          border: Border.all(color: _green, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        barra,
        const SizedBox(height: 6),
        Text(
          _letras[i],
          style: TextStyle(
            fontSize: 12,
            fontWeight: esHoy ? FontWeight.w700 : FontWeight.w400,
            color: esHoy ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// Aviso según qué tan sobre tu promedio de 4 semanas vas.
class _Alerta extends StatelessWidget {
  const _Alerta({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pct = ((total / _promedio - 1) * 100).round();
    final sobrecarga = pct >= 20;

    // Colores propios (amarillo de alerta), iguales en claro y oscuro.
    const texto = Color(0xFF3B2E05);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: sobrecarga
            ? const Color(0xFFF6E2A6)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            sobrecarga
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            color: sobrecarga ? texto : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: sobrecarga
                ? Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Alerta de sobrecarga. ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text:
                              'Vas $pct % sobre tu promedio de 4 semanas. '
                              'Considera una sesión liviana hoy.',
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: texto,
                    ),
                  )
                : Text(
                    'Tu carga de la semana va dentro de tu promedio de 4 '
                    'semanas.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Reemplaza al formulario cuando ya registraste la sesión de hoy: verde y
// sin desplegar. Para cambiarla, toca la barra del jueves.
class _TarjetaRegistrada extends StatelessWidget {
  const _TarjetaRegistrada({required this.sesion});

  final _Sesion sesion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sesión de hoy registrada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_tipos[sesion.tipo]} · ${sesion.minutos} min × '
                  '${sesion.esfuerzo} = ${sesion.carga} UA',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFEAF3EC),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Toca la barra del jueves para modificarla o eliminarla.',
                  style: TextStyle(fontSize: 12, color: _mint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Menú que sale al tocar una barra. Devuelve 'modificar' o 'eliminar'.
class _OpcionesSesion extends StatelessWidget {
  const _OpcionesSesion({required this.dia, required this.sesion});

  final String dia;
  final _Sesion sesion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$dia · ${_tipos[sesion.tipo]}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              '${sesion.minutos} min × ${sesion.esfuerzo} = ${sesion.carga} UA',
              style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context, 'modificar'),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Modificar sesión'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, 'eliminar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  side: BorderSide(color: scheme.error),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Botón de opción (tipo de sesión, esfuerzo): verde si está activa.
class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.texto,
    required this.activa,
    required this.onTap,
  });

  final String texto;
  final bool activa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: activa ? _green : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: activa ? null : Border.all(color: scheme.outline),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 14,
            fontWeight: activa ? FontWeight.w600 : FontWeight.w500,
            color: activa ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}

class _FilaEsfuerzo extends StatelessWidget {
  const _FilaEsfuerzo({
    required this.numeros,
    required this.seleccionado,
    required this.onChanged,
  });

  final List<int> numeros;
  final int seleccionado;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < numeros.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: _Opcion(
              texto: '${numeros[i]}',
              activa: numeros[i] == seleccionado,
              onTap: () => onChanged(numeros[i]),
            ),
          ),
        ],
      ],
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
