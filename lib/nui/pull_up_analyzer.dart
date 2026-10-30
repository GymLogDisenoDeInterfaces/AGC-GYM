// Guillermo - 31/10/2026: He implementado el analizador biomecánico del ángulo de codo para contar dominadas y detectar repeticiones incompletas.

/// Evento que se dispara al procesar un fotograma en el contador de dominadas.
enum PullUpEvent { none, repCounted, incomplete }

/// Máquina de estados que cuenta dominadas a partir del ángulo articular de codo
/// (muñeca-codo-hombro).
///
/// * Posición inicial (colgado): brazos extendidos (ángulo >= [extendedAngle], ~145°).
/// * Inicio de tracción: el ángulo flexiona por debajo de [partialAngle] (~125°).
/// * Cima de la dominada: la barbilla supera la barra y los codos flexionan por debajo de [flexedAngle] (~85°).
/// * Si desciende de nuevo a extensión sin haber llegado a [flexedAngle],
///   se avisa de dominada incompleta.
class PullUpAnalyzer {
  PullUpAnalyzer({
    this.extendedAngle = 145,
    this.flexedAngle = 85,
    this.partialAngle = 125,
  }) : assert(flexedAngle < partialAngle && partialAngle < extendedAngle);

  final double extendedAngle;
  final double flexedAngle;
  final double partialAngle;

  int _reps = 0;
  bool _traccionando = false;
  double _minimo = 180;

  int get reps => _reps;
  bool get traccionando => _traccionando;

  /// Procesa un ángulo de flexión de codo y devuelve el evento resultante.
  PullUpEvent update(double angulo) {
    if (!_traccionando) {
      if (angulo < partialAngle) {
        _traccionando = true;
        _minimo = angulo;
      }
      return PullUpEvent.none;
    }

    if (angulo < _minimo) _minimo = angulo;

    if (angulo >= extendedAngle) {
      final completa = _minimo <= flexedAngle;
      _traccionando = false;
      _minimo = 180;
      if (completa) {
        _reps++;
        return PullUpEvent.repCounted;
      }
      return PullUpEvent.incomplete;
    }
    return PullUpEvent.none;
  }

  /// Suma una repetición a mano (alternativa táctil).
  void sumarManual() => _reps++;

  /// Reinicia el contador de repeticiones y la máquina de estados.
  void reiniciar() {
    _reps = 0;
    _traccionando = false;
    _minimo = 180;
  }
}
