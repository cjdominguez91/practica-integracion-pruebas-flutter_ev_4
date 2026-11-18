/// Nombres de las rutas de la app.
class Rutas {
  Rutas._();

  /// Raíz: muestra Login o Home según la sesión (ver `AuthGate`).
  static const String inicio = '/';
  static const String registro = '/registro';

  /// Argumento opcional: la `Tarea` a editar (null = crear).
  static const String formulario = '/tarea/formulario';

  /// Argumento obligatorio: el `id` (String) de la tarea.
  static const String detalle = '/tarea/detalle';
}
