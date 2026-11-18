import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/models/tarea.dart';
import 'package:practica_integracion_pruebas_flutter/repositories/auth_repository.dart';
import 'package:practica_integracion_pruebas_flutter/screens/tarea_form_screen.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_tarea_repository.dart';
import 'helpers.dart';

const _usuario = UsuarioApp(uid: 'uid-1', email: 'prueba1@test.com');

void main() {
  group('TareaFormScreen', () {
    testWidgets('con título vacío muestra error y no crea la tarea', (
      tester,
    ) async {
      final repo = FakeTareaRepository();
      await tester.pumpWidget(
        envolver(
          const TareaFormScreen(),
          auth: FakeAuthRepository(usuarioInicial: _usuario),
          tareas: repo,
        ),
      );

      await tester.enterText(find.byKey(const Key('form_titulo')), '   ');
      await tester.tap(find.byKey(const Key('form_guardar')));
      await tester.pump();

      expect(find.text('El título es obligatorio'), findsOneWidget);
      expect(await repo.observarTareas('uid-1').first, isEmpty);
    });

    testWidgets('con título válido crea la tarea con el uid del usuario', (
      tester,
    ) async {
      final repo = FakeTareaRepository();
      await tester.pumpWidget(
        envolver(
          const TareaFormScreen(),
          auth: FakeAuthRepository(usuarioInicial: _usuario),
          tareas: repo,
        ),
      );

      await tester.enterText(
        find.byKey(const Key('form_titulo')),
        '  Comprar pan  ',
      );
      await tester.tap(find.byKey(const Key('form_guardar')));
      await tester.pump();

      final tareas = await repo.observarTareas('uid-1').first;
      expect(tareas, hasLength(1));
      expect(tareas.single.titulo, 'Comprar pan');
      expect(tareas.single.uid, 'uid-1');
      expect(tareas.single.completada, isFalse);
    });

    testWidgets('en edición precarga los datos de la tarea', (tester) async {
      final tarea = Tarea(
        id: 't1',
        titulo: 'Estudiar',
        descripcion: 'Repasar widgets',
        completada: true,
        fechaCreacion: DateTime(2026, 11, 16),
        uid: 'uid-1',
      );
      await tester.pumpWidget(
        envolver(
          TareaFormScreen(tarea: tarea),
          auth: FakeAuthRepository(usuarioInicial: _usuario),
          tareas: FakeTareaRepository(iniciales: [tarea]),
        ),
      );

      expect(find.text('Editar tarea'), findsOneWidget);
      expect(find.text('Estudiar'), findsOneWidget);
      expect(find.text('Repasar widgets'), findsOneWidget);
      final interruptor = tester.widget<SwitchListTile>(
        find.byKey(const Key('form_completada')),
      );
      expect(interruptor.value, isTrue);
    });
  });
}
