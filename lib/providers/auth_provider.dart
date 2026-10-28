import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../perfil.dart';

// La sesión del usuario con Supabase Auth. La usan el login (entrar y crear
// cuenta) y la pantalla principal (cerrar sesión), así que vive en un provider.
class AuthProvider extends ChangeNotifier {
  bool cargando = false;

  GoTrueClient get _auth => Supabase.instance.client.auth;

  String? get correo => _auth.currentUser?.email;
  User? get usuario => _auth.currentUser;

  // Devuelven null si salió bien, o el texto del error para mostrarlo.
  Future<String?> entrar(String correo, String clave) =>
      _ejecutar(() => _auth.signInWithPassword(email: correo, password: clave));

  Future<String?> registrar(String correo, String clave, String nombre) =>
      _ejecutar(
        () => _auth.signUp(
          email: correo,
          password: clave,
          data: {'full_name': nombre},
        ),
      );

  Future<String?> actualizarPerfil(Perfil perfil) => _ejecutar(
    () => _auth.updateUser(
      UserAttributes(
        data: {
          'full_name': perfil.nombre,
          'age': perfil.edad,
          'weight_kg': perfil.peso,
          'height_m': perfil.estatura,
          'handicap': perfil.handicap,
          'right_handed': perfil.manoDerecha,
        },
      ),
    ),
  );

  Future<void> salir() => _auth.signOut();

  Future<String?> _ejecutar<T>(Future<T> Function() accion) async {
    cargando = true;
    notifyListeners();
    try {
      await accion();
      return null;
    } on AuthException catch (e) {
      return e.message; // por ejemplo: "Invalid login credentials"
    } catch (_) {
      return 'No se pudo conectar. Revisa tu conexión a internet.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
