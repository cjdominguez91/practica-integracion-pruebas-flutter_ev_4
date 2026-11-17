import 'package:cloud_firestore/cloud_firestore.dart';

/// Recurso principal de TaskFlow: una tarea personal de un usuario.
class Tarea {
  final String id;
  final String titulo;
  final String descripcion;
  final bool completada;
  final DateTime fechaCreacion;

  /// UID del usuario dueño de la tarea (Firebase Auth).
  final String uid;

  const Tarea({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.completada,
    required this.fechaCreacion,
    required this.uid,
  });

  /// Crea una tarea a partir de un documento de Firestore.
  ///
  /// Es tolerante con datos incompletos: los campos faltantes toman
  /// valores por defecto en lugar de lanzar una excepción.
  factory Tarea.fromMap(String id, Map<String, dynamic> map) {
    return Tarea(
      id: id,
      titulo: (map['titulo'] as String?) ?? '',
      descripcion: (map['descripcion'] as String?) ?? '',
      completada: (map['completada'] as bool?) ?? false,
      fechaCreacion: _leerFecha(map['fechaCreacion']),
      uid: (map['uid'] as String?) ?? '',
    );
  }

  /// Convierte la tarea a un mapa para guardarla en Firestore.
  /// El `id` no se incluye porque es el ID del documento.
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'completada': completada,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'uid': uid,
    };
  }

  Tarea copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    bool? completada,
    DateTime? fechaCreacion,
    String? uid,
  }) {
    return Tarea(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      completada: completada ?? this.completada,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      uid: uid ?? this.uid,
    );
  }

  static DateTime _leerFecha(Object? valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    if (valor is int) return DateTime.fromMillisecondsSinceEpoch(valor);
    if (valor is String) return DateTime.tryParse(valor) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      other is Tarea &&
      other.id == id &&
      other.titulo == titulo &&
      other.descripcion == descripcion &&
      other.completada == completada &&
      other.fechaCreacion == fechaCreacion &&
      other.uid == uid;

  @override
  int get hashCode =>
      Object.hash(id, titulo, descripcion, completada, fechaCreacion, uid);

  @override
  String toString() =>
      'Tarea(id: $id, titulo: $titulo, completada: $completada, uid: $uid)';
}
