import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tarea.dart';
import 'tarea_repository.dart';

/// Implementación de [TareaRepository] con Cloud Firestore.
///
/// Colección: `tareas`. Cada documento guarda el `uid` del dueño, que las
/// reglas de seguridad (`firestore.rules`) comparan con `request.auth.uid`.
class FirestoreTareaRepository implements TareaRepository {
  static const String coleccion = 'tareas';

  final FirebaseFirestore _db;

  FirestoreTareaRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tareas =>
      _db.collection(coleccion);

  @override
  Stream<List<Tarea>> observarTareas(String uid) {
    // Se filtra por uid en la consulta (obligatorio por las reglas) y se
    // ordena en el cliente para no requerir un índice compuesto.
    return _tareas
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final lista =
              snap.docs.map((doc) => Tarea.fromMap(doc.id, doc.data())).toList()
                ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
          return lista;
        })
        .handleError((Object e) {
          throw TareaRepositoryException(_mensaje('cargar las tareas', e));
        });
  }

  @override
  Future<Tarea?> obtenerTarea(String id) async {
    try {
      final doc = await _tareas.doc(id).get();
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return Tarea.fromMap(doc.id, data);
    } catch (e) {
      throw TareaRepositoryException(_mensaje('obtener la tarea', e));
    }
  }

  @override
  Future<String> crearTarea(Tarea tarea) async {
    try {
      final ref = await _tareas.add(tarea.toMap());
      return ref.id;
    } catch (e) {
      throw TareaRepositoryException(_mensaje('crear la tarea', e));
    }
  }

  @override
  Future<void> actualizarTarea(Tarea tarea) async {
    try {
      // No se modifican uid ni fechaCreacion al editar.
      await _tareas.doc(tarea.id).update({
        'titulo': tarea.titulo,
        'descripcion': tarea.descripcion,
        'completada': tarea.completada,
      });
    } catch (e) {
      throw TareaRepositoryException(_mensaje('actualizar la tarea', e));
    }
  }

  @override
  Future<void> cambiarCompletada(String id, bool completada) async {
    try {
      await _tareas.doc(id).update({'completada': completada});
    } catch (e) {
      throw TareaRepositoryException(_mensaje('actualizar la tarea', e));
    }
  }

  @override
  Future<void> eliminarTarea(String id) async {
    try {
      await _tareas.doc(id).delete();
    } catch (e) {
      throw TareaRepositoryException(_mensaje('eliminar la tarea', e));
    }
  }

  String _mensaje(String accion, Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'No tienes permiso para $accion';
        case 'unavailable':
          return 'Sin conexión: no se pudo $accion';
        case 'not-found':
          return 'La tarea no existe';
      }
      return 'Error al $accion (${e.code})';
    }
    return 'Error inesperado al $accion';
  }
}
