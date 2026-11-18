import 'dart:async';

import 'package:practica_integracion_pruebas_flutter/models/tarea.dart';
import 'package:practica_integracion_pruebas_flutter/repositories/tarea_repository.dart';

/// Fake en memoria de [TareaRepository] para pruebas sin Firestore.
class FakeTareaRepository implements TareaRepository {
  final Map<String, Tarea> _tareas = {};
  final _cambios = StreamController<void>.broadcast();
  int _siguienteId = 1;

  /// Si es true, [observarTareas] emite un error (simula sin conexión).
  bool fallarAlCargar;

  FakeTareaRepository({
    List<Tarea> iniciales = const [],
    this.fallarAlCargar = false,
  }) {
    for (final t in iniciales) {
      _tareas[t.id] = t;
    }
  }

  List<Tarea> _deUsuario(String uid) =>
      _tareas.values.where((t) => t.uid == uid).toList()
        ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));

  @override
  Stream<List<Tarea>> observarTareas(String uid) async* {
    if (fallarAlCargar) {
      throw const TareaRepositoryException(
        'Sin conexión: no se pudo cargar las tareas',
      );
    }
    yield _deUsuario(uid);
    await for (final _ in _cambios.stream) {
      yield _deUsuario(uid);
    }
  }

  @override
  Future<Tarea?> obtenerTarea(String id) async => _tareas[id];

  @override
  Future<String> crearTarea(Tarea tarea) async {
    final id = 'tarea-${_siguienteId++}';
    _tareas[id] = tarea.copyWith(id: id);
    _cambios.add(null);
    return id;
  }

  @override
  Future<void> actualizarTarea(Tarea tarea) async {
    _exigir(tarea.id);
    _tareas[tarea.id] = tarea;
    _cambios.add(null);
  }

  @override
  Future<void> cambiarCompletada(String id, bool completada) async {
    _tareas[id] = _exigir(id).copyWith(completada: completada);
    _cambios.add(null);
  }

  @override
  Future<void> eliminarTarea(String id) async {
    _exigir(id);
    _tareas.remove(id);
    _cambios.add(null);
  }

  Tarea _exigir(String id) {
    final t = _tareas[id];
    if (t == null) throw const TareaRepositoryException('La tarea no existe');
    return t;
  }
}
