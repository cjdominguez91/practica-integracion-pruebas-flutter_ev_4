import 'package:flutter/material.dart';

/// Muestra un SnackBar con [texto]. Usar con un messenger obtenido antes
/// de un `await` para no usar el `BuildContext` tras un hueco asíncrono.
void mostrarMensaje(ScaffoldMessengerState messenger, String texto) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}

/// Formato `dd/MM/yyyy HH:mm` sin depender de `intl`.
String formatearFecha(DateTime fecha) {
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} '
      '${dos(fecha.hour)}:${dos(fecha.minute)}';
}
