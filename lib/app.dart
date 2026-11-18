import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/tarea.dart';
import 'repositories/auth_repository.dart';
import 'repositories/tarea_repository.dart';
import 'rutas.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/tarea_detalle_screen.dart';
import 'screens/tarea_form_screen.dart';

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
        initialRoute: Rutas.inicio,
        routes: {
          Rutas.inicio: (_) => const AuthGate(),
          Rutas.registro: (_) => const RegistroScreen(),
        },
        onGenerateRoute: generarRuta,
      ),
    );
  }
}

/// Rutas que reciben argumentos.
Route<dynamic>? generarRuta(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case Rutas.formulario:
      return MaterialPageRoute<bool>(
        settings: settings,
        builder: (_) => TareaFormScreen(tarea: args is Tarea ? args : null),
      );
    case Rutas.detalle:
      if (args is String) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => TareaDetalleScreen(tareaId: args),
        );
      }
  }
  return null;
}

/// Muestra Login o Home según el estado de la sesión. Al cerrar sesión,
/// Home se destruye y sus datos dejan de estar visibles.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<UsuarioApp?> _sesion;

  @override
  void initState() {
    super.initState();
    _sesion = context.read<AuthRepository>().cambiosDeSesion();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UsuarioApp?>(
      stream: _sesion,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final usuario = snapshot.data;
        if (usuario == null) return const LoginScreen();
        // La key fuerza un Home nuevo si cambia de usuario.
        return HomeScreen(key: ValueKey(usuario.uid), usuario: usuario);
      },
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
