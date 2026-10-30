// Guillermo - 30/10/2026: He programado el analizador trigonométrico del ángulo articular para contar sentadillas y avisar de incompletas.
/// Qué ha pasado al procesar el último fotograma.
enum SquatEvent { none, repCounted, incomplete }

/// Máquina de estados que cuenta sentadillas a partir del ángulo de rodilla.
///
/// De pie la rodilla está cerca de 170°; al bajar el ángulo disminuye.
/// * Se considera que empieza a bajar al pasar de [partialAngle] (140°).
/// * Si llega a [downAngle] (100°) o menos y vuelve a [upAngle] (160°), cuenta
///   una repetición.
/// * Si vuelve a subir sin haber llegado a [downAngle], es una sentadilla
///   incompleta (se avisa y no se cuenta).
class SquatAnalyzer {
  SquatAnalyzer({
    this.upAngle = 160,
    this.downAngle = 100,
    this.partialAngle = 140,
  }) : assert(downAngle < partialAngle && partialAngle < upAngle);

  final double upAngle;
  final double downAngle;
  final double partialAngle;

  int _reps = 0;
  bool _bajando = false;
  double _minimo = 180;

  int get reps => _reps;
  bool get bajando => _bajando;

  /// Procesa un ángulo de rodilla y devuelve el evento resultante.
  SquatEvent update(double angulo) {
    if (!_bajando) {
      if (angulo < partialAngle) {
        _bajando = true;
        _minimo = angulo;
      }
      return SquatEvent.none;
    }

    if (angulo < _minimo) _minimo = angulo;

    if (angulo >= upAngle) {
      final profunda = _minimo <= downAngle;
      _bajando = false;
      _minimo = 180;
      if (profunda) {
        _reps++;
        return SquatEvent.repCounted;
      }
      return SquatEvent.incomplete;
    }
    return SquatEvent.none;
  }

  /// Suma una repetición a mano (alternativa táctil).
  void sumarManual() => _reps++;

  void reiniciar() {
    _reps = 0;
    _bajando = false;
    _minimo = 180;
  }
}
