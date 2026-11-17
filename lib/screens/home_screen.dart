import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tarea.dart';
import '../repositories/auth_repository.dart';
import '../repositories/tarea_repository.dart';
import '../rutas.dart';
import '../utils/ui.dart';

/// Lista de tareas del usuario con estados explícitos:
/// cargando, error, vacío y con datos.
class HomeScreen extends StatefulWidget {
  final UsuarioApp usuario;

  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<List<Tarea>> _tareas;

  @override
  void initState() {
    super.initState();
    _suscribir();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.usuario.uid != widget.usuario.uid) _suscribir();
  }

  void _suscribir() {
    _tareas = context.read<TareaRepository>().observarTareas(
      widget.usuario.uid,
    );
  }

  void _reintentar() => setState(_suscribir);

  Future<void> _cerrarSesion() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AuthRepository>().cerrarSesion();
      // AuthGate detecta el cierre y muestra Login.
    } on AuthException catch (e) {
      mostrarMensaje(messenger, e.mensaje);
    } catch (e) {
      mostrarMensaje(messenger, 'No se pudo cerrar sesión');
    }
  }

  Future<void> _cambiarCompletada(Tarea tarea, bool completada) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<TareaRepository>().cambiarCompletada(
        tarea.id,
        completada,
      );
    } on TareaRepositoryException catch (e) {
      mostrarMensaje(messenger, e.mensaje);
    } catch (e) {
      mostrarMensaje(messenger, 'No se pudo actualizar la tarea');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tareas'),
        actions: [
          IconButton(
            key: const Key('home_cerrar_sesion'),
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
        bottom: widget.usuario.email == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    widget.usuario.email!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('home_nueva_tarea'),
        onPressed: () => Navigator.pushNamed(context, Rutas.formulario),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
      body: StreamBuilder<List<Tarea>>(
        stream: _tareas,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _EstadoError(onReintentar: _reintentar);
          }
          if (!snapshot.hasData) {
            return const Center(
              key: Key('home_cargando'),
              child: CircularProgressIndicator(),
            );
          }
          final tareas = snapshot.data!;
          if (tareas.isEmpty) return const _EstadoVacio();
          return ListView.separated(
            key: const Key('home_lista'),
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: tareas.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final tarea = tareas[i];
              return ListTile(
                key: Key('tarea_${tarea.id}'),
                leading: Checkbox(
                  value: tarea.completada,
                  onChanged: (v) => _cambiarCompletada(tarea, v ?? false),
                ),
                title: Text(
                  tarea.titulo,
                  style: tarea.completada
                      ? const TextStyle(decoration: TextDecoration.lineThrough)
                      : null,
                ),
                subtitle: tarea.descripcion.isEmpty
                    ? null
                    : Text(
                        tarea.descripcion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(
                  context,
                  Rutas.detalle,
                  arguments: tarea.id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('home_vacio'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No tienes tareas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text('Pulsa "Nueva tarea" para crear la primera.'),
          ],
        ),
      ),
    );
  }
}

class _EstadoError extends StatelessWidget {
  final VoidCallback onReintentar;

  const _EstadoError({required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('home_error'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Sin conexión / error al cargar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
