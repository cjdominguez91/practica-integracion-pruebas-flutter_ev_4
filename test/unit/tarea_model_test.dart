import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/models/tarea.dart';

void main() {
  final fecha = DateTime(2026, 11, 16, 10, 30);
  final tarea = Tarea(
    id: 'abc',
    titulo: 'Estudiar',
    descripcion: 'Repasar Flutter',
    completada: false,
    fechaCreacion: fecha,
    uid: 'uid-1',
  );

  group('Tarea', () {
    test('toMap no incluye el id y guarda la fecha como Timestamp', () {
      final map = tarea.toMap();
      expect(map.containsKey('id'), isFalse);
      expect(map['titulo'], 'Estudiar');
      expect(map['descripcion'], 'Repasar Flutter');
      expect(map['completada'], false);
      expect(map['uid'], 'uid-1');
      expect(map['fechaCreacion'], Timestamp.fromDate(fecha));
    });

    test('fromMap(toMap) reconstruye la misma tarea', () {
      expect(Tarea.fromMap('abc', tarea.toMap()), tarea);
    });

    test('fromMap acepta DateTime y milisegundos como fecha', () {
      final conDate = Tarea.fromMap('x', {'fechaCreacion': fecha});
      final conInt = Tarea.fromMap('x', {
        'fechaCreacion': fecha.millisecondsSinceEpoch,
      });
      expect(conDate.fechaCreacion, fecha);
      expect(conInt.fechaCreacion, fecha);
    });

    test('fromMap con campos faltantes usa valores por defecto', () {
      final t = Tarea.fromMap('vacia', {});
      expect(t.id, 'vacia');
      expect(t.titulo, '');
      expect(t.descripcion, '');
      expect(t.completada, isFalse);
      expect(t.uid, '');
    });

    test('copyWith cambia solo los campos indicados', () {
      final c = tarea.copyWith(completada: true);
      expect(c.completada, isTrue);
      expect(c.titulo, tarea.titulo);
      expect(c.id, tarea.id);
    });
  });
}
