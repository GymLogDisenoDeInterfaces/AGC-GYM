// Carlos - 27/10/2026: Pantalla de detalle de rutina con listado de ejercicios y botón para iniciar la sesión directamente.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/rutinas_controller.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/serie_ui.dart';

/// Pantalla 3: detalle de una rutina. El controlador lo crea el router.
class RutinaDetalleScreen extends StatelessWidget {
  const RutinaDetalleScreen({super.key});

  Future<void> _empezar(BuildContext context) async {
    final ctrl = context.read<RutinaDetalleController>();
    final router = GoRouter.of(context);
    final rutinaId = ctrl.rutinaId;
    final id = await ctrl.empezarSesion();
    router.go('/');
    await router.push('/sesion/$id?rutina=$rutinaId');
  }

  Future<void> _borrar(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final ctrl = context.read<RutinaDetalleController>();
    final router = GoRouter.of(context);
    final nombre = ctrl.rutina?.nombre ?? '';
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteRoutineTitle),
        content: Text(l.deleteRoutineQuestion(nombre)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    await ctrl.eliminar();
    router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ctrl = context.watch<RutinaDetalleController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(ctrl.rutina?.nombre ?? l.routineFallbackTitle),
        actions: [
          if (ctrl.rutina != null)
            IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _borrar(context),
            ),
        ],
      ),
      body: ctrl.cargando
          ? const Center(child: CircularProgressIndicator())
          : ctrl.rutina == null
              ? EstadoVacio(
                  icono: Icons.error_outline,
                  mensaje: l.routineNotFound,
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: ctrl.ejercicios.length,
                        itemBuilder: (context, index) {
                          final e = ctrl.ejercicios[index];
                          return ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(e.nombre),
                            subtitle: Text(nombreGrupo(l, e.grupoMuscular)),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _empezar(context),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l.startWithRoutine),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
