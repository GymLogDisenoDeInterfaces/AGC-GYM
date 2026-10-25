import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/models/ejercicio.dart';
import 'package:gymlog/data/models/estadisticas.dart';
import 'package:gymlog/data/models/serie.dart';
import 'package:gymlog/data/models/sesion.dart';

void main() {
  test('Ejercicio: toMap / fromMap', () {
    const e = Ejercicio(id: 3, nombre: 'Press banca', grupoMuscular: 'Pecho');
    final copia = Ejercicio.fromMap(e.toMap());
    expect(copia.id, 3);
    expect(copia.nombre, 'Press banca');
    expect(copia.grupoMuscular, 'Pecho');
  });

  test('Serie: toMap / fromMap conserva el origen', () {
    const s = Serie(
      id: 1,
      sesionId: 2,
      ejercicioId: 3,
      reps: 8,
      pesoKg: 62.5,
      origen: SerieOrigen.pose,
    );
    final copia = Serie.fromMap(s.toMap());
    expect(copia.origen, SerieOrigen.pose);
    expect(copia.pesoKg, 62.5);
    expect(copia.volumen, 500);
  });

  test('Serie.copyWith cambia solo lo indicado', () {
    const s = Serie(sesionId: 1, ejercicioId: 1, reps: 5, pesoKg: 20);
    final c = s.copyWith(reps: 6);
    expect(c.reps, 6);
    expect(c.pesoKg, 20);
  });

  test('SerieOrigen.desdeNombre usa manual si no conoce el nombre', () {
    expect(SerieOrigen.desdeNombre('voz'), SerieOrigen.voz);
    expect(SerieOrigen.desdeNombre('xyz'), SerieOrigen.manual);
    expect(SerieOrigen.desdeNombre(null), SerieOrigen.manual);
  });

  test('Sesion: la fecha viaja en ISO-8601', () {
    final s = Sesion(fecha: DateTime(2026, 10, 30, 18, 30), duracionMin: 45);
    final copia = Sesion.fromMap({'id': 1, ...s.toMap()});
    expect(copia.fecha, DateTime(2026, 10, 30, 18, 30));
    expect(copia.duracionMin, 45);
  });

  test('VolumenSemana.numeroSemana', () {
    const v = VolumenSemana(semana: '2026-43', volumen: 100);
    expect(v.numeroSemana, 43);
  });
}
