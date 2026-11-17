/// Validadores de formularios. Devuelven `null` si el valor es válido
/// o un mensaje de error en español si no lo es (compatibles con
/// `TextFormField.validator`).
class Validators {
  Validators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w.+-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}$',
  );

  static const int longitudMinimaPassword = 6;
  static const int longitudMaximaTitulo = 100;

  static String? email(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'El correo es obligatorio';
    if (!_emailRegExp.hasMatch(texto)) return 'Correo no válido';
    return null;
  }

  static String? password(String? valor) {
    final texto = valor ?? '';
    if (texto.isEmpty) return 'La contraseña es obligatoria';
    if (texto.length < longitudMinimaPassword) {
      return 'La contraseña debe tener al menos $longitudMinimaPassword caracteres';
    }
    return null;
  }

  static String? confirmarPassword(String? valor, String original) {
    if (valor == null || valor.isEmpty) return 'Confirma la contraseña';
    if (valor != original) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? titulo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'El título es obligatorio';
    if (texto.length > longitudMaximaTitulo) {
      return 'El título no puede superar $longitudMaximaTitulo caracteres';
    }
    return null;
  }
}
