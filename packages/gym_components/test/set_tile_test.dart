// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_components/gym_components.dart';

import 'helpers.dart';

Widget _lista(Widget tile) => ListView(children: [tile]);

void main() {
  group('SetTile · propiedades', () {
    test('valores por defecto', () {
      const t = SetTile(ejercicio: 'Sentadilla', reps: 5, pesoKg: 80);
      expect(t.origen, SetOrigin.manual);
      expect(t.onEdit, isNull);
      expect(t.onDelete, isNull);
      expect(t.dismissKey, isNull);
    });

    test('assert: reps, peso y dismissKey', () {
      expect(
        () => SetTile(ejercicio: 'a', reps: 0, pesoKg: 1),
        throwsAssertionError,
      );
      expect(
        () => SetTile(ejercicio: 'a', reps: 1, pesoKg: -1),
        throwsAssertionError,
      );
      expect(
        () => SetTile(ejercicio: 'a', reps: 1, pesoKg: 1, onDelete: () {}),
        throwsAssertionError,
      );
    });

    test('semanticLabel incluye ejercicio, datos y origen', () {
      const t = SetTile(
        ejercicio: 'Press banca',
        reps: 10,
        pesoKg: 62.5,
        origen: SetOrigin.voice,
      );
      expect(t.semanticLabel, 'Press banca, 10 reps × 62.5 kg, Voice');
    });

    test('es un GymComponent', () {
      expect(
        const SetTile(ejercicio: 'a', reps: 1, pesoKg: 0),
        isA<GymComponent>(),
      );
    });
  });

  group('SetTile · widget', () {
    testWidgets('muestra ejercicio y subtítulo (peso entero sin decimales)',
        (tester) async {
      await tester.pumpWidget(app(_lista(
        const SetTile(ejercicio: 'Sentadilla', reps: 8, pesoKg: 60),
      )));
      expect(find.text('Sentadilla'), findsOneWidget);
      expect(find.text('8 reps × 60 kg'), findsOneWidget);
    });

    testWidgets('el peso con decimales se muestra con uno', (tester) async {
      await tester.pumpWidget(app(_lista(
        const SetTile(ejercicio: 'Press', reps: 6, pesoKg: 67.5),
      )));
      expect(find.text('6 reps × 67.5 kg'), findsOneWidget);
    });

    testWidgets('cada origen muestra su icono', (tester) async {
      for (final origen in SetOrigin.values) {
        await tester.pumpWidget(app(_lista(
          SetTile(ejercicio: 'x', reps: 1, pesoKg: 0, origen: origen),
        )));
        expect(find.byIcon(origen.icon), findsOneWidget);
      }
    });

    testWidgets('la pulsación larga llama a onEdit', (tester) async {
      var editado = 0;
      await tester.pumpWidget(app(_lista(
        SetTile(
          ejercicio: 'Remo',
          reps: 10,
          pesoKg: 50,
          onEdit: () => editado++,
        ),
      )));
      await tester.longPress(find.text('Remo'));
      expect(editado, 1);
    });

    testWidgets('el botón de editar llama a onEdit', (tester) async {
      var editado = 0;
      await tester.pumpWidget(app(_lista(
        SetTile(
          ejercicio: 'Remo',
          reps: 10,
          pesoKg: 50,
          onEdit: () => editado++,
        ),
      )));
      await tester.tap(find.byIcon(Icons.edit_outlined));
      expect(editado, 1);
    });

    testWidgets('sin onEdit no hay botón de editar', (tester) async {
      await tester.pumpWidget(app(_lista(
        const SetTile(ejercicio: 'Remo', reps: 10, pesoKg: 50),
      )));
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });

    testWidgets('deslizar llama a onDelete', (tester) async {
      var borrado = 0;
      await tester.pumpWidget(app(_lista(
        SetTile(
          dismissKey: const ValueKey('s1'),
          ejercicio: 'Dominadas',
          reps: 8,
          pesoKg: 0,
          onDelete: () => borrado++,
        ),
      )));
      await tester.drag(find.byType(SetTile), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(borrado, 1);
    });

    testWidgets('sin onDelete no se envuelve en Dismissible', (tester) async {
      await tester.pumpWidget(app(_lista(
        const SetTile(ejercicio: 'Dominadas', reps: 8, pesoKg: 0),
      )));
      expect(find.byType(Dismissible), findsNothing);
    });

    testWidgets('los textos se pueden traducir con SetTileLabels',
        (tester) async {
      await tester.pumpWidget(app(_lista(
        SetTile(
          ejercicio: 'Sentadilla',
          reps: 5,
          pesoKg: 100,
          onEdit: () {},
          labels: SetTileLabels(
            subtitle: (reps, kg) => '$reps repeticiones de $kg kilos',
            editTooltip: 'Editar',
          ),
        ),
      )));
      expect(find.text('5 repeticiones de 100 kilos'), findsOneWidget);
      expect(find.byTooltip('Editar'), findsOneWidget);
    });
  });

  group('SetTile · golden', () {
    testWidgets('tres orígenes (claro)', (tester) async {
      await tester.pumpWidget(app(
        SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SetTile(ejercicio: 'Sentadilla', reps: 8, pesoKg: 60),
              const SetTile(
                ejercicio: 'Press banca',
                reps: 10,
                pesoKg: 62.5,
                origen: SetOrigin.voice,
              ),
              SetTile(
                ejercicio: 'Sentadilla con barra larga de nombre muy largo',
                reps: 12,
                pesoKg: 0,
                origen: SetOrigin.pose,
                onEdit: () {},
              ),
            ],
          ),
        ),
      ));
      await comparaGolden(tester, 'set_tile_claro.png');
    });

    testWidgets('modo oscuro', (tester) async {
      await tester.pumpWidget(app(
        const SizedBox(
          width: 360,
          child: SetTile(
            ejercicio: 'Peso muerto',
            reps: 5,
            pesoKg: 100,
            origen: SetOrigin.pose,
          ),
        ),
        brillo: Brightness.dark,
      ));
      await comparaGolden(tester, 'set_tile_oscuro.png');
    });
  });
}
