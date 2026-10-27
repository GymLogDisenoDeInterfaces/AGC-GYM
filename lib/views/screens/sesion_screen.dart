// Ayoub - 28/10/2026: He maquetado la pantalla de sesión activa integrando RepCounter, gestos y atajos de teclado.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_components/gym_components.dart';
import 'package:provider/provider.dart';

import '../../controllers/sesion_controller.dart';
import '../../data/models/serie.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/serie_dialog.dart';
import '../widgets/serie_ui.dart';
import '../widgets/voz_panel.dart';

/// Pantalla 5: sesión en curso. Los controladores los crea el router.
///
/// Eventos: botón, deslizar para borrar (con deshacer), pulsación larga para
/// editar, micrófono y atajos de teclado (Ctrl+N y Espacio).
class SesionScreen extends StatelessWidget {
  const SesionScreen({super.key});

  Future<void> _nuevaSerie(BuildContext context) async {
    final ctrl = context.read<SesionController>();
    final l = AppLocalizations.of(context);
    if (ctrl.ejercicios.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l.createExerciseFirst)));
      return;
    }
    final serie = await mostrarFormularioSerie(
      context,
      sesionId: ctrl.sesionId,
      ejercicios: ctrl.ejercicios,
    );
    if (serie != null) await ctrl.anadirSerie(serie);
  }

  Future<void> _editarSerie(BuildContext context, Serie serie) async {
    final ctrl = context.read<SesionController>();
    final editada = await mostrarFormularioSerie(
      context,
      sesionId: ctrl.sesionId,
      ejercicios: ctrl.ejercicios,
      existente: serie,
    );
    if (editada != null) await ctrl.editarSerie(editada);
  }

  void _borrarSerie(BuildContext context, Serie serie) {
    final ctrl = context.read<SesionController>();
    final l = AppLocalizations.of(context);
    final mensajes = ScaffoldMessenger.of(context);
    ctrl.eliminarSerie(serie);
    mensajes
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l.setDeleted),
          action: SnackBarAction(
            label: l.undo,
            onPressed: () => ctrl.restaurarSerie(serie),
          ),
        ),
      );
  }

  Future<void> _terminar(BuildContext context) async {
    final ctrl = context.read<SesionController>();
    final l = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final mensajes = ScaffoldMessenger.of(context);
    final guardada = await ctrl.terminar();
    mensajes
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(guardada ? l.sessionSaved : l.emptySessionDiscarded),
        ),
      );
    router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ctrl = context.watch<SesionController>();

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ctrl.descartarSiVacia();
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
              _nuevaSerie(context),
          const SingleActivator(LogicalKeyboardKey.space): () =>
              ctrl.sumarRepUltima(),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l.sessionInProgress),
              actions: [
                IconButton(
                  tooltip: l.openPoseCounter,
                  icon: const Icon(Icons.accessibility_new),
                  onPressed: () async {
                    await context.push('/sesion/${ctrl.sesionId}/pose');
                    if (context.mounted) {
                      context.read<SesionController>().recargarSeries();
                    }
                  },
                ),
                TextButton(
                  onPressed: () => _terminar(context),
                  child: Text(l.finish),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _nuevaSerie(context),
              icon: const Icon(Icons.add),
              label: Text(l.addSet),
            ),
            body: ctrl.cargando
                ? const Center(child: CircularProgressIndicator())
                : ctrl.sesion == null
                    ? EstadoVacio(
                        icono: Icons.error_outline,
                        mensaje: l.sessionNotFound,
                      )
                    : Column(
                        children: [
                          const VozPanel(),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                RepCounter(
                                  count: ctrl.repeticionesTotales,
                                  goal: SesionController.objetivoRepeticiones,
                                  size: 96,
                                  strokeWidth: 9,
                                  label: l.repsUnit,
                                  onGoalReached: () {
                                    ScaffoldMessenger.of(context)
                                      ..clearSnackBars()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(l.sessionGoalReached),
                                        ),
                                      );
                                  },
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    l.sessionRepsGoal,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: ActionChip(
                              avatar: const Icon(Icons.accessibility_new, size: 18),
                              label: const Text('Modo Sensores (Cámara & Pose)'),
                              onPressed: () async {
                                await context.push('/sesion/${ctrl.sesionId}/pose');
                                if (context.mounted) ctrl.recargarSeries();
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ctrl.series.isEmpty
                                ? EstadoVacio(
                                    icono: Icons.playlist_add,
                                    mensaje: l.noSetsYet,
                                  )
                                : ListView.builder(
                                    padding:
                                        const EdgeInsets.only(bottom: 88),
                                    itemCount: ctrl.series.length,
                                    itemBuilder: (context, index) {
                                      final s = ctrl.series[index];
                                      return setTileDeSerie(
                                        l,
                                        s,
                                        onEdit: () =>
                                            _editarSerie(context, s),
                                        onDelete: () =>
                                            _borrarSerie(context, s),
                                      );
                                    },
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              l.shortcutsHint,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
