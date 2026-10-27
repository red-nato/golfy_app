import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/medicion.dart';

// Habla con la tabla `mediciones` de Supabase: el CRUD completo.
// No filtra por usuario: Row Level Security ya devuelve solo las filas de
// quien inició sesión, y solo le deja crear, editar y borrar las suyas.
class MedicionesService {
  SupabaseClient get _db => Supabase.instance.client;

  // R: leer todas mis mediciones, de la más reciente a la más antigua.
  Future<List<Medicion>> obtener() async {
    final filas = await _db
        .from('mediciones')
        .select()
        .order('fecha', ascending: false)
        .order('created_at', ascending: false);
    return [for (final fila in filas) Medicion.fromJson(fila)];
  }

  // C: crear una medición nueva.
  Future<void> crear(Medicion medicion) async {
    await _db.from('mediciones').insert(medicion.toJson());
  }

  // U: editar una medición que ya existe, buscándola por su id.
  Future<void> editar(Medicion medicion) async {
    await _db
        .from('mediciones')
        .update(medicion.toJson())
        .eq('id', medicion.id!);
  }

  // D: borrar una medición por su id.
  Future<void> borrar(String id) async {
    await _db.from('mediciones').delete().eq('id', id);
  }
}