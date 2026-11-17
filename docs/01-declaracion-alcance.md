# 01 — Declaración de alcance

## Aplicación

**TaskFlow** es un gestor de tareas personales. Cada usuario se registra con correo y contraseña, crea sus tareas,
las consulta, edita, marca como completadas y elimina. Un usuario **solo** puede ver y modificar sus propias tareas.

- **Recurso principal (entidad):** `Tarea`

  | Campo | Tipo | Descripción |
  |---|---|---|
  | `id` | `String` | ID del documento en Firestore |
  | `titulo` | `String` | Obligatorio, máximo 100 caracteres |
  | `descripcion` | `String` | Opcional |
  | `completada` | `bool` | `false` al crear |
  | `fechaCreacion` | `Timestamp` | Fecha y hora de creación |
  | `uid` | `String` | UID del usuario dueño (Firebase Auth) |

- **Pantallas:** Login, Registro, Lista de tareas (Home), Formulario de tarea (crear/editar), Detalle de tarea.

## Módulos y servicios

| Módulo / servicio | ¿Aplica? | Observación |
|---|---|---|
| Autenticación (Firebase Auth, email/contraseña) | ✅ Sí | Registro, inicio de sesión, cierre de sesión y persistencia de la sesión al reiniciar la app. |
| Base de datos (Cloud Firestore) | ✅ Sí | CRUD de tareas en la colección `tareas`. Todas las consultas filtran por el `uid` del usuario autenticado y las reglas de seguridad lo exigen. |
| Almacenamiento (Firebase Storage) | ❌ No aplica | La app no maneja archivos ni imágenes; las tareas son solo texto. |
| Notificaciones push (FCM) | ❌ No aplica | Las tareas no tienen fecha de vencimiento ni recordatorios, y no hay interacción entre usuarios que requiera avisos. Por eso los casos CP-14 a CP-17 se marcan como "No aplica". |
| API REST externa | ❌ No aplica | Todos los datos provienen de Firebase; no se consume ningún servicio externo. |
| Otros (Analytics, Crashlytics, Remote Config) | ❌ No aplica | Fuera del alcance de la práctica. |

## Arquitectura relevante para las pruebas

- **Patrón repositorio:** las pantallas dependen de las interfaces `AuthRepository` y `TareaRepository`, inyectadas con
  `Provider`. Las implementaciones reales son `FirebaseAuthRepository` y `FirestoreTareaRepository`. En las pruebas
  automatizadas se inyectan fakes en memoria (`test/fakes/`), por lo que no se necesita Firebase para ejecutarlas.
- **Navegación:** rutas nombradas (`lib/rutas.dart`). La ruta raíz (`AuthGate`) muestra Login o Home según la sesión.
- **Manejo de errores:** toda operación asíncrona usa `try/catch` y muestra un mensaje en un SnackBar o en la pantalla.

## Entorno de pruebas

| Elemento | Valor |
|---|---|
| Flutter / Dart | 3.44.8 (stable) / 3.12.2 |
| Plataforma configurada en Firebase | Android (iOS, web y escritorio no están configurados) |
| Dispositivo / emulador | _Completar (modelo y versión de Android)_ |
| Usuarios de prueba | `prueba1@test.com`, `prueba2@test.com` (contraseñas solo en local, no se publican) |
| Reglas de Firestore | [`firestore.rules`](../firestore.rules) |

## Reglas de seguridad de Firestore

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

## Seguridad del repositorio

El repositorio es público. Por eso **no** se suben `android/app/google-services.json`,
`ios/Runner/GoogleService-Info.plist`, `lib/firebase_options.dart` ni `firebase.json` (todos están en `.gitignore`).
Se incluye [`lib/firebase_options.example.dart`](../lib/firebase_options.example.dart) con valores falsos; el archivo
real se regenera con `flutterfire configure`.
