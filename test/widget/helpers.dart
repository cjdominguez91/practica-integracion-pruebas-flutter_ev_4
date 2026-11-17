import 'package:flutter/material.dart';
import 'package:practica_integracion_pruebas_flutter/app.dart';
import 'package:practica_integracion_pruebas_flutter/repositories/auth_repository.dart';
import 'package:practica_integracion_pruebas_flutter/repositories/tarea_repository.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_tarea_repository.dart';

/// Monta [pantalla] con los repositorios fake y las rutas de la app.
Widget envolver(
  Widget pantalla, {
  AuthRepository? auth,
  TareaRepository? tareas,
}) {
  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: auth ?? FakeAuthRepository()),
      Provider<TareaRepository>.value(value: tareas ?? FakeTareaRepository()),
    ],
    child: MaterialApp(home: pantalla, onGenerateRoute: generarRuta),
  );
}
