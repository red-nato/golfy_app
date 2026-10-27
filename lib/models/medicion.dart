// Una medición de un usuario, tal como vive en la tabla `mediciones` de
// Supabase. El IMC no se guarda: se calcula con el peso y la estatura.
class Medicion {
  const Medicion({
    this.id,
    required this.fecha,
    required this.peso,
    required this.estatura,
    this.pulso,
  });

  final String? id; // null mientras todavía no se guarda en Supabase
  final DateTime fecha;
  final double peso; // kg
  final double estatura; // metros
  final int? pulso; // latidos por minuto, opcional

  // IMC = peso / estatura²
  double get imc => peso / (estatura * estatura);

  // Convierte una fila de Supabase (un Map) en una Medicion.
  factory Medicion.fromJson(Map<String, dynamic> json) {
    return Medicion(
      id: json['id'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      peso: (json['peso'] as num).toDouble(),
      estatura: (json['estatura'] as num).toDouble(),
      pulso: (json['pulso'] as num?)?.toInt(),
    );
  }

  // Lo que se envía a Supabase al crear o editar. No manda id ni user_id:
  // la tabla los genera sola (gen_random_uuid() y auth.uid()).
  Map<String, dynamic> toJson() {
    return {
      'fecha': fechaIso,
      'peso': peso,
      'estatura': estatura,
      'pulso': pulso,
    };
  }

  // "2026-10-08": el formato de las columnas `date` de Postgres.
  String get fechaIso {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${fecha.year}-${dos(fecha.month)}-${dos(fecha.day)}';
  }

  // "8 oct": el mismo formato que usaba el historial de la app.
  String get fechaCorta {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]}';
  }
}