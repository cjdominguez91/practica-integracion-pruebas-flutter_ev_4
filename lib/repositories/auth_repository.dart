/// Usuario autenticado, independiente de Firebase para poder usar fakes.
class UsuarioApp {
  final String uid;
  final String? email;

  const UsuarioApp({required this.uid, this.email});
}

/// Error de autenticación con un mensaje listo para mostrar en la UI.
class AuthException implements Exception {
  final String mensaje;
  final String? codigo;

  const AuthException(this.mensaje, {this.codigo});

  @override
  String toString() => 'AuthException($codigo): $mensaje';
}

/// Contrato de autenticación. Las pantallas dependen de esta interfaz,
/// nunca de `FirebaseAuth` directamente.
abstract class AuthRepository {
  /// Usuario con sesión iniciada, o `null`.
  UsuarioApp? get usuarioActual;

  /// Emite cada vez que cambia el estado de la sesión.
  Stream<UsuarioApp?> cambiosDeSesion();

  /// Lanza [AuthException] si falla.
  Future<UsuarioApp> iniciarSesion(String email, String password);

  /// Lanza [AuthException] si falla.
  Future<UsuarioApp> registrar(String email, String password);

  Future<void> cerrarSesion();
}
