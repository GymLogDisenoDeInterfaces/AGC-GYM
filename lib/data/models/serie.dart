enum SerieOrigen {
  manual,
  voz,
  pose;

  static SerieOrigen desdeNombre(String? nombre) => SerieOrigen.values
      .firstWhere((o) => o.name == nombre, orElse: () => SerieOrigen.manual);
}

class Serie {
  const Serie({
    this.id,
    required this.sesionId,
    required this.ejercicioId,
    required this.reps,
    this.pesoKg = 0,
    this.origen = SerieOrigen.manual,
    this.ejercicioNombre,
    this.rir,
  });

  final int? id;
  final int sesionId;
  final int ejercicioId;
  final int reps;
  final double pesoKg;
  final SerieOrigen origen;

  /// Repeticiones en recámara (0 = fallo, 1 = 1 rep antes del fallo, etc.).
  final int? rir;

  /// Solo viene rellenado cuando la serie sale de un JOIN con ejercicio.
  final String? ejercicioNombre;

  double get volumen => reps * pesoKg;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'sesion_id': sesionId,
        'ejercicio_id': ejercicioId,
        'reps': reps,
        'peso_kg': pesoKg,
        'origen': origen.name,
        if (rir != null) 'rir': rir,
      };

  factory Serie.fromMap(Map<String, Object?> map) => Serie(
        id: map['id'] as int?,
        sesionId: map['sesion_id'] as int,
        ejercicioId: map['ejercicio_id'] as int,
        reps: map['reps'] as int,
        pesoKg: (map['peso_kg'] as num).toDouble(),
        origen: SerieOrigen.desdeNombre(map['origen'] as String?),
        ejercicioNombre: map['ejercicio_nombre'] as String?,
        rir: map['rir'] as int?,
      );

  Serie copyWith({
    int? id,
    int? sesionId,
    int? ejercicioId,
    int? reps,
    double? pesoKg,
    SerieOrigen? origen,
    String? ejercicioNombre,
    int? rir,
  }) =>
      Serie(
        id: id ?? this.id,
        sesionId: sesionId ?? this.sesionId,
        ejercicioId: ejercicioId ?? this.ejercicioId,
        reps: reps ?? this.reps,
        pesoKg: pesoKg ?? this.pesoKg,
        origen: origen ?? this.origen,
        ejercicioNombre: ejercicioNombre ?? this.ejercicioNombre,
        rir: rir ?? this.rir,
      );
}
