import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tarea.dart';
import '../repositories/tarea_repository.dart';
import '../rutas.dart';
import '../utils/ui.dart';

/// Detalle de una tarea: permite editarla, marcarla como completada
/// o pendiente, y eliminarla.
class TareaDetalleScreen extends StatefulWidget {
  final String tareaId;

  const TareaDetalleScreen({super.key, required this.tareaId});

  @override
  State<TareaDetalleScreen> createState() => _TareaDetalleScreenState();
}

class _TareaDetalleScreenState extends State<TareaDetalleScreen> {
  Tarea? _tarea;
  String? _error;
  bool _cargando = true;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final repo = context.read<TareaRepository>();
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final tarea = await repo.obtenerTarea(widget.tareaId);
      if (!mounted) return;
      setState(() {
        _tarea = tarea;
        _error = tarea == null ? 'La tarea no existe o fue eliminada' : null;
      });
    } on TareaRepositoryException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (e) {
      if (mounted) setState(() => _error = 'Error inesperado al cargar');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _editar() async {
    final resultado = await Navigator.pushNamed(
      context,
      Rutas.formulario,
      arguments: _tarea,
    );
    if (resultado == true && mounted) await _cargar();
  }

  Future<void> _alternarCompletada() async {
    final tarea = _tarea;
    if (tarea == null || _procesando) return;
    final repo = context.read<TareaRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final nuevoValor = !tarea.completada;
    setState(() => _procesando = true);
    try {
      await repo.cambiarCompletada(tarea.id, nuevoValor);
      if (!mounted) return;
      setState(() => _tarea = tarea.copyWith(completada: nuevoValor));
      mostrarMensaje(
        messenger,
        nuevoValor ? 'Tarea completada' : 'Tarea marcada como pendiente',
      );
    } on TareaRepositoryException catch (e) {
      mostrarMensaje(messenger, e.mensaje);
    } catch (e) {
      mostrarMensaje(messenger, 'No se pudo actualizar la tarea');
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _eliminar() async {
    final tarea = _tarea;
    if (tarea == null || _procesando) return;
    final repo = context.read<TareaRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Seguro que quieres eliminar "${tarea.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('detalle_confirmar_eliminar'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    setState(() => _procesando = true);
    try {
      await repo.eliminarTarea(tarea.id);
      navigator.pop();
      mostrarMensaje(messenger, 'Tarea eliminada');
    } on TareaRepositoryException catch (e) {
      mostrarMensaje(messenger, e.mensaje);
    } catch (e) {
      mostrarMensaje(messenger, 'No se pudo eliminar la tarea');
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tarea = _tarea;
    final hayTarea = tarea != null && _error == null && !_cargando;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de tarea'),
        actions: [
          if (hayTarea) ...[
            IconButton(
              key: const Key('detalle_editar'),
              tooltip: 'Editar',
              icon: const Icon(Icons.edit),
              onPressed: _procesando ? null : _editar,
            ),
            IconButton(
              key: const Key('detalle_eliminar'),
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete_outline),
              onPressed: _procesando ? null : _eliminar,
            ),
          ],
        ],
      ),
      body: _construirCuerpo(context),
    );
  }

  Widget _construirCuerpo(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _cargar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final tarea = _tarea!;
    final tema = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(tarea.titulo, style: tema.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: Icon(
                tarea.completada ? Icons.check_circle : Icons.schedule,
                size: 18,
              ),
              label: Text(tarea.completada ? 'Completada' : 'Pendiente'),
            ),
            Chip(
              avatar: const Icon(Icons.calendar_today, size: 18),
              label: Text(formatearFecha(tarea.fechaCreacion)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Descripción', style: tema.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          tarea.descripcion.isEmpty ? 'Sin descripción' : tarea.descripcion,
          style: tarea.descripcion.isEmpty
              ? tema.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: tema.colorScheme.outline,
                )
              : tema.textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          key: const Key('detalle_alternar_completada'),
          onPressed: _procesando ? null : _alternarCompletada,
          icon: Icon(tarea.completada ? Icons.undo : Icons.check),
          label: Text(
            tarea.completada
                ? 'Marcar como pendiente'
                : 'Marcar como completada',
          ),
        ),
      ],
    );
  }
}
