import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/models/tarea.dart';
import 'package:practica_integracion_pruebas_flutter/repositories/auth_repository.dart';
import 'package:practica_integracion_pruebas_flutter/screens/home_screen.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_tarea_repository.dart';
import 'helpers.dart';

const _usuario = UsuarioApp(uid: 'uid-1', email: 'prueba1@test.com');

Tarea _tarea(String id, String titulo, {String uid = 'uid-1', int dia = 1}) =>
    Tarea(
      id: id,
      titulo: titulo,
      descripcion: '',
      completada: false,
      fechaCreacion: DateTime(2026, 11, dia),
      uid: uid,
    );

void main() {
  group('HomeScreen', () {
    testWidgets('mientras carga muestra el indicador de progreso', (
      tester,
    ) async {
      await tester.pumpWidget(
        envolver(
          const HomeScreen(usuario: _usuario),
          tareas: FakeTareaRepository(),
        ),
      );

      // Primer frame: el stream todavía no ha emitido.
      expect(find.byKey(const Key('home_cargando')), findsOneWidget);
      await tester.pump();
      expect(find.byKey(const Key('home_cargando')), findsNothing);
    });

    testWidgets('con lista vacía muestra "No tienes tareas"', (tester) async {
      await tester.pumpWidget(
        envolver(
          const HomeScreen(usuario: _usuario),
          tareas: FakeTareaRepository(),
        ),
      );
      await tester.pump();

      expect(find.text('No tienes tareas'), findsOneWidget);
      expect(find.byKey(const Key('home_lista')), findsNothing);
    });

    testWidgets('con datos muestra los títulos (solo del usuario)', (
      tester,
    ) async {
      final repo = FakeTareaRepository(
        iniciales: [
          _tarea('1', 'Comprar pan', dia: 1),
          _tarea('2', 'Estudiar Flutter', dia: 2),
          _tarea('3', 'Tarea de otro usuario', uid: 'uid-2'),
        ],
      );
      await tester.pumpWidget(
        envolver(const HomeScreen(usuario: _usuario), tareas: repo),
      );
      await tester.pump();

      expect(find.text('Comprar pan'), findsOneWidget);
      expect(find.text('Estudiar Flutter'), findsOneWidget);
      expect(find.text('Tarea de otro usuario'), findsNothing);
      expect(find.text('No tienes tareas'), findsNothing);
    });

    testWidgets('si falla la carga muestra el estado de error', (tester) async {
      await tester.pumpWidget(
        envolver(
          const HomeScreen(usuario: _usuario),
          tareas: FakeTareaRepository(fallarAlCargar: true),
        ),
      );
      await tester.pump();

      expect(find.text('Sin conexión / error al cargar'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('el botón de cerrar sesión llama al repositorio', (
      tester,
    ) async {
      final auth = FakeAuthRepository(usuarioInicial: _usuario);
      await tester.pumpWidget(
        envolver(const HomeScreen(usuario: _usuario), auth: auth),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pump();

      expect(auth.llamadasCerrarSesion, 1);
      expect(auth.usuarioActual, isNull);
    });
  });
}
