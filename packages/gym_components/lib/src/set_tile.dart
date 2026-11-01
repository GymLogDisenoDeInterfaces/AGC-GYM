// Guillermo - 02/11/2026: Componente visual propio SetTile para representar series con soporte para Dismissible, onEdit y onDelete.
import 'package:flutter/material.dart';

import 'gym_component.dart';
import 'set_origin.dart';
import 'set_tile_labels.dart';

/// Fila que representa una serie de entrenamiento.
///
/// Muestra el icono del [origen], el nombre del [ejercicio] y un subtítulo con
/// las repeticiones y el peso.
///
/// Si [onDelete] no es nulo, la fila se envuelve en un [Dismissible]: al
/// deslizarla hacia la izquierda se llama a [onDelete]. En ese caso hay que
/// pasar también [dismissKey], una clave única por fila.
///
/// Ejemplo:
///
/// ```dart
/// SetTile(
///   dismissKey: ValueKey('serie-${serie.id}'),
///   ejercicio: 'Press banca',
///   reps: 10,
///   pesoKg: 62.5,
///   origen: SetOrigin.manual,
///   onEdit: () => editar(serie),
///   onDelete: () => borrar(serie),
/// )
/// ```
class SetTile extends StatelessWidget implements GymComponent {
  /// Crea una fila de serie.
  ///
  /// [reps] debe ser mayor que 0 y [pesoKg] no puede ser negativo. Si se pasa
  /// [onDelete] es obligatorio pasar [dismissKey].
  const SetTile({
    super.key,
    required this.ejercicio,
    required this.reps,
    required this.pesoKg,
    this.origen = SetOrigin.manual,
    this.onEdit,
    this.onDelete,
    this.dismissKey,
    this.labels = const SetTileLabels(),
  })  : assert(reps > 0, 'reps debe ser mayor que 0'),
        assert(pesoKg >= 0, 'pesoKg no puede ser negativo'),
        assert(
          onDelete == null || dismissKey != null,
          'dismissKey es obligatorio cuando se pasa onDelete',
        );

  /// Nombre del ejercicio.
  final String ejercicio;

  /// Repeticiones de la serie. Debe ser mayor que 0.
  final int reps;

  /// Peso en kilogramos. Por defecto no hay límite superior, pero no puede ser
  /// negativo.
  final double pesoKg;

  /// Cómo se registró la serie. Por defecto [SetOrigin.manual].
  final SetOrigin origen;

  /// Se llama cuando el usuario quiere editar la serie: pulsación larga sobre
  /// la fila o toque en el botón de editar. Si es nulo, la fila no es editable.
  final VoidCallback? onEdit;

  /// Se llama cuando el usuario desliza la fila para borrarla. Si es nulo, la
  /// fila no se puede borrar deslizando.
  final VoidCallback? onDelete;

  /// Clave del [Dismissible] interno. Obligatoria si [onDelete] no es nulo.
  final Key? dismissKey;

  /// Textos del componente, para traducirlos.
  final SetTileLabels labels;

  @override
  String get semanticLabel {
    final nombreOrigen = switch (origen) {
      SetOrigin.manual => labels.manual,
      SetOrigin.voice => labels.voice,
      SetOrigin.pose => labels.pose,
    };
    return '$ejercicio, ${labels.subtitle(reps, _formatearPeso(pesoKg))}, '
        '$nombreOrigen';
  }

  static String _formatearPeso(double kg) =>
      kg == kg.roundToDouble() ? kg.toInt().toString() : kg.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final fila = Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: ListTile(
        leading: CircleAvatar(child: Icon(origen.icon)),
        title: Text(ejercicio, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(labels.subtitle(reps, _formatearPeso(pesoKg))),
        trailing: onEdit == null
            ? null
            : IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: labels.editTooltip,
                onPressed: onEdit,
              ),
        onLongPress: onEdit,
      ),
    );

    if (onDelete == null) return fila;

    final colores = Theme.of(context).colorScheme;
    return Dismissible(
      key: dismissKey!,
      direction: DismissDirection.endToStart,
      background: Container(
        color: colores.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: colores.onErrorContainer),
      ),
      onDismissed: (_) => onDelete!(),
      child: fila,
    );
  }
}
