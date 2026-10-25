// Ayoub - 25/10/2026: He creado el repositorio de series con consultas parametrizadas, JOIN con ejercicio y cálculo de volumen.
import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/serie.dart';

class SerieRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  /// JOIN serie-ejercicio para mostrar el nombre del ejercicio.
  Future<List<Serie>> deSesion(int sesionId) async {
    final db = await _db;
    final filas = await db.rawQuery(
      '''
      SELECT s.*, e.nombre AS ejercicio_nombre
      FROM serie s
      JOIN ejercicio e ON e.id = s.ejercicio_id
      WHERE s.sesion_id = ?
      ORDER BY s.id
      ''',
      [sesionId],
    );
    return filas.map(Serie.fromMap).toList();
  }

  /// Si la serie trae id (deshacer un borrado) se reinserta con el mismo id.
  Future<int> insertar(Serie serie) async {
    final db = await _db;
    return db.insert('serie', serie.toMap());
  }

  Future<void> actualizar(Serie serie) async {
    final db = await _db;
    await db.update(
      'serie',
      serie.toMap(),
      where: 'id = ?',
      whereArgs: [serie.id],
    );
  }

  Future<void> eliminar(int id) async {
    final db = await _db;
    await db.delete('serie', where: 'id = ?', whereArgs: [id]);
  }
}
