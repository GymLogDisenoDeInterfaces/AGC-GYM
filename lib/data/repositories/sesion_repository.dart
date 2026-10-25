import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/sesion.dart';

class SesionRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<int> insertar(Sesion sesion) async {
    final db = await _db;
    return db.insert('sesion', sesion.toMap());
  }

  Future<Sesion?> obtener(int id) async {
    final db = await _db;
    final filas = await db.query('sesion', where: 'id = ?', whereArgs: [id]);
    return filas.isEmpty ? null : Sesion.fromMap(filas.first);
  }

  Future<void> actualizarDuracion(int id, int minutos) async {
    final db = await _db;
    await db.update(
      'sesion',
      {'duracion_min': minutos},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> eliminar(int id) async {
    final db = await _db;
    // Las series se borran solas por ON DELETE CASCADE.
    await db.delete('sesion', where: 'id = ?', whereArgs: [id]);
  }

  /// Consulta con JOIN + agregados: sesiones con nº de series y volumen.
  Future<List<SesionResumen>> resumenes({int? limite}) =>
      _consultarResumenes(limite: limite);

  Future<SesionResumen?> resumenPorId(int id) async {
    final lista = await _consultarResumenes(donde: 'se.id = ?', argumentos: [id]);
    return lista.isEmpty ? null : lista.first;
  }

  Future<List<SesionResumen>> _consultarResumenes({
    String? donde,
    List<Object?>? argumentos,
    int? limite,
  }) async {
    final db = await _db;
    final filas = await db.rawQuery(
      '''
      SELECT se.id, se.fecha, se.duracion_min,
             COUNT(s.id) AS num_series,
             COALESCE(SUM(s.reps * s.peso_kg), 0) AS volumen
      FROM sesion se
      LEFT JOIN serie s ON s.sesion_id = se.id
      ${donde == null ? '' : 'WHERE $donde'}
      GROUP BY se.id
      ORDER BY se.fecha DESC
      ${limite == null ? '' : 'LIMIT $limite'}
      ''',
      argumentos,
    );
    return filas
        .map((f) => SesionResumen(
              sesion: Sesion.fromMap(f),
              numSeries: f['num_series'] as int,
              volumen: (f['volumen'] as num).toDouble(),
            ))
        .toList();
  }

  /// Sesiones y volumen de los últimos 7 días.
  Future<ResumenSemana> resumenSemana() async {
    final db = await _db;
    final desde =
        DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
    final filas = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT se.id) AS n,
             COALESCE(SUM(s.reps * s.peso_kg), 0) AS volumen
      FROM sesion se
      LEFT JOIN serie s ON s.sesion_id = se.id
      WHERE se.fecha >= ?
      ''',
      [desde],
    );
    final fila = filas.first;
    return ResumenSemana(
      sesiones: fila['n'] as int,
      volumen: (fila['volumen'] as num).toDouble(),
    );
  }
}
