import '../models/tarea.dart';

/// Error de acceso a datos con un mensaje listo para mostrar en la UI.
class TareaRepositoryException implements Exception {
  final String mensaje;

  const TareaRepositoryException(this.mensaje);

  @override
  String toString() => 'TareaRepositoryException: $mensaje';
}

/// Contrato de acceso a las tareas. Todas las operaciones están
/// limitadas al usuario indicado por `uid`.
abstract class TareaRepository {
  /// Tareas del usuario, ordenadas de más reciente a más antigua.
  /// El stream emite un error [TareaRepositoryException] si falla la carga.
  Stream<List<Tarea>> observarTareas(String uid);

  /// Devuelve la tarea o `null` si no existe.
  Future<Tarea?> obtenerTarea(String id);

  /// Crea la tarea y devuelve el ID generado.
  Future<String> crearTarea(Tarea tarea);

  Future<void> actualizarTarea(Tarea tarea);

  Future<void> cambiarCompletada(String id, bool completada);

  Future<void> eliminarTarea(String id);
}
