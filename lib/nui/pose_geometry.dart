import 'dart:math' as math;

/// Ángulo en grados (0 a 180) en el vértice B del triángulo A-B-C.
/// Para la rodilla: A = cadera, B = rodilla, C = tobillo.
double anguloEntre({
  required double ax,
  required double ay,
  required double bx,
  required double by,
  required double cx,
  required double cy,
}) {
  final radianes =
      math.atan2(cy - by, cx - bx) - math.atan2(ay - by, ax - bx);
  var grados = (radianes * 180 / math.pi).abs();
  if (grados > 180) grados = 360 - grados;
  return grados;
}
