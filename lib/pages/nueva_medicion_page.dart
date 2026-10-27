import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medicion.dart';
import '../providers/mediciones_provider.dart';

const _green = Color(0xFF14573A);

const _meses = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

class NuevaMedicionPage extends StatefulWidget {
  // Sin medición: crea una nueva. Con medición: edita esa.
  const NuevaMedicionPage({super.key, this.medicion});

  final Medicion? medicion;

  @override
  State<NuevaMedicionPage> createState() => _NuevaMedicionPageState();
}

class _NuevaMedicionPageState extends State<NuevaMedicionPage> {
  final _formKey = GlobalKey<FormState>();
  final _fechaCtrl = TextEditingController();
  late final TextEditingController _peso;
  late final TextEditingController _estatura;
  late final TextEditingController _pulso;

  late DateTime _fecha;
  bool _guardando = false;

  bool get _editando => widget.medicion != null;

  @override
  void initState() {
    super.initState();
    // Si viene una medición, los campos parten con sus datos; si no, vacíos.
    final m = widget.medicion;
    _fecha = m?.fecha ?? DateTime.now();
    _fechaCtrl.text = _fechaTexto(_fecha);
    _peso = TextEditingController(text: m == null ? '' : _decimal(m.peso));
    _estatura = TextEditingController(
      text: m == null ? '' : _decimal(m.estatura),
    );
    _pulso = TextEditingController(text: m?.pulso?.toString() ?? '');
  }

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _peso.dispose();
    _estatura.dispose();
    _pulso.dispose();
    super.dispose();
  }

  // Acepta coma o punto decimal: "78,4" -> 78.4
  double? _numero(String texto) {
    return double.tryParse(texto.trim().replaceAll(',', '.'));
  }

  // 78.4 -> "78,4" y 78.0 -> "78", para mostrar al editar.
  String _decimal(double n) {
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toString().replaceAll('.', ',');
  }

  String _fechaTexto(DateTime f) {
    final hoy = DateTime.now();
    final esHoy =
        f.year == hoy.year && f.month == hoy.month && f.day == hoy.day;
    final texto = '${f.day} ${_meses[f.month - 1]} ${f.year}';
    return esHoy ? 'Hoy · $texto' : texto;
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

  // Los mismos rangos que los `check` de la tabla en Supabase.
  String? _validarPeso(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe tu peso';
    final n = _numero(texto);
    if (n == null) return 'Solo números, por ejemplo 78,4';
    if (n < 20 || n > 300) return 'Entre 20 y 300 kg';
    return null;
  }

  String? _validarEstatura(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe tu estatura';
    final n = _numero(texto);
    if (n == null) return 'Solo números, por ejemplo 1,79';
    if (n > 3) return 'En metros, por ejemplo 1,79';
    if (n < 1 || n > 2.5) return 'Entre 1 y 2,5 m';
    return null;
  }

  String? _validarPulso(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return null; // el pulso es opcional
    final n = int.tryParse(texto);
    if (n == null) return 'Solo números enteros';
    if (n < 30 || n > 220) return 'Entre 30 y 220';
    return null;
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // no se registran mediciones del futuro
    );
    if (elegida == null) return; // cerró el calendario sin elegir
    setState(() {
      _fecha = elegida;
      _fechaCtrl.text = _fechaTexto(elegida);
    });
  }

  Future<void> _guardar() async {
    // Corre los tres validator; si alguno falla, muestra el error y no sigue.
    if (!_formKey.currentState!.validate()) return;

    final pulsoTexto = _pulso.text.trim();
    final medicion = Medicion(
      id: widget.medicion?.id, // null al crear; el id original al editar
      fecha: _fecha,
      peso: _numero(_peso.text)!,
      estatura: _numero(_estatura.text)!,
      pulso: pulsoTexto.isEmpty ? null : int.parse(pulsoTexto),
    );

    setState(() => _guardando = true);
    final error = await context.read<MedicionesProvider>().guardar(medicion);
    if (!mounted) return;
    setState(() => _guardando = false);

    final messenger = ScaffoldMessenger.of(context);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(_editando ? 'Medición actualizada' : 'Medición guardada'),
      ),
    );
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _editando ? 'Editar medición' : 'Nueva medición',
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
              _Campo(
                label: 'Fecha',
                controller: _fechaCtrl,
                soloLectura: true,
                onTap: _elegirFecha,
              ),
              const SizedBox(height: 14),
              _Campo(
                label: 'Peso (kg)',
                controller: _peso,
                hint: '78,4',
                validator: _validarPeso,
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
                      hint: '1,79',
                      validator: _validarEstatura,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Campo(
                      label: 'Pulso reposo (lpm)',
                      controller: _pulso,
                      hint: 'Opcional',
                      validator: _validarPulso,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
                  // null deshabilita el botón mientras se guarda.
                  onTap: _guardando ? null : _guardar,
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    child: _guardando
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onInverseSurface,
                            ),
                          )
                        : Text(
                            _editando ? 'Guardar cambios' : 'Guardar medición',
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
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  const _Campo({
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.onChanged,
    this.onTap,
    this.soloLectura = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onChanged;
  final VoidCallback? onTap;
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
        TextFormField(
          controller: controller,
          readOnly: soloLectura,
          onTap: onTap,
          validator: validator,
          onChanged: (_) => onChanged?.call(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: soloLectura
                ? const Icon(Icons.calendar_today_outlined, size: 20)
                : null,
            enabledBorder: borde(scheme.outline, 1),
            focusedBorder: borde(_green, 2),
            errorBorder: borde(scheme.error, 1),
            focusedErrorBorder: borde(scheme.error, 2),
          ),
        ),
      ],
    );
  }
}