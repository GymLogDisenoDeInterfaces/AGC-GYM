// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_components/gym_components.dart';

import 'helpers.dart';

void main() {
  group('RepCounter · propiedades', () {
    test('valores por defecto', () {
      const c = RepCounter(count: 3);
      expect(c.goal, 10);
      expect(c.size, 160);
      expect(c.strokeWidth, 12);
      expect(c.label, 'reps');
      expect(c.color, isNull);
      expect(c.onGoalReached, isNull);
    });

    test('assert: goal, count, size y strokeWidth se validan', () {
      expect(() => RepCounter(count: 1, goal: 0), throwsAssertionError);
      expect(() => RepCounter(count: -1), throwsAssertionError);
      expect(() => RepCounter(count: 1, size: 0), throwsAssertionError);
      expect(() => RepCounter(count: 1, strokeWidth: 0), throwsAssertionError);
    });

    test('semanticLabel describe el progreso', () {
      const c = RepCounter(count: 4, goal: 12, label: 'reps');
      expect(c.semanticLabel, '4 / 12 reps');
    });

    test('es un GymComponent', () {
      expect(const RepCounter(count: 0), isA<GymComponent>());
    });
  });

  group('RepCounter · widget', () {
    testWidgets('muestra el número y el objetivo', (tester) async {
      await tester.pumpWidget(app(const RepCounter(count: 6, goal: 10)));
      await tester.pump();
      expect(find.text('6'), findsOneWidget);
      expect(find.text('/ 10 reps'), findsOneWidget);
    });

    testWidgets('usa el texto traducido de label', (tester) async {
      await tester.pumpWidget(
        app(const RepCounter(count: 2, goal: 5, label: 'repeticiones')),
      );
      await tester.pump();
      expect(find.text('/ 5 repeticiones'), findsOneWidget);
    });

    testWidgets('onGoalReached se dispara una sola vez al cruzar el objetivo',
        (tester) async {
      var avisos = 0;
      Widget construye(int count) => app(
            RepCounter(count: count, goal: 10, onGoalReached: () => avisos++),
          );

      await tester.pumpWidget(construye(8));
      await tester.pumpAndSettle();
      expect(avisos, 0);

      await tester.pumpWidget(construye(10));
      await tester.pumpAndSettle();
      expect(avisos, 1);

      // Seguir por encima del objetivo no vuelve a disparar el evento.
      await tester.pumpWidget(construye(11));
      await tester.pumpAndSettle();
      expect(avisos, 1);

      // Si baja del objetivo y lo vuelve a alcanzar, se dispara otra vez.
      await tester.pumpWidget(construye(4));
      await tester.pumpAndSettle();
      await tester.pumpWidget(construye(10));
      await tester.pumpAndSettle();
      expect(avisos, 2);
    });

    testWidgets('no dispara el evento si arranca ya cumplido', (tester) async {
      var avisos = 0;
      await tester.pumpWidget(
        app(RepCounter(count: 10, goal: 10, onGoalReached: () => avisos++)),
      );
      await tester.pumpAndSettle();
      expect(avisos, 0);
    });
  });

  group('RepCounter · golden', () {
    testWidgets('a medias (claro)', (tester) async {
      await tester.pumpWidget(app(const RepCounter(count: 6, goal: 10)));
      await tester.pumpAndSettle();
      await comparaGolden(tester, 'rep_counter_a_medias_claro.png');
    });

    testWidgets('objetivo alcanzado (oscuro)', (tester) async {
      await tester.pumpWidget(
        app(const RepCounter(count: 10, goal: 10), brillo: Brightness.dark),
      );
      await tester.pumpAndSettle();
      await comparaGolden(tester, 'rep_counter_completo_oscuro.png');
    });
  });
}
