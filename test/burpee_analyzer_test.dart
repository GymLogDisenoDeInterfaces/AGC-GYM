// Ayoub - 04/11/2026: Tests unitarios del analizador de burpees y cálculo del ratio vertical.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/nui/burpee_analyzer.dart';

void main() {
  group('calcularRatioVertical', () {
    test('cuerpo vertical de pie da un ratio alto cercano a 1.0', () {
      // Hombro en (100, 50) y tobillo en (100, 350) -> pura vertical
      final r = calcularRatioVertical(sx: 100, sy: 50, ax: 100, ay: 350);
      expect(r, closeTo(1.0, 0.01));
    });

    test('cuerpo horizontal en el suelo da un ratio bajo cercano a 0.0', () {
      // Hombro en (50, 300) y tobillo en (350, 310) -> casi pura horizontal
      final r = calcularRatioVertical(sx: 50, sy: 300, ax: 350, ay: 310);
      expect(r, lessThan(0.2));
    });
  });

  group('BurpeeAnalyzer', () {
    late BurpeeAnalyzer analizador;
    setUp(() => analizador = BurpeeAnalyzer());

    BurpeeEvent pasar(List<double> ratios) {
      var ultimo = BurpeeEvent.none;
      for (final r in ratios) {
        final e = analizador.update(r);
        if (e != BurpeeEvent.none) ultimo = e;
      }
      return ultimo;
    }

    test('un burpee completo (de pie -> suelo -> de pie) cuenta una repetición', () {
      // De pie (0.95), empieza a bajar (0.60), al suelo (0.35, 0.30), se levanta (0.55), de pie (0.85)
      final e = pasar([0.95, 0.60, 0.35, 0.30, 0.55, 0.85]);
      expect(e, BurpeeEvent.repCounted);
      expect(analizador.reps, 1);
      expect(analizador.fase, BurpeeFase.dePie);
    });

    test('quedarse de pie no cuenta repeticiones', () {
      expect(pasar([0.90, 0.85, 0.92, 0.88]), BurpeeEvent.none);
      expect(analizador.reps, 0);
      expect(analizador.fase, BurpeeFase.dePie);
    });

    test('bajar al suelo sin levantarse aún no suma la repetición', () {
      expect(pasar([0.95, 0.50, 0.30]), BurpeeEvent.none);
      expect(analizador.reps, 0);
      expect(analizador.fase, BurpeeFase.enSuelo);
    });

    test('agacharse solo un poco (sin llegar al suelo) no cuenta como burpee', () {
      // Baja a 0.55 (no llega a <= 0.45) y vuelve a subir
      expect(pasar([0.90, 0.65, 0.55, 0.70, 0.85]), BurpeeEvent.none);
      expect(analizador.reps, 0);
      expect(analizador.fase, BurpeeFase.dePie);
    });

    test('dos burpees consecutivos suman dos repeticiones', () {
      pasar([0.95, 0.35, 0.85]);
      pasar([0.90, 0.30, 0.88]);
      expect(analizador.reps, 2);
    });

    test('sumarManual incrementa el contador y reiniciar lo pone a cero', () {
      analizador.sumarManual();
      analizador.sumarManual();
      expect(analizador.reps, 2);
      analizador.reiniciar();
      expect(analizador.reps, 0);
      expect(analizador.fase, BurpeeFase.dePie);
    });
  });
}
