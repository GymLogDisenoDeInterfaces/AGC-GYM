/// Volumen total (suma de repeticiones × peso) de una semana.
class VolumenSemana {
  const VolumenSemana({required this.semana, required this.volumen});

  /// Semana en formato `AAAA-SS` (año y número de semana de SQLite).
  final String semana;
  final double volumen;

  /// Número de semana: `2026-43` → 43.
  int get numeroSemana => int.tryParse(semana.split('-').last) ?? 0;
}

/// Número de series registradas para un grupo muscular.
class SeriesPorGrupo {
  const SeriesPorGrupo({required this.grupo, required this.series});

  final String grupo;
  final int series;
}
