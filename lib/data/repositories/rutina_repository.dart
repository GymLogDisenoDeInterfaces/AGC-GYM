import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/ejercicio.dart';
import '../models/rutina.dart';

class RutinaRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<Rutina>> todas() async {
    final db = await _db;
    final filas = await db.rawQuery('''
      SELECT r.id, r.nombre, COUNT(re.ejercicio_id) AS num_ejercicios
      FROM rutina r
      LEFT JOIN rutina_ejercicio re ON re.rutina_id = r.id
      GROUP BY r.id
      ORDER BY r.nombre COLLATE NOCASE
    ''');
    return filas.map(Rutina.fromMap).toList();
  }

  Future<Rutina?> obtener(int id) async {
    final db = await _db;
    final filas = await db.query('rutina', where: 'id = ?', whereArgs: [id]);
    return filas.isEmpty ? null : Rutina.fromMap(filas.first);
  }

  /// Ejercicios de la rutina, en el orden definido.
  Future<List<Ejercicio>> ejerciciosDe(int rutinaId) async {
    final db = await _db;
    final filas = await db.rawQuery(
      '''
      SELECT e.*
      FROM rutina_ejercicio re
      JOIN ejercicio e ON e.id = re.ejercicio_id
      WHERE re.rutina_id = ?
      ORDER BY re.orden
      ''',
      [rutinaId],
    );
    return filas.map(Ejercicio.fromMap).toList();
  }

  Future<int> crear(String nombre, List<int> ejercicioIds) async {
    final db = await _db;
    return db.transaction<int>((txn) async {
      final id = await txn.insert('rutina', {'nombre': nombre});
      for (var i = 0; i < ejercicioIds.length; i++) {
        await txn.insert('rutina_ejercicio', {
          'rutina_id': id,
          'ejercicio_id': ejercicioIds[i],
          'orden': i,
        });
      }
      return id;
    });
  }

  Future<void> eliminar(int id) async {
    final db = await _db;
    await db.delete('rutina', where: 'id = ?', whereArgs: [id]);
  }
}
