class Sesion {
  const Sesion({this.id, required this.fecha, this.duracionMin = 0});

  final int? id;
  final DateTime fecha;
  final int duracionMin;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'fecha': fecha.toIso8601String(),
        'duracion_min': duracionMin,
      };

  factory Sesion.fromMap(Map<String, Object?> map) => Sesion(
        id: map['id'] as int?,
        fecha: DateTime.parse(map['fecha'] as String),
        duracionMin: (map['duracion_min'] as int?) ?? 0,
      );
}

/// Sesión con sus totales (resultado de una consulta con JOIN + agregados).
class SesionResumen {
  const SesionResumen({
    required this.sesion,
    required this.numSeries,
    required this.volumen,
  });

  final Sesion sesion;
  final int numSeries;
  final double volumen;
}

/// Totales de los últimos 7 días.
class ResumenSemana {
  const ResumenSemana({required this.sesiones, required this.volumen});

  final int sesiones;
  final double volumen;
}
