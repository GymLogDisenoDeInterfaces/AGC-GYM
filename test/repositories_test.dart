import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/db/database_helper.dart';
import 'package:gymlog/data/models/ejercicio.dart';
import 'package:gymlog/data/models/serie.dart';
import 'package:gymlog/data/models/sesion.dart';
import 'package:gymlog/data/repositories/ejercicio_repository.dart';
import 'package:gymlog/data/repositories/estadistica_repository.dart';
import 'package:gymlog/data/repositories/serie_repository.dart';
import 'package:gymlog/data/repositories/sesion_repository.dart';
import 'package:gymlog/nui/voice_command_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Pruebas con SQLite en memoria. Si el equipo no tiene la librería nativa de
/// SQLite (pasa a veces en Windows) se marcan como omitidas, no como fallos.
void main() {
  var disponible = true;

  setUpAll(() async {
    try {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      DatabaseHelper.rutaPrueba = inMemoryDatabasePath;
      await DatabaseHelper.instance.database;
    } catch (_) {
      disponible = false;
    }
  });

  tearDownAll(() async {
    if (disponible) await DatabaseHelper.instance.cerrar();
  });

  bool omitir() {
    if (!disponible) markTestSkipped('SQLite nativo no disponible');
    return !disponible;
  }

  test('el seed deja datos de ejemplo', () async {
    if (omitir()) return;
    final ejercicios = await EjercicioRepository().obtener();
    expect(ejercicios.length, greaterThanOrEqualTo(10));
  });

  test('CRUD de ejercicio con whereArgs', () async {
    if (omitir()) return;
    final repo = EjercicioRepository();
    final id = await repo.insertar(
      const Ejercicio(nombre: 'Ejercicio de prueba', grupoMuscular: 'Core'),
    );
    var lista = await repo.obtener(busqueda: 'de prueba');
    expect(lista.single.id, id);

    await repo.actualizar(
      Ejercicio(id: id, nombre: 'Prueba editada', grupoMuscular: 'Core'),
    );
    lista = await repo.obtener(busqueda: 'editada');
    expect(lista.length, 1);

    await repo.eliminar(id);
    expect(await repo.obtener(busqueda: 'editada'), isEmpty);
  });

  test('el nombre de ejercicio es único', () async {
    if (omitir()) return;
    final repo = EjercicioRepository();
    const e = Ejercicio(nombre: 'Unico', grupoMuscular: 'Core');
    final id = await repo.insertar(e);
    await expectLater(repo.insertar(e), throwsA(isA<DatabaseException>()));
    await repo.eliminar(id);
  });

  test('no se puede borrar un ejercicio con series (clave ajena)', () async {
    if (omitir()) return;
    final ejercicios = EjercicioRepository();
    final sesiones = SesionRepository();
    final series = SerieRepository();
    final ejId = await ejercicios.insertar(
      const Ejercicio(nombre: 'Con series', grupoMuscular: 'Pierna'),
    );
    final sesId = await sesiones.insertar(Sesion(fecha: DateTime.now()));
    await series.insertar(
      Serie(sesionId: sesId, ejercicioId: ejId, reps: 5, pesoKg: 10),
    );
    await expectLater(ejercicios.eliminar(ejId), throwsA(isA<DatabaseException>()));
    await sesiones.eliminar(sesId); // borra las series en cascada
    await ejercicios.eliminar(ejId);
  });

  test('JOIN y agregados: resumen de sesión y estadísticas', () async {
    if (omitir()) return;
    final ejercicios = await EjercicioRepository().obtener();
    final sesiones = SesionRepository();
    final series = SerieRepository();
    final sesId = await sesiones.insertar(Sesion(fecha: DateTime.now()));
    await series.insertar(
      Serie(sesionId: sesId, ejercicioId: ejercicios.first.id!, reps: 10, pesoKg: 50),
    );
    await series.insertar(
      Serie(sesionId: sesId, ejercicioId: ejercicios.first.id!, reps: 5, pesoKg: 20),
    );

    final resumen = await sesiones.resumenPorId(sesId);
    expect(resumen!.numSeries, 2);
    expect(resumen.volumen, 600);

    final lista = await series.deSesion(sesId);
    expect(lista.first.ejercicioNombre, ejercicios.first.nombre);

    final semanas = await EstadisticaRepository().volumenSemanal();
    expect(semanas, isNotEmpty);
    final grupos = await EstadisticaRepository().seriesPorGrupo();
    expect(grupos, isNotEmpty);
  });

  test('voz: añadir series escribe en SQLite y las consultas leen', () async {
    if (omitir()) return;
    final sesiones = SesionRepository();
    final sesId = await sesiones.insertar(Sesion(fecha: DateTime.now()));
    final manejador = VoiceCommandHandler(sesionId: sesId);

    final r1 = await manejador.ejecutarTexto(
      'añade tres series de sentadilla con sesenta kilos',
    );
    expect(r1.exito, isTrue);
    expect(r1.cambioDatos, isTrue);

    final guardadas = await SerieRepository().deSesion(sesId);
    expect(guardadas.length, 3);
    expect(guardadas.every((s) => s.origen == SerieOrigen.voz), isTrue);
    expect(guardadas.first.pesoKg, 60);

    final r2 = await manejador.ejecutarTexto('cuántas series llevo');
    expect(r2.mensaje, contains('3'));
    final r3 = await manejador.ejecutarTexto('cuánto volumen llevo');
    expect(r3.mensaje, contains('1800'));

    final r4 = await manejador.ejecutarTexto('añade una serie de patata');
    expect(r4.exito, isFalse);
  });
}
