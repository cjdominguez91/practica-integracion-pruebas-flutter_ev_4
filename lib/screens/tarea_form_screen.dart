import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tarea.dart';
import '../repositories/auth_repository.dart';
import '../repositories/tarea_repository.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';

/// Formulario para crear (tarea == null) o editar una tarea.
/// Al guardar hace `pop(true)`.
class TareaFormScreen extends StatefulWidget {
  final Tarea? tarea;

  const TareaFormScreen({super.key, this.tarea});

  bool get esEdicion => tarea != null;

  @override
  State<TareaFormScreen> createState() => _TareaFormScreenState();
}

class _TareaFormScreenState extends State<TareaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descripcionCtrl;
  late bool _completada;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.tarea?.titulo ?? '');
    _descripcionCtrl = TextEditingController(
      text: widget.tarea?.descripcion ?? '',
    );
    _completada = widget.tarea?.completada ?? false;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando) return; // Evita crear la tarea dos veces.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final repo = context.read<TareaRepository>();
    final auth = context.read<AuthRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final titulo = _tituloCtrl.text.trim();
    final descripcion = _descripcionCtrl.text.trim();

    setState(() => _guardando = true);
    try {
      final original = widget.tarea;
      if (original == null) {
        final uid = auth.usuarioActual?.uid;
        if (uid == null) {
          mostrarMensaje(messenger, 'Tu sesión expiró. Inicia sesión de nuevo');
          return;
        }
        await repo.crearTarea(
          Tarea(
            id: '',
            titulo: titulo,
            descripcion: descripcion,
            completada: false,
            fechaCreacion: DateTime.now(),
            uid: uid,
          ),
        );
        mostrarMensaje(messenger, 'Tarea creada');
      } else {
        await repo.actualizarTarea(
          original.copyWith(
            titulo: titulo,
            descripcion: descripcion,
            completada: _completada,
          ),
        );
        mostrarMensaje(messenger, 'Tarea actualizada');
      }
      navigator.pop(true);
    } on TareaRepositoryException catch (e) {
      mostrarMensaje(messenger, e.mensaje);
    } catch (e) {
      mostrarMensaje(messenger, 'Error inesperado al guardar la tarea');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.esEdicion ? 'Editar tarea' : 'Nueva tarea'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                key: const Key('form_titulo'),
                controller: _tituloCtrl,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLength: Validators.longitudMaximaTitulo,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.titulo,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('form_descripcion'),
                controller: _descripcionCtrl,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              if (widget.esEdicion) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  key: const Key('form_completada'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Completada'),
                  value: _completada,
                  onChanged: _guardando
                      ? null
                      : (v) => setState(() => _completada = v),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('form_guardar'),
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
