import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/app.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_tarea_repository.dart';

void main() {
  testWidgets('TaskFlowApp arranca con repositorios fake sin Firebase', (
    tester,
  ) async {
    await tester.pumpWidget(
      TaskFlowApp(
        authRepository: FakeAuthRepository(),
        tareaRepository: FakeTareaRepository(),
      ),
    );

    expect(find.text('TaskFlow'), findsOneWidget);
  });
}
