import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('vacío o nulo devuelve error', () {
      expect(Validators.email(''), 'El correo es obligatorio');
      expect(Validators.email('   '), 'El correo es obligatorio');
      expect(Validators.email(null), 'El correo es obligatorio');
    });

    test('formato inválido devuelve error', () {
      for (final e in [
        'prueba',
        'prueba@',
        'prueba@test',
        '@test.com',
        'a b@test.com',
      ]) {
        expect(Validators.email(e), 'Correo no válido', reason: e);
      }
    });

    test('correo válido devuelve null', () {
      expect(Validators.email('prueba1@test.com'), isNull);
      expect(Validators.email('  prueba2@test.com '), isNull);
    });
  });

  group('Validators.password', () {
    test('vacía devuelve error', () {
      expect(Validators.password(''), 'La contraseña es obligatoria');
    });

    test('menos de 6 caracteres devuelve error', () {
      expect(Validators.password('12345'), contains('al menos 6'));
    });

    test('6 o más caracteres es válida', () {
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.confirmarPassword', () {
    test('no coincide devuelve error', () {
      expect(
        Validators.confirmarPassword('abcdef', 'abcdeg'),
        'Las contraseñas no coinciden',
      );
    });

    test('coincide devuelve null', () {
      expect(Validators.confirmarPassword('abcdef', 'abcdef'), isNull);
    });
  });

  group('Validators.titulo', () {
    test('vacío o solo espacios devuelve error', () {
      expect(Validators.titulo(''), 'El título es obligatorio');
      expect(Validators.titulo('   '), 'El título es obligatorio');
    });

    test('demasiado largo devuelve error', () {
      expect(Validators.titulo('a' * 101), contains('100'));
    });

    test('título válido devuelve null', () {
      expect(Validators.titulo('Comprar pan'), isNull);
    });
  });
}
