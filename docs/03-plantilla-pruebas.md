# 03 — Plantilla de pruebas funcionales

## Análisis estático inicial (Fase 1)

| Medición | Fecha | Errores | Warnings | Infos | Evidencia |
|---|---|---|---|---|---|
| `flutter analyze` inicial (antes de integrar) | _Completar_ | _Completar_ | _Completar_ | _Completar_ | _Completar_ |
| `flutter analyze` tras integrar pantallas y pruebas | 2026-11-16 | 0 | 0 | 0 | [flutter-analyze.txt](evidencias/pruebas-y-analisis/flutter-analyze.txt) |

## Criterios

- **Estados posibles:** `Aprobado` / `Fallido` / `Bloqueado` / `No ejecutado` / `No aplica`.
- **Criterio de Aprobado:** el resultado coincide con lo esperado, no aparecen excepciones no controladas en la consola,
  hay evidencia adjunta y el resultado se repite tras reiniciar la app.
- **"Resultado obtenido"** describe lo que pasó realmente (nunca solo "ok").
- **Evidencia:** enlace a la captura o al archivo en `docs/evidencias/`. Nombre sugerido: `CP-XX_descripcion-corta.png`.
- **Incidencia:** ID del registro en [04-registro-incidencias.md](04-registro-incidencias.md) si el caso falló.
- **Usuarios de prueba:** `prueba1@test.com` y `prueba2@test.com` (las contraseñas no se escriben en este documento).

## Casos de prueba

| ID | Módulo | Descripción | Precondición | Pasos | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia | Incidencia |
|---|---|---|---|---|---|---|---|---|---|---|
| CP-01 | Auth | Registro de usuario nuevo con datos válidos | App instalada, sin sesión. El correo no existe en Firebase Auth | 1. Abrir la app<br>2. Pulsar "¿No tienes cuenta? Regístrate"<br>3. Llenar correo, contraseña y confirmación<br>4. Pulsar "Registrarme" | Correo: `prueba1@test.com`<br>Contraseña válida de ≥ 6 caracteres (igual en ambos campos) | Se muestra Home con "No tienes tareas" y el SnackBar "Cuenta creada. ¡Bienvenido!". El usuario aparece en Firebase Console → Authentication | | No ejecutado | | |
| CP-02 | Auth | Inicio de sesión con credenciales válidas | Usuario `prueba1@test.com` registrado, sin sesión iniciada | 1. Abrir la app<br>2. Escribir correo y contraseña<br>3. Pulsar "Iniciar sesión" | Correo: `prueba1@test.com`<br>Contraseña correcta | Se muestra Home ("Mis tareas") con el correo del usuario bajo el título y sus tareas (o "No tienes tareas") | | No ejecutado | | |
| CP-03 | Auth | **(Negativo)** Inicio de sesión con contraseña incorrecta y con campos vacíos | Usuario `prueba1@test.com` registrado, sin sesión | 1. Pulsar "Iniciar sesión" con los campos vacíos<br>2. Escribir el correo y una contraseña incorrecta<br>3. Pulsar "Iniciar sesión" | a) Campos vacíos<br>b) `prueba1@test.com` + contraseña incorrecta | a) Mensajes "El correo es obligatorio" y "La contraseña es obligatoria"; no se llama a Firebase<br>b) SnackBar "Correo o contraseña incorrectos"; la app sigue en Login sin cerrarse | | No ejecutado | | |
| CP-04 | Auth | **(Negativo)** Registro con datos inválidos o correo ya existente | `prueba1@test.com` ya registrado | 1. Ir a Registro<br>2. Escribir contraseñas distintas y pulsar "Registrarme"<br>3. Corregir las contraseñas y usar un correo ya registrado<br>4. Pulsar "Registrarme" | a) Contraseña y confirmación distintas<br>b) Correo `prueba1@test.com` | a) Mensaje "Las contraseñas no coinciden"; no se llama a Firebase<br>b) SnackBar "Ya existe una cuenta con ese correo"; se queda en Registro | | No ejecutado | | |
| CP-05 | Firestore | Crear una tarea y verla en la lista | Sesión iniciada con `prueba1@test.com` | 1. En Home pulsar "Nueva tarea"<br>2. Escribir título y descripción<br>3. Pulsar "Guardar" | Título: `Comprar pan`<br>Descripción: `Integral` | SnackBar "Tarea creada"; vuelve a Home y la tarea aparece en la lista sin recargar. En Firestore existe un documento en `tareas` con `uid` del usuario, `completada: false` y `fechaCreacion` | | No ejecutado | | |
| CP-06 | Firestore / UI | **(Negativo)** Crear una tarea con título vacío | Sesión iniciada | 1. Pulsar "Nueva tarea"<br>2. Dejar el título vacío (o solo espacios)<br>3. Pulsar "Guardar" | Título: vacío / `"   "` | Mensaje "El título es obligatorio"; no se crea ningún documento en Firestore; se queda en el formulario | | No ejecutado | | |
| CP-07 | Firestore | Ver el detalle y editar una tarea | Sesión iniciada; existe la tarea `Comprar pan` | 1. Tocar la tarea en Home<br>2. Verificar los datos del Detalle<br>3. Pulsar el icono de editar<br>4. Cambiar el título y pulsar "Guardar" | Nuevo título: `Comprar pan y leche` | El Detalle muestra título, estado "Pendiente", fecha y descripción. Tras guardar: SnackBar "Tarea actualizada", el Detalle y la lista muestran el nuevo título. En Firestore no cambian `uid` ni `fechaCreacion` | | No ejecutado | | |
| CP-08 | Firestore | Marcar una tarea como completada y volver a pendiente | Sesión iniciada; existe una tarea pendiente | 1. Abrir el Detalle y pulsar "Marcar como completada"<br>2. Volver a Home<br>3. Desmarcar el checkbox de la tarea en Home<br>4. Cerrar y reabrir la app | — | Paso 1: estado "Completada" y SnackBar "Tarea completada". Paso 2: en Home el título aparece tachado y el checkbox marcado. Paso 3: deja de estar tachado. Paso 4: se conserva el último estado | | No ejecutado | | |
| CP-09 | Firestore | Eliminar una tarea (con confirmación) | Sesión iniciada; existe la tarea a eliminar | 1. Abrir el Detalle y pulsar el icono de eliminar<br>2. Pulsar "Cancelar"<br>3. Pulsar de nuevo eliminar y luego "Eliminar" | — | Paso 2: la tarea no se elimina. Paso 3: vuelve a Home, SnackBar "Tarea eliminada", la tarea ya no está en la lista ni en Firestore | | No ejecutado | | |
| CP-10 | Auth / Navegación | Cerrar sesión y que los datos dejen de verse | Sesión iniciada con tareas en la lista | 1. En Home pulsar el icono "Cerrar sesión"<br>2. Pulsar el botón "Atrás" del sistema | — | Paso 1: se muestra Login y la lista ya no es visible. Paso 2: no se vuelve a Home (la app sale o permanece en Login) | | No ejecutado | | |
| CP-11 | Reglas | Aislamiento de datos entre usuarios (reglas de Firestore) | `prueba1` tiene al menos una tarea; `prueba2` registrado. Reglas de `firestore.rules` publicadas | 1. Iniciar sesión con `prueba2@test.com` y revisar la lista<br>2. En Firebase Console → Firestore → Reglas → Rules Playground, simular `get` de `/tareas/{id de una tarea de prueba1}` autenticado con el UID de `prueba2`<br>3. Repetir la simulación con el UID de `prueba1` | UIDs de `prueba1` y `prueba2` (de Authentication) | Paso 1: `prueba2` no ve las tareas de `prueba1`. Paso 2: la simulación es **denegada**. Paso 3: la simulación es **permitida** | | No ejecutado | | |
| CP-12 | Auth / Errores | **(Negativo)** Uso sin conexión a Internet | Sin sesión iniciada; activar el modo avión | 1. Con modo avión, intentar iniciar sesión<br>2. Desactivar el modo avión e intentar de nuevo | Credenciales válidas de `prueba1` | Paso 1: SnackBar "Sin conexión. Revisa tu red e intenta de nuevo"; la app no se cierra ni muestra excepciones. Paso 2: inicia sesión normalmente | | No ejecutado | | |
| CP-13 | Storage | Subir un archivo adjunto | No aplica: la app no usa Firebase Storage (ver docs/01) | — | — | — | | No aplica | | |
| CP-14 | FCM | Notificación con la app en primer plano | No aplica: la app no usa FCM (ver docs/01) | — | — | — | | No aplica | | |
| CP-15 | FCM | Notificación con la app en segundo plano | No aplica: la app no usa FCM (ver docs/01) | — | — | — | | No aplica | | |
| CP-16 | FCM | Notificación con la app cerrada | No aplica: la app no usa FCM (ver docs/01) | — | — | — | | No aplica | | |
| CP-17 | FCM | Obtención del token y permiso de notificaciones | No aplica: la app no usa FCM (ver docs/01) | — | — | — | | No aplica | | |
| CP-18 | Auth | Persistencia de la sesión al reiniciar la app | Sesión iniciada con `prueba1` | 1. Cerrar la app por completo (forzar detención)<br>2. Abrir la app de nuevo | — | Se abre directamente en Home con las tareas de `prueba1`, sin pasar por Login | | No ejecutado | | |
| CP-19 | Calidad | Pruebas automatizadas en verde | Dependencias instaladas (`flutter pub get`) | 1. Ejecutar `flutter test`<br>2. Guardar la salida en `docs/evidencias/pruebas-y-analisis/flutter-test.txt` | — | Todas las pruebas unitarias y de widget pasan ("All tests passed!") | | No ejecutado | | |
| CP-20 | Calidad | Análisis estático sin errores | Dependencias instaladas | 1. Ejecutar `flutter analyze`<br>2. Guardar la salida en `docs/evidencias/pruebas-y-analisis/flutter-analyze.txt` | — | "No issues found!" (0 errores) | | No ejecutado | | |

## Pruebas automatizadas

| Archivo | Tipo | Qué verifica |
|---|---|---|
| `test/unit/validators_test.dart` | Unitaria | Email vacío/inválido/válido, contraseña vacía o < 6, confirmación, título vacío o > 100 |
| `test/unit/tarea_model_test.dart` | Unitaria | `Tarea.toMap` / `fromMap` (ida y vuelta), formatos de fecha, campos faltantes, `copyWith` |
| `test/widget/home_screen_test.dart` | Widget (fakes) | Estados cargando, vacío ("No tienes tareas"), con datos (solo del usuario), error; cerrar sesión |
| `test/widget/login_screen_test.dart` | Widget (fakes) | Campos vacíos muestran validación y **no** llaman al repositorio; credenciales incorrectas |
| `test/widget/tarea_form_screen_test.dart` | Widget (fakes) | Título vacío no crea la tarea; creación con el `uid` del usuario; edición precarga los datos |
| `test/widget/app_smoke_test.dart` | Widget (fakes) | Arranque en Login; flujo completo login → crear → detalle → completar → eliminar → logout |

## Resumen de resultados

_Completar tras ejecutar los casos._

| Métrica | Valor |
|---|---|
| Casos aplicables (excluye "No aplica") | 15 |
| Casos ejecutados | |
| Aprobados | |
| Fallidos | |
| Bloqueados | |
| % Aprobados en flujos críticos (CP-01 a CP-12, CP-18) — meta ≥ 80 % | |
