// Guillermo - 27/10/2026: Pantalla de historial con listado cronológico de sesiones realizadas y métricas de volumen.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/historial_controller.dart';
import '../../data/models/sesion.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/resumen_sesion_tile.dart';
import '../widgets/serie_ui.dart';

/// Pantalla 7: historial de sesiones (JOIN + COUNT + SUM).
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HistorialController>().cargar();
    });
  }

  Future<void> _borrar(SesionResumen resumen) async {
    final l = AppLocalizations.of(context);
    final ctrl = context.read<HistorialController>();
    final fecha = fechaLarga(context, resumen.sesion.fecha);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteSessionTitle),
        content: Text(l.deleteSessionQuestion(fecha)),
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
    if (confirmado == true) await ctrl.eliminar(resumen.sesion.id!);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ctrl = context.watch<HistorialController>();

    if (ctrl.cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.items.isEmpty) {
      return EstadoVacio(icono: Icons.history, mensaje: l.noSessions);
    }
    return ListView.builder(
      itemCount: ctrl.items.length,
      itemBuilder: (context, index) {
        final r = ctrl.items[index];
        return ResumenSesionTile(
          resumen: r,
          onTap: () => context.push('/historial/${r.sesion.id}'),
          onDelete: () => _borrar(r),
        );
      },
    );
  }
}
