# CLAUDE.md — Práctica de integración y pruebas funcionales (Flutter + Firebase)

## Contexto
Este repositorio es la entrega de la práctica **"4_A1 — Integración y pruebas funcionales del proyecto"** (40 % de la nota).
El objetivo es integrar una app Flutter (UI, navegación, servicios y Firebase), ejecutar pruebas funcionales y
automatizadas sobre los flujos críticos, y registrar y corregir **al menos 3 incidencias** con evidencia y trazabilidad
(registro → corrección → commit → prueba de regresión).

- Nombre del repositorio: `practica-integracion-pruebas-flutter` (público en GitHub).
- Rama de trabajo obligatoria: `semana16-integracion`.
- Idioma de la documentación, mensajes de UI y comentarios: **español**.

## La app
**TaskFlow** — gestor de tareas personales. (Si el proyecto cambia, actualiza esta sección primero.)

- Recurso principal ("entidad"): **Tarea** (`id`, `titulo`, `descripcion`, `completada`, `fechaCreacion`, `uid`).
- Pantallas mínimas: Login, Registro, Lista de tareas (Home), Formulario de tarea (crear/editar), Detalle de tarea.

### Declaración de alcance
| Módulo / servicio | ¿Aplica? | Observación |
|---|---|---|
| Autenticación (Firebase Auth, email/contraseña) | ✅ | Registro, login, logout |
| Base de datos (Cloud Firestore) | ✅ | CRUD de tareas por usuario |
| Almacenamiento (Storage) | ❌ | Fuera del alcance |
| Notificaciones push (FCM) | ❌ | Fuera del alcance (justificar en docs como "No aplica") |
| API REST externa | ❌ | Fuera del alcance |
| Otros (Analytics, Crashlytics, Remote Config) | ❌ | Fuera del alcance |

> Si se decide incluir FCM, cambiar la tabla y cubrir CP-14 a CP-17 (primer plano, segundo plano y app cerrada).

## Stack
- Flutter **3.44.8** (canal stable) + Dart 3, Material 3. No usar APIs que requieran una versión más nueva.
- Agregar paquetes siempre con `flutter pub add <paquete>` para que se resuelvan versiones compatibles con este SDK.
- Paquetes: `firebase_core`, `firebase_auth`, `cloud_firestore`.
- Dev: `flutter_test`, `integration_test`, `flutter_lints`. (Mocks con fakes escritos a mano; `fake_cloud_firestore` solo si hace falta.)
- Estado: `ChangeNotifier`/`provider` (mantenerlo simple).
- Navegación: `Navigator` con rutas nombradas (o `go_router` si se justifica).

## Arquitectura y estructura
Usar **patrón repositorio** para que las pruebas de widget puedan inyectar un fake sin Firebase.

```
lib/
  main.dart                  # Inicializa Firebase y arranca la app
  app.dart                   # MaterialApp, rutas, tema
  models/tarea.dart          # Modelo + fromMap/toMap (probado en unit)
  utils/validators.dart      # Validadores de email, contraseña, título (probado en unit)
  repositories/
    auth_repository.dart     # Interfaz abstracta
    firebase_auth_repository.dart
    tarea_repository.dart    # Interfaz abstracta
    firestore_tarea_repository.dart
  screens/
    login_screen.dart
    registro_screen.dart
    home_screen.dart         # Lista: estado vacío / con datos / error
    tarea_form_screen.dart
    tarea_detalle_screen.dart
test/
  unit/                      # validators_test.dart, tarea_model_test.dart
  widget/                    # home_screen_test.dart, login_screen_test.dart (con fakes)
  fakes/                     # fake_auth_repository.dart, fake_tarea_repository.dart
integration_test/
  flujo_principal_test.dart  # Opcional
docs/
  01-declaracion-alcance.md
  02-mapa-flujos-criticos.md
  03-plantilla-pruebas.md
  04-registro-incidencias.md
  05-reflexion-final.md
  evidencias/
    capturas-aplicacion/
    firebase/
    notificaciones-fcm/      # Con un README que explique "No aplica" si FCM está fuera de alcance
    pruebas-y-analisis/
```

Reglas:
- Las pantallas reciben los repositorios por constructor o `Provider`; **nunca** llaman a `FirebaseAuth.instance` / `FirebaseFirestore.instance` directamente.
- Cada consulta de Firestore filtra por `uid` del usuario autenticado.
- Toda operación asíncrona maneja errores con `try/catch` y muestra un mensaje en la UI (SnackBar), sin excepciones no controladas.
- Estados explícitos en la lista: cargando, vacío ("No tienes tareas"), error ("Sin conexión / error al cargar"), con datos.

## Reglas de seguridad de Firestore (deben existir y probarse en CP-11)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tareas/{tareaId} {
      allow read, update, delete: if request.auth != null && resource.data.uid == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.uid == request.auth.uid;
    }
  }
}
```
Guardar una copia en `firestore.rules` en la raíz.

## Seguridad del repositorio (OBLIGATORIO — el repo es público)
- **Nunca** commitear `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `lib/firebase_options.dart` ni `firebase.json` con datos reales. Deben estar en `.gitignore`.
- Incluir `lib/firebase_options.example.dart` con valores de ejemplo y explicar en el README cómo regenerar el real con `flutterfire configure`.
- No poner contraseñas, tokens ni datos personales reales en código, docs o capturas. Usuarios de prueba: `prueba1@test.com`, `prueba2@test.com` (contraseñas solo locales).
- Antes de cada commit revisar `git status` para confirmar que ningún archivo sensible está en stage.

## Comandos
```bash
flutter pub get
flutter analyze                    # Debe terminar sin errores
flutter test                       # Debe quedar en verde
flutter test > docs/evidencias/pruebas-y-analisis/flutter-test.txt
flutter analyze > docs/evidencias/pruebas-y-analisis/flutter-analyze.txt
flutter test integration_test      # Opcional, requiere emulador/dispositivo
flutter run
```

## Pruebas automatizadas mínimas
1. **Unitaria**: `validators.dart` (email vacío/inválido/válido, contraseña < 6, título vacío) y `Tarea.fromMap/toMap`.
2. **Widget**: `HomeScreen` con `FakeTareaRepository` → muestra "No tienes tareas" con lista vacía y muestra los títulos con datos. `LoginScreen` → con campos vacíos muestra mensajes de validación y **no** llama al repositorio.
3. **Integración** (opcional): login → crear tarea → verla en la lista → logout.

## Flujos críticos (docs/02)
1. El usuario puede registrarse e iniciar sesión.
2. El usuario puede crear una tarea y verla en la lista.
3. El usuario puede ver el detalle y editar/marcar como completada una tarea.
4. El usuario puede eliminar una tarea.
5. El usuario puede cerrar sesión y sus datos dejan de ser visibles.

## Casos de prueba (docs/03)
Mínimo **10 ejecutados**, al menos uno por flujo crítico y al menos uno negativo. Casos aplicables al alcance:
CP-01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 18, 19, 20. (CP-13 a CP-17 → "No aplica" con motivo.)

Formato de la tabla:
| ID | Módulo | Descripción | Precondición | Pasos | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia | Incidencia |

- Estado: `Aprobado` / `Fallido` / `Bloqueado` / `No ejecutado` / `No aplica`.
- "Resultado obtenido" describe lo que pasó realmente (nunca solo "ok").
- Criterio de Aprobado: coincide con lo esperado, sin excepciones no controladas en consola, con evidencia adjunta y repetible tras reiniciar la app.
- Meta: ≥ 80 % de los casos de flujos críticos en Aprobado tras las correcciones.

## Registro de incidencias (docs/04)
Mínimo **3**, al menos **1 corregida y re-probada**. Formato:
| ID | Título | Caso relacionado | Severidad (Crítica/Alta/Media/Baja) | Prioridad (Alta/Media/Baja) | Origen (UI/Lógica/Firebase/Config/Reglas) | Pasos para reproducir | Resultado esperado | Resultado obtenido | Causa raíz | Corrección | Commit | Re-prueba | Estado |

Método de depuración de 5 pasos para cada incidencia: **reproducir → leer (logs/stack trace) → hipótesis → comprobar → corregir y proteger** (agregar o ajustar una prueba que la cubra).

## Convenciones de Git
- Trabajar siempre en `semana16-integracion`.
- Conventional commits en español:
  - `feat: pantalla de lista de tareas`
  - `test: prueba de widget de HomeScreen con estado vacío`
  - `fix: INC-001 lista no se actualiza tras crear tarea`
  - `docs: registro de incidencias y plantilla de pruebas`
- Cada corrección de incidencia va en **su propio commit** con el ID `INC-00X` en el mensaje.
- Commits pequeños y frecuentes; ambos integrantes de la pareja deben tener commits.

## Fases de trabajo (seguir en orden)
1. **Preparación**: rama, `flutter analyze` inicial (anotar cantidad de warnings/errores en docs/03), alcance en docs/01.
2. **Mapa de flujos** en docs/02.
3. **Integración incremental** — no avanzar si hay una incidencia Crítica/Alta sin resolver o sin registrar:
   arranque/Firebase → auth → navegación → lectura → escritura → flujo completo.
4. **Pruebas automatizadas** (unit + widget, integración opcional) y guardar salida de `flutter test`.
5. **Depuración y corrección** de la incidencia de mayor prioridad + regresión + commit `fix: INC-00X ...`.
6. **Cierre**: completar docs, evidencias, reflexión (5–8 líneas: ¿qué prueba habría evitado mi error más costoso?), README.

## Instrucciones para Claude
- Antes de cambiar código, lee este archivo y respeta la arquitectura y las reglas de seguridad.
- Después de cada cambio de código ejecuta `flutter analyze` y `flutter test`; no dejes errores.
- Cuando encuentres un bug real, regístralo en `docs/04-registro-incidencias.md` antes de corregirlo y sugiere el mensaje de commit `fix: INC-00X ...`.
- No inventes resultados de pruebas manuales: deja "Resultado obtenido" y "Evidencia" para que el estudiante los complete tras ejecutar, salvo las salidas de comandos que tú mismo corras.
- Nunca leas, muestres ni commitees archivos de configuración de Firebase con claves reales.
