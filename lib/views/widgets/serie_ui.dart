import 'package:flutter/material.dart';
import 'package:gym_components/gym_components.dart';

import '../../core/formatters.dart';
import '../../data/models/serie.dart';
import '../../l10n/app_localizations.dart';

/// Traduce el origen guardado en SQLite al del paquete de componentes.
SetOrigin origenDeSerie(SerieOrigen o) => switch (o) {
      SerieOrigen.manual => SetOrigin.manual,
      SerieOrigen.voz => SetOrigin.voice,
      SerieOrigen.pose => SetOrigin.pose,
    };

/// Textos de SetTile en el idioma activo, con soporte de RIR.
SetTileLabels etiquetasSetTile(AppLocalizations l, {int? rir}) => SetTileLabels(
      subtitle: (reps, kg) {
        final base = l.setSubtitle(reps, kg);
        if (rir == null) return base;
        return rir == 0 ? '$base · RIR 0 (Fallo)' : '$base · RIR $rir';
      },
      editTooltip: l.editTooltip,
      manual: l.originManual,
      voice: l.originVoice,
      pose: l.originPose,
    );

/// Un SetTile a partir de una [Serie] (lo usan Sesión, Detalle y Pose).
SetTile setTileDeSerie(
  AppLocalizations l,
  Serie serie, {
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  return SetTile(
    key: ValueKey('tile-${serie.id}'),
    ejercicio: serie.ejercicioNombre ?? '#${serie.ejercicioId}',
    reps: serie.reps,
    pesoKg: serie.pesoKg,
    origen: origenDeSerie(serie.origen),
    onEdit: onEdit,
    onDelete: onDelete,
    dismissKey: onDelete == null ? null : ValueKey('serie-${serie.id}'),
    labels: etiquetasSetTile(l, rir: serie.rir),
  );
}

/// Nombre del grupo muscular traducido (la BD guarda el nombre en español).
String nombreGrupo(AppLocalizations l, String grupo) => switch (grupo) {
      'Pecho' => l.groupChest,
      'Espalda' => l.groupBack,
      'Pierna' => l.groupLegs,
      'Hombro' => l.groupShoulders,
      'Brazo' => l.groupArms,
      'Core' => l.groupCore,
      _ => grupo,
    };

/// Color característico del grupo muscular (estilo fitness profesional).
Color colorGrupo(String grupo, {bool oscuro = true}) => switch (grupo) {
      'Pecho' => oscuro ? const Color(0xFFFF5252) : const Color(0xFFD32F2F),
      'Espalda' => oscuro ? const Color(0xFF448AFF) : const Color(0xFF1976D2),
      'Pierna' => oscuro ? const Color(0xFFFFAB00) : const Color(0xFFF57C00),
      'Hombro' => oscuro ? const Color(0xFF00E676) : const Color(0xFF2E7D32),
      'Brazo' => oscuro ? const Color(0xFFE040FB) : const Color(0xFF8E24AA),
      'Core' => oscuro ? const Color(0xFFFF6E40) : const Color(0xFFE64A19),
      _ => oscuro ? const Color(0xFF0ABAB5) : const Color(0xFF00897B),
    };

/// Icono descriptivo del grupo muscular.
IconData iconoGrupo(String grupo) => switch (grupo) {
      'Pecho' => Icons.fitness_center,
      'Espalda' => Icons.view_headline,
      'Pierna' => Icons.directions_walk,
      'Hombro' => Icons.accessibility_new,
      'Brazo' => Icons.sports_martial_arts,
      'Core' => Icons.shield_outlined,
      _ => Icons.fitness_center,
    };

/// Avatar estilizado para ejercicios y rutinas estilo Lyfta.
Widget avatarGrupo(String grupo, {bool oscuro = true, double size = 42}) {
  final color = colorGrupo(grupo, oscuro: oscuro);
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: oscuro ? 0.22 : 0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
    ),
    child: Icon(iconoGrupo(grupo), color: color, size: size * 0.52),
  );
}

/// "Lunes, 26 de octubre de 2026" según el idioma activo.
String fechaLarga(BuildContext context, DateTime fecha) {
  final l = AppLocalizations.of(context);
  return capitalizar(l.sessionDate(fecha));
}

String idiomaActivo(BuildContext context) =>
    Localizations.localeOf(context).languageCode;
