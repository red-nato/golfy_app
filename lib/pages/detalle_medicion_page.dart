import 'package:flutter/material.dart';

import '../models/medicion.dart';
import '../widgets/insignia_medicion.dart';
import 'nueva_medicion_page.dart';

// El detalle de una medición. La recibe por su constructor desde el historial.
class DetalleMedicionPage extends StatefulWidget {
  const DetalleMedicionPage({super.key, required this.medicion});

  final Medicion medicion;

  @override
  State<DetalleMedicionPage> createState() => _DetalleMedicionPageState();
}

class _DetalleMedicionPageState extends State<DetalleMedicionPage> {
  bool _visible = false; // para el fundido de los datos

  @override
  void initState() {
    super.initState();
    // Después del primer frame pasa a visible: ese cambio es el que se anima.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  // Con coma decimal: 78.4 -> "78,4"
  String _numero(double valor, int decimales) {
    return valor.toStringAsFixed(decimales).replaceAll('.', ',');
  }

  String _rango(double imc) {
    if (imc < 18.5) return 'IMC bajo el rango normal';
    if (imc < 25) return 'IMC en rango normal';
    return 'IMC sobre el rango normal';
  }

  void _editar() {
    // Reemplaza el detalle por el formulario: al guardar se vuelve directo
    // al historial, que ya muestra los datos nuevos.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NuevaMedicionPage(medicion: widget.medicion),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.medicion;
    final scheme = Theme.of(context).colorScheme;
    final sinAnimaciones = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      appBar: AppBar(title: Text('Medición del ${m.fechaCorta}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: SizedBox(
              width: 110,
              height: 110,
              child: Hero(
                tag: heroMedicion(m),
                child: const InsigniaMedicion(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: Duration(milliseconds: sinAnimaciones ? 0 : 450),
            curve: Curves.easeOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${_numero(m.peso, 1)} kg',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  _rango(m.imc),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text('${m.fechaCorta} ${m.fecha.year}'),
                  subtitle: const Text('Fecha'),
                ),
                ListTile(
                  leading: const Icon(Icons.height_rounded),
                  title: Text('${_numero(m.estatura, 2)} m'),
                  subtitle: const Text('Estatura'),
                ),
                ListTile(
                  leading: const Icon(Icons.speed_rounded),
                  title: Text(_numero(m.imc, 1)),
                  subtitle: const Text('IMC'),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border_rounded),
                  title: Text(m.pulso == null ? 'Sin registrar' : '${m.pulso} lpm'),
                  subtitle: const Text('Pulso en reposo'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _editar,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar medición'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}