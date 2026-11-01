import 'package:flutter/material.dart';

/// Forma en la que se registró una serie.
///
/// Cada origen tiene su propio icono, que [SetTile] muestra a la izquierda.
///
/// ```dart
/// final icono = SetOrigin.voice.icon;
/// ```
enum SetOrigin {
  /// Introducida a mano con el formulario.
  manual(Icons.touch_app_outlined),

  /// Dictada por voz.
  voice(Icons.mic_none),

  /// Contada con la cámara (detección de pose).
  pose(Icons.accessibility_new);

  /// Crea un origen con su icono.
  const SetOrigin(this.icon);

  /// Icono que representa este origen.
  final IconData icon;
}
