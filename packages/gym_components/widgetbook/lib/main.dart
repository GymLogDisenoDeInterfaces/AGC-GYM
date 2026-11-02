// Carlos - 03/11/2026: Catálogo interactivo en Widgetbook con todos los estados y variantes de RepCounter y SetTile.
import 'package:flutter/material.dart';
import 'package:gym_components/gym_components.dart';
import 'package:widgetbook/widgetbook.dart';

void main() => runApp(const CatalogoApp());

ThemeData _tema(Brightness brillo) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0ABAB5),
        brightness: brillo,
      ),
    );

/// Catálogo con todos los estados de RepCounter y SetTile (RA3.a).
class CatalogoApp extends StatelessWidget {
  const CatalogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Oscuro', data: _tema(Brightness.dark)),
            WidgetbookTheme(name: 'Claro', data: _tema(Brightness.light)),
          ],
        ),
        TextScaleAddon(),
      ],
      directories: [
        WidgetbookComponent(
          name: 'RepCounter',
          useCases: [
            WidgetbookUseCase(
              name: '0 / goal',
              builder: (context) => const _Centrado(RepCounter(count: 0)),
            ),
            WidgetbookUseCase(
              name: 'A medias',
              builder: (context) =>
                  const _Centrado(RepCounter(count: 6, goal: 10)),
            ),
            WidgetbookUseCase(
              name: 'Objetivo alcanzado',
              builder: (context) =>
                  const _Centrado(RepCounter(count: 10, goal: 10)),
            ),
            WidgetbookUseCase(
              name: 'Objetivo superado',
              builder: (context) =>
                  const _Centrado(RepCounter(count: 14, goal: 10)),
            ),
            WidgetbookUseCase(
              name: 'Interactivo',
              builder: (context) => _Centrado(
                RepCounter(
                  count: context.knobs.int
                      .slider(label: 'count', initialValue: 5, min: 0, max: 30),
                  goal: context.knobs.int
                      .slider(label: 'goal', initialValue: 10, min: 1, max: 30),
                  size: context.knobs.double.slider(
                    label: 'size',
                    initialValue: 160,
                    min: 80,
                    max: 300,
                  ),
                  strokeWidth: context.knobs.double.slider(
                    label: 'strokeWidth',
                    initialValue: 12,
                    min: 4,
                    max: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'SetTile',
          useCases: [
            for (final origen in SetOrigin.values)
              WidgetbookUseCase(
                name: 'Origen: ${origen.name}',
                builder: (context) => _Centrado(
                  SetTile(
                    ejercicio: 'Sentadilla',
                    reps: 8,
                    pesoKg: 60,
                    origen: origen,
                  ),
                ),
              ),
            WidgetbookUseCase(
              name: 'Con edición y borrado',
              builder: (context) => _Centrado(
                SetTile(
                  dismissKey: const ValueKey('demo'),
                  ejercicio: 'Press banca',
                  reps: 10,
                  pesoKg: 62.5,
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Nombre muy largo',
              builder: (context) => const _Centrado(
                SetTile(
                  ejercicio: 'Press inclinado con mancuernas y agarre neutro',
                  reps: 12,
                  pesoKg: 22,
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Interactivo',
              builder: (context) => _Centrado(
                SetTile(
                  ejercicio: context.knobs.string(
                    label: 'ejercicio',
                    initialValue: 'Remo con barra',
                  ),
                  reps: context.knobs.int
                      .slider(label: 'reps', initialValue: 10, min: 1, max: 30),
                  pesoKg: context.knobs.double.slider(
                    label: 'pesoKg',
                    initialValue: 50,
                    min: 0,
                    max: 200,
                  ),
                  origen: context.knobs.object.dropdown<SetOrigin>(
                    label: 'origen',
                    options: SetOrigin.values,
                    labelBuilder: (o) => o.name,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Centrado extends StatelessWidget {
  const _Centrado(this.hijo);

  final Widget hijo;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: SizedBox(width: 360, child: hijo)));
}
