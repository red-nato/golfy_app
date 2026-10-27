import 'package:flutter/material.dart';

import '../models/medicion.dart';
import '../theme.dart';

// El tag del Hero de una medición: el mismo en la fila del historial y en
// el detalle, y distinto para cada medición gracias a su id.
String heroMedicion(Medicion m) => 'medicion-${m.id}';

// Un círculo verde con el ícono de medición. Ocupa todo el espacio que le
// den, así crece de forma pareja mientras vuela con el Hero.
class InsigniaMedicion extends StatelessWidget {
  const InsigniaMedicion({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: golfGreen, shape: BoxShape.circle),
      child: FractionallySizedBox(
        widthFactor: 0.55,
        heightFactor: 0.55,
        child: FittedBox(
          child: Icon(Icons.monitor_weight_outlined, color: golfLime),
        ),
      ),
    );
  }
}