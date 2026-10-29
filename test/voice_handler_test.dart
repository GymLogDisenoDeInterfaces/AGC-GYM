import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/models/ejercicio.dart';
import 'package:gymlog/nui/voice_command_handler.dart';

void main() {
  const catalogo = [
    Ejercicio(id: 1, nombre: 'Sentadilla', grupoMuscular: 'Pierna'),
    Ejercicio(id: 2, nombre: 'Press banca', grupoMuscular: 'Pecho'),
    Ejercicio(id: 3, nombre: 'Curl de bíceps', grupoMuscular: 'Brazo'),
  ];

  test('coincidencia exacta ignorando tildes y plurales', () {
    expect(VoiceCommandHandler.buscarEjercicio(catalogo, 'sentadillas')?.id, 1);
    expect(VoiceCommandHandler.buscarEjercicio(catalogo, 'curl de biceps')?.id, 3);
  });

  test('coincidencia parcial', () {
    expect(VoiceCommandHandler.buscarEjercicio(catalogo, 'banca')?.id, 2);
  });

  test('sin coincidencia devuelve null', () {
    expect(VoiceCommandHandler.buscarEjercicio(catalogo, 'patata'), isNull);
    expect(VoiceCommandHandler.buscarEjercicio(catalogo, ''), isNull);
  });
}
