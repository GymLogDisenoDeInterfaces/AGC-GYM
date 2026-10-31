// Ayoub - 02/11/2026: Componente visual propio RepCounter con animación de progreso circular, validaciones assert y evento onGoalReached.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'gym_component.dart';

/// Contador circular de repeticiones con objetivo.
///
/// Dibuja un arco que se llena de forma animada según [count] respecto a
/// [goal], con el número de repeticiones en el centro.
///
/// El evento [onGoalReached] se dispara **una sola vez** cada vez que [count]
/// pasa de estar por debajo de [goal] a alcanzarlo o superarlo. Se llama justo
/// después del fotograma en el que cambia el valor, así que es seguro mostrar un
/// `SnackBar` o llamar a `setState` desde él.
///
/// Ejemplo:
///
/// ```dart
/// RepCounter(
///   count: repeticiones,
///   goal: 10,
///   label: 'reps',
///   onGoalReached: () => hablar('Objetivo alcanzado'),
/// )
/// ```
class RepCounter extends StatefulWidget implements GymComponent {
  /// Crea un contador.
  ///
  /// [count] no puede ser negativo, [goal] debe ser mayor que 0 y [size] y
  /// [strokeWidth] deben ser positivos.
  const RepCounter({
    super.key,
    required this.count,
    this.goal = 10,
    this.size = 160,
    this.strokeWidth = 12,
    this.label = 'reps',
    this.color,
    this.animationDuration = const Duration(milliseconds: 500),
    this.onGoalReached,
  })  : assert(goal > 0, 'goal debe ser mayor que 0'),
        assert(count >= 0, 'count no puede ser negativo'),
        assert(size > 0, 'size debe ser mayor que 0'),
        assert(strokeWidth > 0, 'strokeWidth debe ser mayor que 0');

  /// Repeticiones realizadas. No puede ser negativo.
  final int count;

  /// Objetivo de repeticiones. Por defecto 10. Debe ser mayor que 0.
  final int goal;

  /// Diámetro del círculo en píxeles lógicos. Por defecto 160.
  final double size;

  /// Grosor del arco. Por defecto 12.
  final double strokeWidth;

  /// Texto bajo el número, por ejemplo "reps". Sirve para traducirlo.
  final String label;

  /// Color del arco. Si es nulo se usa el color primario del tema.
  final Color? color;

  /// Duración de la animación del arco. Por defecto medio segundo.
  final Duration animationDuration;

  /// Se llama una vez cuando [count] alcanza [goal] viniendo de un valor menor.
  final VoidCallback? onGoalReached;

  @override
  String get semanticLabel => '$count / $goal $label';

  @override
  State<RepCounter> createState() => _RepCounterState();
}

class _RepCounterState extends State<RepCounter> {
  @override
  void didUpdateWidget(RepCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    final antesCumplido = oldWidget.count >= oldWidget.goal;
    final ahoraCumplido = widget.count >= widget.goal;
    if (!antesCumplido && ahoraCumplido) {
      // Se avisa después del fotograma para poder usar setState o SnackBar.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onGoalReached?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final fraccion = (widget.count / widget.goal).clamp(0.0, 1.0);
    final colorArco = widget.color ?? tema.colorScheme.primary;

    return Semantics(
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: fraccion),
          duration: widget.animationDuration,
          curve: Curves.easeOutCubic,
          builder: (context, progreso, _) => CustomPaint(
            painter: _ArcPainter(
              progreso: progreso,
              colorPista: tema.colorScheme.surfaceContainerHighest,
              colorArco: colorArco,
              grosor: widget.strokeWidth,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.count}',
                    style: tema.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/ ${widget.goal} ${widget.label}',
                    style: tema.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.progreso,
    required this.colorPista,
    required this.colorArco,
    required this.grosor,
  });

  final double progreso;
  final Color colorPista;
  final Color colorArco;
  final double grosor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(grosor / 2);

    final pista = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..color = colorPista;
    canvas.drawArc(rect, 0, 2 * math.pi, false, pista);

    if (progreso <= 0) return;
    final arco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round
      ..color = colorArco;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progreso, false, arco);
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progreso != progreso ||
      old.colorPista != colorPista ||
      old.colorArco != colorArco ||
      old.grosor != grosor;
}
