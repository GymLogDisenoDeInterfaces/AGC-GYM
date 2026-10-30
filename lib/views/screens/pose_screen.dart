// Guillermo - 31/10/2026: Pantalla de pose con cámara en tiempo real, superposición de landmarks, contador y alternativa táctil.
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gym_components/gym_components.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../controllers/pose_controller.dart';
import '../../core/platform_support.dart';
import '../../l10n/app_localizations.dart';
import '../../nui/burpee_analyzer.dart';
import '../../nui/pose_painter.dart';
import '../widgets/serie_ui.dart';

/// Pantalla 6: contador de sentadillas por pose (ML Kit) con aviso de
/// sentadilla incompleta. Todo tiene alternativa táctil (+1 manual).
class PoseScreen extends StatefulWidget {
  const PoseScreen({super.key});

  @override
  State<PoseScreen> createState() => _PoseScreenState();
}

class _PoseScreenState extends State<PoseScreen> {
  final TextEditingController _peso = TextEditingController(text: '0');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l = AppLocalizations.of(context);
    final ctrl = context.read<PoseController>();
    ctrl.avisoIncompleto = l.poseIncomplete;
    ctrl.avisoDominadaIncompleta = l.poseIncompletePullUp;
    ctrl.avisoObjetivo = l.poseGoalReached;
    ctrl.idiomaTts =
        Localizations.localeOf(context).languageCode == 'en' ? 'en-US' : 'es-ES';
  }

  @override
  void dispose() {
    _peso.dispose();
    super.dispose();
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _empezar() async {
    final l = AppLocalizations.of(context);
    final ctrl = context.read<PoseController>();
    if (!esMovil) {
      _aviso(l.poseUnavailable);
      return;
    }
    final permiso = await Permission.camera.request();
    if (!permiso.isGranted) {
      if (mounted) _aviso(l.poseNeedsCamera);
      return;
    }
    await ctrl.empezar();
  }

  Future<void> _guardar() async {
    final l = AppLocalizations.of(context);
    final ctrl = context.read<PoseController>();
    ctrl.setPeso(double.tryParse(_peso.text.replaceAll(',', '.')) ?? 0);
    final guardadas = await ctrl.guardarSerie();
    if (!mounted) return;
    _aviso(guardadas == 0 ? l.poseNothingToSave : l.poseSaved(guardadas));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ctrl = context.watch<PoseController>();
    final tema = Theme.of(context);
    final activo = ctrl.estado == EstadoPose.activo;
    final angulo = ctrl.anguloRodilla;
    final ultimas = ctrl.seriesSesion.reversed.take(3).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.poseTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: SegmentedButton<ModoEjercicioPose>(
              segments: [
                ButtonSegment(
                  value: ModoEjercicioPose.sentadillas,
                  label: Text(l.poseExerciseSquats),
                  icon: const Icon(Icons.fitness_center),
                ),
                ButtonSegment(
                  value: ModoEjercicioPose.burpees,
                  label: Text(l.poseExerciseBurpees),
                  icon: const Icon(Icons.directions_run),
                ),
                ButtonSegment(
                  value: ModoEjercicioPose.dominadas,
                  label: Text(l.poseExercisePullUps),
                  icon: const Icon(Icons.sports_gymnastics),
                ),
              ],
              selected: {ctrl.modo},
              onSelectionChanged: (nuevo) {
                ctrl.cambiarModo(nuevo.first);
              },
            ),
          ),
          const SizedBox(height: 12),
          _VistaCamara(ctrl: ctrl),
          const SizedBox(height: 8),
          if (!esMovil)
            Text(l.poseUnavailable, style: TextStyle(color: tema.colorScheme.outline))
          else if (ctrl.sinCamara)
            Text(l.poseNoCamera, style: TextStyle(color: tema.colorScheme.error))
          else if (ctrl.estado == EstadoPose.error)
            Text(l.poseError, style: TextStyle(color: tema.colorScheme.error))
          else if (!activo)
            Text(l.poseHowTo)
          else if (ctrl.modo == ModoEjercicioPose.sentadillas) ...[
            if (angulo == null)
              Text(l.poseNoBody)
            else
              Text(
                l.poseKneeAngle(angulo.toStringAsFixed(0)),
                style: tema.textTheme.titleMedium,
              ),
            if (ctrl.incompleta)
              Card(
                color: tema.colorScheme.errorContainer,
                child: ListTile(
                  leading: Icon(
                    Icons.warning_amber_rounded,
                    color: tema.colorScheme.onErrorContainer,
                  ),
                  title: Text(
                    l.poseIncomplete,
                    style: TextStyle(color: tema.colorScheme.onErrorContainer),
                  ),
                ),
              ),
          ] else if (ctrl.modo == ModoEjercicioPose.burpees) ...[
            if (ctrl.ratioVertical == null)
              Text(l.poseNoBody)
            else if (ctrl.faseBurpee == BurpeeFase.enSuelo)
              Card(
                color: tema.colorScheme.primaryContainer,
                child: ListTile(
                  leading: Icon(
                    Icons.arrow_upward,
                    color: tema.colorScheme.onPrimaryContainer,
                  ),
                  title: Text(
                    l.poseBurpeePhaseGround,
                    style: TextStyle(
                      color: tema.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              Text(
                l.poseBurpeePhaseStanding,
                style: tema.textTheme.titleMedium,
              ),
          ] else ...[
            if (ctrl.anguloCodo == null)
              Text(l.poseNoBody)
            else
              Text(
                l.poseElbowAngle(ctrl.anguloCodo!.toStringAsFixed(0)),
                style: tema.textTheme.titleMedium,
              ),
            if (ctrl.incompleta)
              Card(
                color: tema.colorScheme.errorContainer,
                child: ListTile(
                  leading: Icon(
                    Icons.warning_amber_rounded,
                    color: tema.colorScheme.onErrorContainer,
                  ),
                  title: Text(
                    l.poseIncompletePullUp,
                    style: TextStyle(color: tema.colorScheme.onErrorContainer),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          Center(
            child: RepCounter(
              count: ctrl.reps,
              goal: ctrl.objetivo,
              size: 170,
              label: l.repsUnit,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (activo)
                FilledButton.tonalIcon(
                  onPressed: ctrl.parar,
                  icon: const Icon(Icons.stop),
                  label: Text(l.poseStop),
                )
              else
                FilledButton.icon(
                  onPressed: ctrl.estado == EstadoPose.iniciando ? null : _empezar,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l.poseStart),
                ),
              OutlinedButton.icon(
                onPressed: ctrl.sumarManual,
                icon: const Icon(Icons.add),
                label: Text(l.poseAddRep),
              ),
              OutlinedButton.icon(
                onPressed: ctrl.reiniciar,
                icon: const Icon(Icons.restart_alt),
                label: Text(l.poseReset),
              ),
              if (activo && ctrl.servicio.hayVariasCamaras)
                IconButton.outlined(
                  tooltip: l.poseFlipCamera,
                  onPressed: ctrl.cambiarCamara,
                  icon: const Icon(Icons.flip_camera_android),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l.poseGoalLabel),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => ctrl.setObjetivo(ctrl.objetivo - 1),
              ),
              Text('${ctrl.objetivo}', style: tema.textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => ctrl.setObjetivo(ctrl.objetivo + 1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _peso,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l.poseWeightLabel,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save_outlined),
              label: Text(l.poseSave),
            ),
          ),
          if (ultimas.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final s in ultimas)
              setTileDeSerie(l, s),
          ],
        ],
      ),
    );
  }
}

class _VistaCamara extends StatelessWidget {
  const _VistaCamara({required this.ctrl});

  final PoseController ctrl;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final camara = ctrl.servicio.camara;
    final lista = esMovil &&
        ctrl.estado == EstadoPose.activo &&
        camara != null &&
        camara.value.isInitialized;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: lista ? 1 / camara.value.aspectRatio : 3 / 4,
        child: lista
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(camara),
                  if (ctrl.ultimoFotograma != null)
                    CustomPaint(
                      painter: PosePainter(
                        pose: ctrl.ultimoFotograma!.pose,
                        imageSize: ctrl.ultimoFotograma!.imageSize,
                        rotation: ctrl.ultimoFotograma!.rotation,
                        lensDirection: ctrl.ultimoFotograma!.lensDirection,
                        colorLinea: tema.colorScheme.primary,
                        colorPunto: tema.colorScheme.tertiary,
                      ),
                    ),
                ],
              )
            : ColoredBox(
                color: tema.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: ctrl.estado == EstadoPose.iniciando
                      ? const CircularProgressIndicator()
                      : Icon(
                          Icons.accessibility_new,
                          size: 96,
                          color: tema.colorScheme.outline,
                        ),
                ),
              ),
      ),
    );
  }
}
