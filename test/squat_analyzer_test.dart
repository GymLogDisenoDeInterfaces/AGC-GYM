import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/nui/pose_geometry.dart';
import 'package:gymlog/nui/squat_analyzer.dart';

void main() {
  group('SquatAnalyzer', () {
    late SquatAnalyzer analizador;
    setUp(() => analizador = SquatAnalyzer());

    SquatEvent pasar(List<double> angulos) {
      var ultimo = SquatEvent.none;
      for (final a in angulos) {
        final e = analizador.update(a);
        if (e != SquatEvent.none) ultimo = e;
      }
      return ultimo;
    }

    test('una sentadilla completa cuenta una repetición', () {
      final e = pasar([170, 150, 120, 95, 120, 150, 165]);
      expect(e, SquatEvent.repCounted);
      expect(analizador.reps, 1);
    });

    test('una sentadilla incompleta avisa y no cuenta', () {
      final e = pasar([170, 150, 125, 115, 130, 150, 165]);
      expect(e, SquatEvent.incomplete);
      expect(analizador.reps, 0);
    });

    test('quedarse de pie no hace nada', () {
      expect(pasar([172, 170, 168, 171]), SquatEvent.none);
      expect(analizador.reps, 0);
    });

    test('dos repeticiones seguidas', () {
      pasar([170, 120, 90, 120, 165]);
      pasar([170, 120, 85, 120, 165]);
      expect(analizador.reps, 2);
    });

    test('no cuenta hasta volver a subir', () {
      expect(pasar([170, 130, 90]), SquatEvent.none);
      expect(analizador.reps, 0);
    });

    test('sumarManual y reiniciar', () {
      analizador.sumarManual();
      analizador.sumarManual();
      expect(analizador.reps, 2);
      analizador.reiniciar();
      expect(analizador.reps, 0);
    });

    test('umbrales incoherentes provocan un assert', () {
      expect(
        () => SquatAnalyzer(upAngle: 100, downAngle: 120, partialAngle: 140),
        throwsAssertionError,
      );
    });
  });

  group('anguloEntre', () {
    test('ángulo recto', () {
      final a = anguloEntre(ax: 0, ay: 1, bx: 0, by: 0, cx: 1, cy: 0);
      expect(a, closeTo(90, 0.001));
    });
    test('pierna estirada = 180°', () {
      final a = anguloEntre(ax: 0, ay: 0, bx: 0, by: 1, cx: 0, cy: 2);
      expect(a, closeTo(180, 0.001));
    });
    test('45 grados', () {
      final a = anguloEntre(ax: 1, ay: 0, bx: 0, by: 0, cx: 1, cy: 1);
      expect(a, closeTo(45, 0.001));
    });
  });
}
