import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/estadisticas.dart';

/// Consultas con JOIN y agregados para la pantalla de estadísticas.
class EstadisticaRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  /// SUM(reps * peso_kg) por semana, de las últimas [semanas] con datos.
  Future<List<VolumenSemana>> volumenSemanal({int semanas = 8}) async {
    final db = await _db;
    final filas = await db.rawQuery(
      '''
      SELECT strftime('%Y-%W', se.fecha) AS semana,
             SUM(s.reps * s.peso_kg) AS volumen
      FROM serie s
      JOIN sesion se ON se.id = s.sesion_id
      GROUP BY semana
      ORDER BY semana DESC
      LIMIT ?
      ''',
      [semanas],
    );
    return filas
        .map((f) => VolumenSemana(
              semana: f['semana'] as String,
              volumen: (f['volumen'] as num).toDouble(),
            ))
        .toList()
        .reversed
        .toList();
  }

  /// COUNT de series por grupo muscular (JOIN serie-ejercicio).
  Future<List<SeriesPorGrupo>> seriesPorGrupo() async {
    final db = await _db;
    final filas = await db.rawQuery('''
      SELECT e.grupo_muscular AS grupo, COUNT(s.id) AS series
      FROM serie s
      JOIN ejercicio e ON e.id = s.ejercicio_id
      GROUP BY e.grupo_muscular
      ORDER BY series DESC
    ''');
    return filas
        .map((f) => SeriesPorGrupo(
              grupo: f['grupo'] as String,
              series: f['series'] as int,
            ))
        .toList();
  }
}
