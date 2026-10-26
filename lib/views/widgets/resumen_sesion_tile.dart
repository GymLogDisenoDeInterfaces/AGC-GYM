import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/models/sesion.dart';
import '../../l10n/app_localizations.dart';
import 'serie_ui.dart';

/// Fila del historial: fecha, nº de series (COUNT) y volumen (SUM).
class ResumenSesionTile extends StatelessWidget {
  const ResumenSesionTile({
    super.key,
    required this.resumen,
    this.onTap,
    this.onDelete,
  });

  final SesionResumen resumen;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final duracion = resumen.sesion.duracionMin > 0
        ? ' · ${l.minutesShort(resumen.sesion.duracionMin)}'
        : '';
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.fitness_center_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 22,
        ),
      ),
      title: Text(
        fechaLarga(context, resumen.sesion.fecha),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${l.nSets(resumen.numSeries)} · '
        '${formatearVolumen(resumen.volumen, idiomaActivo(context))}$duracion',
      ),
      trailing: onDelete == null
          ? const Icon(Icons.chevron_right)
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l.delete,
              onPressed: onDelete,
            ),
      onTap: onTap,
    );
  }
}
