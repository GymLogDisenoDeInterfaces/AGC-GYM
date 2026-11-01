/// Textos de [SetTile], para poder traducirlos sin que el componente dependa de
/// ningún sistema de localización.
///
/// Los valores por defecto están en inglés. La app los sustituye por los
/// textos de sus archivos ARB:
///
/// ```dart
/// SetTileLabels(
///   subtitle: (reps, kg) => '$reps repeticiones × $kg kg',
///   editTooltip: 'Editar',
/// )
/// ```
class SetTileLabels {
  /// Crea los textos del componente. Todos son opcionales.
  const SetTileLabels({
    this.subtitle = _subtituloPorDefecto,
    this.editTooltip = 'Edit',
    this.manual = 'Manual',
    this.voice = 'Voice',
    this.pose = 'Pose',
  });

  /// Construye el subtítulo a partir de las repeticiones y el peso ya formateado.
  final String Function(int reps, String weight) subtitle;

  /// Texto emergente del botón de editar.
  final String editTooltip;

  /// Nombre del origen manual (se usa en la etiqueta semántica).
  final String manual;

  /// Nombre del origen por voz (se usa en la etiqueta semántica).
  final String voice;

  /// Nombre del origen por pose (se usa en la etiqueta semántica).
  final String pose;

  static String _subtituloPorDefecto(int reps, String weight) =>
      '$reps reps × $weight kg';
}
