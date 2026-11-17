// ARCHIVO DE EJEMPLO — no contiene claves reales.
//
// El archivo real `lib/firebase_options.dart` está en .gitignore. Para
// generarlo con tu propio proyecto de Firebase ejecuta:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TU_API_KEY_WEB',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'tu-proyecto-id',
    authDomain: 'tu-proyecto-id.firebaseapp.com',
    storageBucket: 'tu-proyecto-id.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TU_API_KEY_ANDROID',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'tu-proyecto-id',
    storageBucket: 'tu-proyecto-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TU_API_KEY_IOS',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'tu-proyecto-id',
    storageBucket: 'tu-proyecto-id.appspot.com',
    iosBundleId: 'com.example.practicaIntegracionPruebasFlutter',
  );
}
