import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/firestore_tarea_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    debugPrint('Error al inicializar Firebase: $e\n$st');
    runApp(ErrorInicioApp(mensaje: e.toString()));
    return;
  }

  runApp(
    TaskFlowApp(
      authRepository: FirebaseAuthRepository(),
      tareaRepository: FirestoreTareaRepository(),
    ),
  );
}
