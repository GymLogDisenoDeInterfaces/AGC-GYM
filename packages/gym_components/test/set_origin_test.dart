import 'package:flutter_test/flutter_test.dart';
import 'package:gym_components/gym_components.dart';

void main() {
  test('cada origen tiene un icono distinto', () {
    final iconos = SetOrigin.values.map((o) => o.icon.codePoint).toSet();
    expect(iconos.length, SetOrigin.values.length);
  });

  test('los nombres de los orígenes son los esperados', () {
    expect(SetOrigin.values.map((o) => o.name),
        ['manual', 'voice', 'pose']);
  });
}
