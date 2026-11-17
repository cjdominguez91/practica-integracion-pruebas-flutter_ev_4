import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/auth_repository.dart';
import 'repositories/tarea_repository.dart';

/// Raíz de la app. Recibe los repositorios por constructor para que las
/// pruebas puedan inyectar fakes sin Firebase.
class TaskFlowApp extends StatelessWidget {
  final AuthRepository authRepository;
  final TareaRepository tareaRepository;

  const TaskFlowApp({
    super.key,
    required this.authRepository,
    required this.tareaRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<TareaRepository>.value(value: tareaRepository),
      ],
      child: MaterialApp(
        title: 'TaskFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        // TODO: reemplazar por las rutas nombradas (login, registro, home,
        // formulario, detalle) cuando existan las pantallas.
        home: const _PantallaTemporal(),
      ),
    );
  }
}

class _PantallaTemporal extends StatelessWidget {
  const _PantallaTemporal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TaskFlow')),
      body: const Center(child: Text('Pantallas en construcción')),
    );
  }
}

/// Se muestra si Firebase no pudo inicializarse.
class ErrorInicioApp extends StatelessWidget {
  final String mensaje;

  const ErrorInicioApp({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'No se pudo conectar con Firebase',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(mensaje, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
