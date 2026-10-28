class SesionCarga {
  const SesionCarga({
    required this.fecha,
    required this.tipo,
    required this.minutos,
    required this.esfuerzo,
  });

  final DateTime fecha;
  final int tipo;
  final int minutos;
  final int esfuerzo;

  int get carga => minutos * esfuerzo;

  String get tipoNombre => const [
        'Rango',
        'Putting',
        'Ronda',
        'Gimnasio',
      ][tipo];
}