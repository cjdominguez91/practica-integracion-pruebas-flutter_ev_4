import 'dart:async';

import 'package:practica_integracion_pruebas_flutter/repositories/auth_repository.dart';

/// Fake en memoria de [AuthRepository] para pruebas sin Firebase.
class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<UsuarioApp?>.broadcast();
  final Map<String, String> _cuentas = {};
  UsuarioApp? _usuario;

  /// Si se asigna, la siguiente operación lanza este error.
  AuthException? errorSiguiente;

  int llamadasIniciarSesion = 0;
  int llamadasRegistrar = 0;
  int llamadasCerrarSesion = 0;

  FakeAuthRepository({UsuarioApp? usuarioInicial}) : _usuario = usuarioInicial;

  /// Registra una cuenta sin iniciar sesión (para probar el login).
  void agregarCuenta(String email, String password) {
    _cuentas[email] = password;
  }

  @override
  UsuarioApp? get usuarioActual => _usuario;

  @override
  Stream<UsuarioApp?> cambiosDeSesion() async* {
    yield _usuario;
    yield* _controller.stream;
  }

  @override
  Future<UsuarioApp> iniciarSesion(String email, String password) async {
    llamadasIniciarSesion++;
    _lanzarSiHayError();
    if (_cuentas[email] != password) {
      throw const AuthException(
        'Correo o contraseña incorrectos',
        codigo: 'invalid-credential',
      );
    }
    return _cambiar(UsuarioApp(uid: 'uid-$email', email: email));
  }

  @override
  Future<UsuarioApp> registrar(String email, String password) async {
    llamadasRegistrar++;
    _lanzarSiHayError();
    if (_cuentas.containsKey(email)) {
      throw const AuthException(
        'Ya existe una cuenta con ese correo',
        codigo: 'email-already-in-use',
      );
    }
    _cuentas[email] = password;
    return _cambiar(UsuarioApp(uid: 'uid-$email', email: email));
  }

  @override
  Future<void> cerrarSesion() async {
    llamadasCerrarSesion++;
    _lanzarSiHayError();
    _usuario = null;
    _controller.add(null);
  }

  UsuarioApp _cambiar(UsuarioApp usuario) {
    _usuario = usuario;
    _controller.add(usuario);
    return usuario;
  }

  void _lanzarSiHayError() {
    final error = errorSiguiente;
    if (error != null) {
      errorSiguiente = null;
      throw error;
    }
  }
}
