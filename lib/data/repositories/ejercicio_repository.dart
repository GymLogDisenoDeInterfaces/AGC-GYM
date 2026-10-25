import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/ejercicio.dart';

class EjercicioRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<Ejercicio>> obtener({String? grupo, String? busqueda}) async {
    final db = await _db;
    final condiciones = <String>[];
    final argumentos = <Object?>[];
    if (grupo != null) {
      condiciones.add('grupo_muscular = ?');
      argumentos.add(grupo);
    }
    final texto = busqueda?.trim() ?? '';
    if (texto.isNotEmpty) {
      condiciones.add('nombre LIKE ?');
      argumentos.add('%$texto%');
    }
    final filas = await db.query(
      'ejercicio',
      where: condiciones.isEmpty ? null : condiciones.join(' AND '),
      whereArgs: argumentos.isEmpty ? null : argumentos,
      orderBy: 'nombre COLLATE NOCASE',
    );
    return filas.map(Ejercicio.fromMap).toList();
  }

  Future<int> insertar(Ejercicio ejercicio) async {
    final db = await _db;
    return db.insert('ejercicio', ejercicio.toMap());
  }

  Future<void> actualizar(Ejercicio ejercicio) async {
    final db = await _db;
    await db.update(
      'ejercicio',
      ejercicio.toMap(),
      where: 'id = ?',
      whereArgs: [ejercicio.id],
    );
  }

  Future<void> eliminar(int id) async {
    final db = await _db;
    await db.delete('ejercicio', where: 'id = ?', whereArgs: [id]);
  }
}
