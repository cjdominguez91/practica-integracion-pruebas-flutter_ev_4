// ARCHIVO DE EJEMPLO — contiene valores FALSOS, no claves reales.
//
// El archivo real `lib/firebase_options.dart` está en .gitignore y no se
// sube al repositorio. Para generarlo con tu propio proyecto de Firebase:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Alternativa manual: copia este archivo como `lib/firebase_options.dart`
// y reemplaza los valores con los de la consola de Firebase
// (Configuración del proyecto → Tus apps → Android).
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opciones de Firebase por plataforma. En este proyecto solo está
/// configurado Android.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions no está configurado para web. '
        'Ejecuta "flutterfire configure" para agregarlo.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para iOS. '
          'Ejecuta "flutterfire configure" para agregarlo.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para macOS. '
          'Ejecuta "flutterfire configure" para agregarlo.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para Windows. '
          'Ejecuta "flutterfire configure" para agregarlo.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para Linux. '
          'Ejecuta "flutterfire configure" para agregarlo.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está soportado en esta plataforma.',
        );
    }
  }

  // Valores de ejemplo: no corresponden a ningún proyecto real.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyEJEMPLO-NO-ES-UNA-CLAVE-REAL-0000',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'taskflow-ejemplo',
    storageBucket: 'taskflow-ejemplo.firebasestorage.app',
  );
}
