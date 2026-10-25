import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';

/// Guarda ajustes de la app (tema, idioma) en la tabla `ajuste`.
class AjusteRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<String?> obtener(String clave) async {
    final db = await _db;
    final filas = await db.query(
      'ajuste',
      where: 'clave = ?',
      whereArgs: [clave],
      limit: 1,
    );
    return filas.isEmpty ? null : filas.first['valor'] as String;
  }

  Future<void> guardar(String clave, String valor) async {
    final db = await _db;
    await db.insert(
      'ajuste',
      {'clave': clave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> borrar(String clave) async {
    final db = await _db;
    await db.delete('ajuste', where: 'clave = ?', whereArgs: [clave]);
  }
}
