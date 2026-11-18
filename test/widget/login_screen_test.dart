import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/screens/login_screen.dart';

import '../fakes/fake_auth_repository.dart';
import 'helpers.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('con campos vacíos muestra validaciones y no llama al repo', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      await tester.pumpWidget(envolver(const LoginScreen(), auth: auth));

      await tester.tap(find.byKey(const Key('login_boton')));
      await tester.pump();

      expect(find.text('El correo es obligatorio'), findsOneWidget);
      expect(find.text('La contraseña es obligatoria'), findsOneWidget);
      expect(auth.llamadasIniciarSesion, 0);
    });

    testWidgets('con email inválido y contraseña corta no llama al repo', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      await tester.pumpWidget(envolver(const LoginScreen(), auth: auth));

      await tester.enterText(find.byKey(const Key('login_email')), 'prueba');
      await tester.enterText(find.byKey(const Key('login_password')), '123');
      await tester.tap(find.byKey(const Key('login_boton')));
      await tester.pump();

      expect(find.text('Correo no válido'), findsOneWidget);
      expect(find.textContaining('al menos 6'), findsOneWidget);
      expect(auth.llamadasIniciarSesion, 0);
    });

    testWidgets('con credenciales incorrectas muestra el error en SnackBar', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      await tester.pumpWidget(envolver(const LoginScreen(), auth: auth));

      await tester.enterText(
        find.byKey(const Key('login_email')),
        'prueba1@test.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password')),
        'incorrecta',
      );
      await tester.tap(find.byKey(const Key('login_boton')));
      await tester.pump();

      expect(auth.llamadasIniciarSesion, 1);
      expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
    });
  });
}
