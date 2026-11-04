# gym_components

Componentes visuales de **agc-gym**.

| Componente | Tipo | Para qué sirve |
|---|---|---|
| `RepCounter` | `StatefulWidget` | Contador circular animado de repeticiones con objetivo |
| `SetTile` | `StatelessWidget` | Fila de una serie (ejercicio, repeticiones, peso y origen) |
| `GymComponent` | clase abstracta | Contrato común: ambos exponen una etiqueta semántica |

## Instalación

En el `pubspec.yaml` de la app:

```yaml
dependencies:
  gym_components:
    path: packages/gym_components
```

## Uso

```dart
import 'package:gym_components/gym_components.dart';

RepCounter(
  count: 7,
  goal: 10,
  onGoalReached: () => print('¡Objetivo!'),
);

SetTile(
  key: const ValueKey('serie-1'),
  dismissKey: const ValueKey('serie-1'),
  ejercicio: 'Sentadilla',
  reps: 8,
  pesoKg: 60,
  origen: SetOrigin.voice,
  onEdit: () {},
  onDelete: () {},
);
```

## Comandos

```bash
flutter pub get
flutter analyze
flutter test --coverage        # cobertura en coverage/lcov.info
dart doc                       # documentación en doc/api
```

La primera vez que se ejecutan los tests se generan las imágenes *golden* en
`test/goldens/`. Hay que subirlas al repositorio.

## Widgetbook

```bash
cd widgetbook
flutter pub get
flutter run -d chrome          # o -d windows
```
