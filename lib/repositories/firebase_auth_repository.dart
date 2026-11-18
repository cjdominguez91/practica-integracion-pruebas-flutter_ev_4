import 'package:firebase_auth/firebase_auth.dart';

import 'auth_repository.dart';

/// Implementación de [AuthRepository] con Firebase Auth (email/contraseña).
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;

  FirebaseAuthRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  @override
  UsuarioApp? get usuarioActual => _mapear(_auth.currentUser);

  @override
  Stream<UsuarioApp?> cambiosDeSesion() =>
      _auth.authStateChanges().map(_mapear);

  @override
  Future<UsuarioApp> iniciarSesion(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapear(cred.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mensajeDeError(e.code), codigo: e.code);
    } catch (e) {
      throw AuthException('Error inesperado al iniciar sesión: $e');
    }
  }

  @override
  Future<UsuarioApp> registrar(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapear(cred.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mensajeDeError(e.code), codigo: e.code);
    } catch (e) {
      throw AuthException('Error inesperado al registrarse: $e');
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('No se pudo cerrar sesión: $e');
    }
  }

  UsuarioApp? _mapear(User? user) =>
      user == null ? null : UsuarioApp(uid: user.uid, email: user.email);

  String _mensajeDeError(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'El correo no es válido';
      case 'user-disabled':
        return 'La cuenta está deshabilitada';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo';
      case 'weak-password':
        return 'La contraseña es demasiado débil (mínimo 6 caracteres)';
      case 'operation-not-allowed':
        return 'El inicio de sesión con correo no está habilitado en Firebase';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta de nuevo más tarde';
      case 'network-request-failed':
        return 'Sin conexión. Revisa tu red e intenta de nuevo';
      default:
        return 'Error de autenticación ($codigo)';
    }
  }
}
