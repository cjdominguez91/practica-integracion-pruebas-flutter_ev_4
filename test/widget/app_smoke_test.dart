import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/app.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_tarea_repository.dart';

void main() {
  testWidgets('sin sesión la app arranca en Login', (tester) async {
    await tester.pumpWidget(
      TaskFlowApp(
        authRepository: FakeAuthRepository(),
        tareaRepository: FakeTareaRepository(),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('login_boton')), findsOneWidget);
  });

  testWidgets('flujo completo con fakes: login → crear → detalle → completar → '
      'eliminar → logout', (tester) async {
    final auth = FakeAuthRepository()
      ..agregarCuenta('prueba1@test.com', '123456');
    await tester.pumpWidget(
      TaskFlowApp(authRepository: auth, tareaRepository: FakeTareaRepository()),
    );
    await tester.pump();

    // Login
    await tester.enterText(
      find.byKey(const Key('login_email')),
      'prueba1@test.com',
    );
    await tester.enterText(find.byKey(const Key('login_password')), '123456');
    await tester.tap(find.byKey(const Key('login_boton')));
    await tester.pumpAndSettle();
    expect(find.text('No tienes tareas'), findsOneWidget);

    // Crear tarea
    await tester.tap(find.byKey(const Key('home_nueva_tarea')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('form_titulo')), 'Comprar pan');
    await tester.tap(find.byKey(const Key('form_guardar')));
    await tester.pumpAndSettle();
    expect(find.text('Comprar pan'), findsOneWidget);
    expect(find.text('No tienes tareas'), findsNothing);

    // Detalle y marcar como completada
    await tester.tap(find.text('Comprar pan'));
    await tester.pumpAndSettle();
    expect(find.text('Pendiente'), findsOneWidget);
    await tester.tap(find.byKey(const Key('detalle_alternar_completada')));
    await tester.pumpAndSettle();
    expect(find.text('Completada'), findsOneWidget);

    // Eliminar
    await tester.tap(find.byKey(const Key('detalle_eliminar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('detalle_confirmar_eliminar')));
    await tester.pumpAndSettle();
    expect(find.text('No tienes tareas'), findsOneWidget);

    // Logout
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login_boton')), findsOneWidget);
  });
}
