# TaskFlow — Práctica de integración y pruebas funcionales (Flutter + Firebase)

Aplicación Flutter de gestión de tareas personales, desarrollada para la práctica **4_A1 — Integración y pruebas funcionales del proyecto**.
Integra UI, navegación, Firebase Authentication y Cloud Firestore, e incluye pruebas funcionales manuales, pruebas automatizadas y el registro y corrección de incidencias.

## Funcionalidades
- Registro, inicio y cierre de sesión con correo y contraseña (Firebase Auth).
- Crear, ver, editar, marcar como completada y eliminar tareas (Cloud Firestore).
- Cada usuario solo ve sus propias tareas (reglas de seguridad por `uid`).
- Manejo de estados: cargando, lista vacía, error y sin conexión.

## Alcance
| Módulo | ¿Aplica? |
|---|---|
| Autenticación | Sí |
| Base de datos (Firestore) | Sí |
| Storage | No |
| Notificaciones push (FCM) | No |
| API REST externa | No |
| Otros (Analytics, Crashlytics…) | No |

Detalle en [docs/01-declaracion-alcance.md](docs/01-declaracion-alcance.md).

## Requisitos
- Flutter 3.44.8 (stable) / Dart 3.12
- Android Studio con un emulador Android (imagen con Google Play) o dispositivo físico
- Node.js, Firebase CLI y FlutterFire CLI
- Un proyecto de Firebase con Authentication (correo/contraseña) y Firestore habilitados

## Cómo ejecutar
Los archivos de configuración de Firebase **no están en el repositorio** por seguridad. Para generarlos:

```bash
git clone https://github.com/cjdominguez91/practica-integracion-pruebas-flutter_ev_4.git
cd practica-integracion-pruebas-flutter_ev_4
flutter pub get

npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure      # seleccionar el proyecto de Firebase y la plataforma android

flutter run
```

Publicar en Firestore las reglas del archivo [`firestore.rules`](firestore.rules).
`lib/firebase_options.example.dart` muestra la estructura del archivo generado, con valores ficticios.

## Pruebas
```bash
flutter test       # pruebas unitarias (test/unit) y de widget (test/widget)
flutter analyze    # análisis estático
```

## Estructura
```
lib/                 Código fuente (models, utils, repositories, screens)
test/unit/           Pruebas unitarias
test/widget/         Pruebas de widget con repositorios fake
docs/                Documentación de la práctica
docs/evidencias/     Capturas de la app, Firebase y salidas de pruebas
```

## Documentación y evidencias
1. [Declaración de alcance](docs/01-declaracion-alcance.md)
2. [Mapa de flujos críticos](docs/02-mapa-flujos-criticos.md)
3. [Plantilla de pruebas](docs/03-plantilla-pruebas.md)
4. [Registro de incidencias](docs/04-registro-incidencias.md)
5. [Reflexión final](docs/05-reflexion-final.md)
- [Capturas de la aplicación](docs/evidencias/capturas-aplicacion/)
- [Evidencias de Firebase](docs/evidencias/firebase/)
- [Salidas de flutter test y flutter analyze](docs/evidencias/pruebas-y-analisis/)

## Ramas y commits
- Rama de trabajo: `semana16-integracion`.
- Las correcciones de incidencias se identifican con commits `fix: INC-00X ...`.