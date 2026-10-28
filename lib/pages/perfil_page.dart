import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carga_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mediciones_provider.dart';
import '../perfil.dart';
import '../widgets/golf_identity.dart';

const _green = Color(0xFF14573A);
String _miles(int numero) {
  final texto = numero.toString();

  if (texto.length <= 3) return texto;

  return '${texto.substring(0, texto.length - 3)}.'
      '${texto.substring(texto.length - 3)}';
}

String _fechaSesion(DateTime fecha) {
  const dias = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  return '${dias[fecha.weekday - 1]} ${fecha.day}/${fecha.month}';
}

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool _recordatorio = true;

  // Abre el popup y, si el jugador guarda, actualiza el perfil de toda la app.
  Future<void> _editar(Perfil actual) async {
    final auth = context.read<AuthProvider>();
    final nuevo = await showDialog<Perfil>(
      context: context,
      builder: (_) => _EditarPerfilDialog(perfil: actual),
    );
    if (nuevo != null) {
      final error = await auth.actualizarPerfil(nuevo);
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      perfilNotifier.value = nuevo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<Perfil>(
      valueListenable: perfilNotifier,
      builder: (context, p, _) {
        final mediciones = context.watch<MedicionesProvider>();
        final carga = context.watch<CargaProvider>();

        final ultimaMedicion = mediciones.ultima;
        final ultimaSesion = carga.ultima;

        final peso = ultimaMedicion?.peso ?? p.peso;
        final estatura = ultimaMedicion?.estatura ?? p.estatura;
        final imc = ultimaMedicion?.imc ?? p.imc;
        final pulso = ultimaMedicion?.pulso;

        final actividadSemana = carga.estaSemana.isEmpty
            ? 'Sin sesiones esta semana'
            : '${carga.estaSemana.length} '
                  '${carga.estaSemana.length == 1 ? 'sesión' : 'sesiones'} · '
                  '${_miles(carga.cargaSemana)} UA';

        final ultimaSesionTexto = ultimaSesion == null
            ? 'Aún no registras sesiones'
            : '${ultimaSesion.tipoNombre} · '
                  '${_fechaSesion(ultimaSesion.fecha)} · '
                  '${ultimaSesion.minutos} min · '
                  '${ultimaSesion.carga} UA';

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GolfHeading(
                title: 'Tu ficha de jugador',
                subtitle: 'Tu identidad, dentro y fuera del campo.',
                icon: Icons.golf_course_rounded,
                hole: '05 / PERFIL',
              ),
              const SizedBox(height: 16),
              _JugadorCard(perfil: p, onEditar: () => _editar(p)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _Dato(
                      label: 'Peso',
                      valor: coma(peso),
                      unidad: 'kg',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Dato(
                      label: 'Estatura',
                      valor: coma(estatura, 2),
                      unidad: 'm',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _Dato(label: 'IMC', valor: coma(imc)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Dato(
                      label: 'Pulso en reposo',
                      valor: pulso == null ? '—' : '$pulso',
                      unidad: pulso == null ? '' : 'lpm',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _Fila('Hándicap', coma(p.handicap)),
                    Divider(height: 1, color: scheme.outlineVariant),
                    _Fila(
                      'Mano dominante',
                      p.manoDerecha ? 'Derecha' : 'Izquierda',
                    ),
                    Divider(height: 1, color: scheme.outlineVariant),
                    _Fila('Actividad esta semana', actividadSemana),
                    Divider(height: 1, color: scheme.outlineVariant),
                    _Fila('Última sesión', ultimaSesionTexto),
                    Divider(height: 1, color: scheme.outlineVariant),
                    SizedBox(
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Recordatorio diario · 20:00',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Switch(
                            value: _recordatorio,
                            activeTrackColor: _green,
                            onChanged: (v) {
                              setState(() => _recordatorio = v);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Solo tú ves tus mediciones. Tu entrenador ve el semáforo de su '
                'plantel. Esta app es una herramienta de apoyo y registro, no '
                'entrega diagnósticos.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _JugadorCard extends StatelessWidget {
  const _JugadorCard({required this.perfil, required this.onEditar});

  final Perfil perfil;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Badge(
            backgroundColor: scheme.primary,
            label: const Icon(
              Icons.sports_golf_rounded,
              size: 13,
              color: Colors.white,
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                perfil.iniciales,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  perfil.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${perfil.edad} años · Golf universitario',
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onEditar,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              foregroundColor: scheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Editar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// Popup para editar los datos básicos. Devuelve el Perfil nuevo al guardar.
class _EditarPerfilDialog extends StatefulWidget {
  const _EditarPerfilDialog({required this.perfil});

  final Perfil perfil;

  @override
  State<_EditarPerfilDialog> createState() => _EditarPerfilDialogState();
}

class _EditarPerfilDialogState extends State<_EditarPerfilDialog> {
  late final _nombre = TextEditingController(text: widget.perfil.nombre);
  late final _edad = TextEditingController(text: '${widget.perfil.edad}');
  late final _handicap = TextEditingController(
    text: coma(widget.perfil.handicap),
  );
  late bool _derecha = widget.perfil.manoDerecha;

  // Mensajes de error (null = el dato está bien).
  String? _eNombre, _eEdad, _eHandicap;

  @override
  void dispose() {
    _nombre.dispose();
    _edad.dispose();
    _handicap.dispose();
    super.dispose();
  }

  // Acepta coma o punto decimal.
  double? _numero(String t) => double.tryParse(t.trim().replaceAll(',', '.'));

  void _guardar() {
    final nombre = _nombre.text.trim();
    final edad = int.tryParse(_edad.text.trim());
    final handicap = _numero(_handicap.text);

    setState(() {
      _eNombre = nombre.isEmpty ? 'Escribe tu nombre' : null;
      _eEdad = (edad == null || edad < 10 || edad > 99) ? '10 a 99' : null;
      _eHandicap = (handicap == null || handicap < -5 || handicap > 54)
          ? '−5 a 54'
          : null;
    });

    final hayError = [_eNombre, _eEdad, _eHandicap].any((e) => e != null);
    if (hayError) return;

    Navigator.pop(
      context,
      Perfil(
        nombre: nombre,
        edad: edad!,
        peso: widget.perfil.peso,
        estatura: widget.perfil.estatura,
        handicap: handicap!,
        manoDerecha: _derecha,
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController controller,
    String? error, {
    bool numerico = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: numerico
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : TextInputType.name,
      textCapitalization: numerico
          ? TextCapitalization.none
          : TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar perfil'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              _campo('Nombre', _nombre, _eNombre, numerico: false),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _campo('Edad', _edad, _eEdad)),
                  const SizedBox(width: 12),
                  Expanded(child: _campo('Hándicap', _handicap, _eHandicap)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Mano dominante',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('Izquierda')),
                    ButtonSegment(value: true, label: Text('Derecha')),
                  ],
                  selected: {_derecha},
                  onSelectionChanged: (s) => setState(() => _derecha = s.first),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}

// Tarjeta chica con un dato (peso, estatura, IMC, pulso).
class _Dato extends StatelessWidget {
  const _Dato({required this.label, required this.valor, this.unidad = ''});

  final String label;
  final String valor;
  final String unidad;

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
        onTap: () {}, // luego: ir a Mediciones
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  text: valor,
                  children: [
                    if (unidad.isNotEmpty)
                      TextSpan(
                        text: ' $unidad',
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
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(this.label, this.valor);

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
