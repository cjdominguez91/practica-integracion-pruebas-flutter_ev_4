# Notificaciones push (FCM) — No aplica

Firebase Cloud Messaging está **fuera del alcance** de TaskFlow:

- Las tareas no tienen fecha de vencimiento ni recordatorios que requieran avisar al usuario.
- No hay interacción entre usuarios (las tareas son personales), así que no hay eventos que notificar.

Por eso los casos **CP-14 a CP-17** (notificación en primer plano, en segundo plano, con la app cerrada y obtención
del token) están marcados como **"No aplica"** en [03-plantilla-pruebas.md](../../03-plantilla-pruebas.md). La
justificación completa está en [01-declaracion-alcance.md](../../01-declaracion-alcance.md).

Si en el futuro se incluye FCM, esta carpeta debe contener las capturas de esos cuatro casos.
