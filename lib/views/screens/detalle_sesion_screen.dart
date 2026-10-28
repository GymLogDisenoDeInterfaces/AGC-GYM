// Guillermo - 28/10/2026: Pantalla de detalle de sesión que integra SetTile y RepCounter con datos de SQLite.
import 'package:flutter/material.dart';
import 'package:gym_components/gym_components.dart';
import 'package:provider/provider.dart';

import '../../controllers/historial_controller.dart';
import '../../controllers/sesion_controller.dart';
import '../../core/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/serie_ui.dart';

/// Pantalla 8: detalle de una sesión pasada (series con SetTile y RepCounter).
class DetalleSesionScreen extends StatelessWidget {
  const DetalleSesionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ctrl = context.watch<DetalleSesionController>();
    final resumen = ctrl.resumen;
    final repeticiones = ctrl.series.fold<int>(0, (s, e) => s + e.reps);

    return Scaffold(
      appBar: AppBar(title: Text(l.sessionDetail)),
      body: ctrl.cargando
          ? const Center(child: CircularProgressIndicator())
          : resumen == null
              ? EstadoVacio(
                  icono: Icons.error_outline,
                  mensaje: l.sessionNotFound,
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          RepCounter(
                            count: repeticiones,
                            goal: SesionController.objetivoRepeticiones,
                            size: 104,
                            strokeWidth: 10,
                            label: l.repsUnit,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fechaLarga(context, resumen.sesion.fecha),
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l.nSets(resumen.numSeries)} · '
                                  '${formatearVolumen(resumen.volumen, idiomaActivo(context))}',
                                ),
                                if (resumen.sesion.duracionMin > 0)
                                  Text(
                                    l.minutesShort(resumen.sesion.duracionMin),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ctrl.series.isEmpty
                          ? EstadoVacio(
                              icono: Icons.playlist_remove,
                              mensaje: l.sessionWithoutSets,
                            )
                          : ListView.builder(
                              itemCount: ctrl.series.length,
                              itemBuilder: (context, index) =>
                                  setTileDeSerie(l, ctrl.series[index]),
                            ),
                    ),
                  ],
                ),
    );
  }
}
