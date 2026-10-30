// Guillermo - 04/11/2026: Tests unitarios para el analizador de dominadas y rangos de flexión articular.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/nui/pull_up_analyzer.dart';

void main() {
  group('PullUpAnalyzer', () {
    late PullUpAnalyzer analizador;
    setUp(() => analizador = PullUpAnalyzer());

    PullUpEvent pasar(List<double> angulos) {
      var ultimo = PullUpEvent.none;
      for (final a in angulos) {
        final e = analizador.update(a);
        if (e != PullUpEvent.none) ultimo = e;
      }
      return ultimo;
    }

    test('una dominada completa (colgado -> barbilla arriba -> colgado) cuenta repetición', () {
      // Colgado (160°), empieza a traccionar (120°), supera barra (80°), baja y estira brazos (150°)
      final e = pasar([160, 140, 115, 80, 100, 130, 150]);
      expect(e, PullUpEvent.repCounted);
      expect(analizador.reps, 1);
      expect(analizador.traccionando, false);
    });

    test('una dominada incompleta (no llega a flexionar completamente) avisa y no cuenta', () {
      // Empieza a subir pero se queda en 100° (no baja de 85°) y vuelve a descolgarse a 150°
      final e = pasar([160, 135, 110, 95, 120, 150]);
      expect(e, PullUpEvent.incomplete);
      expect(analizador.reps, 0);
      expect(analizador.traccionando, false);
    });

    test('quedarse colgado sin traccionar no suma repeticiones', () {
      expect(pasar([165, 160, 155, 162]), PullUpEvent.none);
      expect(analizador.reps, 0);
    });

    test('dos dominadas consecutivas completas suman dos repeticiones', () {
      pasar([160, 110, 75, 150]);
      pasar([155, 105, 70, 148]);
      expect(analizador.reps, 2);
    });

    test('sumarManual y reiniciar funcionan correctamente', () {
      analizador.sumarManual();
      analizador.sumarManual();
      expect(analizador.reps, 2);
      analizador.reiniciar();
      expect(analizador.reps, 0);
      expect(analizador.traccionando, false);
    });
  });
}
