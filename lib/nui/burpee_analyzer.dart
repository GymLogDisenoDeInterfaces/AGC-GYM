// Ayoub - 04/11/2026: He desarrollado el analizador de burpees por visión artificial para registrar series de suelo y salto mediante pose.
import 'dart:math' as math;

/// Evento que se dispara al procesar un fotograma en el contador de burpees.
enum BurpeeEvent { none, repCounted }

/// Fase actual del usuario en la realización de un burpee.
enum BurpeeFase { dePie, enSuelo }

/// Analizador de movimiento para contar burpees a partir de la relación
/// de elevación vertical del cuerpo.
///
/// La relación vertical es el ratio entre la altura vertical (dy) y la longitud
/// total del cuerpo en 2D (sqrt(dx^2 + dy^2)):
/// * De pie: el cuerpo está erguido verticalmente (ratio >= 0.72).
/// * En el suelo (plancha o flexión del burpee): el cuerpo se extiende
///   horizontalmente en el suelo (ratio <= 0.45).
///
/// Una repetición completa requiere bajar al suelo y volver a ponerse de pie.
class BurpeeAnalyzer {
  BurpeeAnalyzer({
    this.standingThreshold = 0.72,
    this.groundThreshold = 0.45,
  }) : assert(groundThreshold < standingThreshold);

  final double standingThreshold;
  final double groundThreshold;

  int _reps = 0;
  BurpeeFase _fase = BurpeeFase.dePie;
  double _ratioMinimo = 1.0;

  int get reps => _reps;
  BurpeeFase get fase => _fase;
  double get ratioMinimo => _ratioMinimo;

  /// Procesa el ratio vertical actual (0.0 a 1.0) y devuelve el evento correspondiente.
  BurpeeEvent update(double ratioVertical) {
    if (_fase == BurpeeFase.dePie) {
      if (ratioVertical <= groundThreshold) {
        _fase = BurpeeFase.enSuelo;
        _ratioMinimo = ratioVertical;
      }
      return BurpeeEvent.none;
    }

    if (ratioVertical < _ratioMinimo) {
      _ratioMinimo = ratioVertical;
    }

    // Si estaba en el suelo y se reincorpora de pie
    if (ratioVertical >= standingThreshold) {
      _fase = BurpeeFase.dePie;
      _ratioMinimo = 1.0;
      _reps++;
      return BurpeeEvent.repCounted;
    }

    return BurpeeEvent.none;
  }

  /// Suma una repetición de forma manual (alternativa táctil).
  void sumarManual() => _reps++;

  /// Reinicia el contador de repeticiones y la máquina de estados.
  void reiniciar() {
    _reps = 0;
    _fase = BurpeeFase.dePie;
    _ratioMinimo = 1.0;
  }
}

/// Calcula el ratio vertical (0.0 a 1.0) entre la cabeza/hombros y tobillos/pies.
double calcularRatioVertical({
  required double sx,
  required double sy,
  required double ax,
  required double ay,
}) {
  final dy = (ay - sy).abs();
  final dx = (ax - sx).abs();
  final longitudTotal = math.sqrt(dx * dx + dy * dy);
  if (longitudTotal == 0) return 1.0;
  return (dy / longitudTotal).clamp(0.0, 1.0);
}
