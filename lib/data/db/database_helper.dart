// Ayoub - 24/10/2026: He creado el singleton de DatabaseHelper para SQLite activando PRAGMA foreign_keys y gestionando onCreate y onUpgrade.
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'seed.dart';

/// Acceso único a SQLite (singleton).
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _nombreBd = 'gymlog.db';

  /// Versión 1: tablas del diario. Versión 2: tabla `ajuste`. Versión 3: columna `rir` en serie.
  static const int _version = 3;

  /// Solo para tests: ruta alternativa (por ejemplo `inMemoryDatabasePath`).
  static String? rutaPrueba;

  Future<Database>? _abriendo;

  Future<Database> get database => _abriendo ??= _abrir();

  Future<Database> _abrir() async {
    final ruta = rutaPrueba ?? p.join(await getDatabasesPath(), _nombreBd);
    return openDatabase(
      ruta,
      version: _version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Las claves ajenas se activan en onConfigure (antes de onCreate/onUpgrade).
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    for (final sentencia in _tablasV1) {
      await db.execute(sentencia);
    }
    await db.execute(_tablaAjuste);
    await sembrarDatos(db);
  }

  Future<void> _onUpgrade(Database db, int anterior, int nueva) async {
    if (anterior < 2) {
      await db.execute(_tablaAjuste);
    }
    if (anterior < 3) {
      try {
        await db.execute('ALTER TABLE serie ADD COLUMN rir INTEGER DEFAULT NULL');
      } catch (_) {}
    }
  }

  /// Cierra la base de datos. La siguiente consulta la vuelve a abrir.
  Future<void> cerrar() async {
    final abriendo = _abriendo;
    if (abriendo == null) return;
    final db = await abriendo;
    await db.close();
    _abriendo = null;
  }

  static const String _tablaAjuste = '''
    CREATE TABLE ajuste (
      clave TEXT PRIMARY KEY,
      valor TEXT NOT NULL
    )''';

  static const List<String> _tablasV1 = [
    '''
    CREATE TABLE ejercicio (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL UNIQUE,
      grupo_muscular TEXT NOT NULL
    )''',
    '''
    CREATE TABLE sesion (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha TEXT NOT NULL,
      duracion_min INTEGER NOT NULL DEFAULT 0
    )''',
    '''
    CREATE TABLE serie (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sesion_id INTEGER NOT NULL REFERENCES sesion(id) ON DELETE CASCADE,
      ejercicio_id INTEGER NOT NULL REFERENCES ejercicio(id) ON DELETE RESTRICT,
      reps INTEGER NOT NULL CHECK (reps > 0),
      peso_kg REAL NOT NULL DEFAULT 0,
      origen TEXT NOT NULL DEFAULT 'manual' CHECK (origen IN ('manual','voz','pose')),
      rir INTEGER DEFAULT NULL
    )''',
    '''
    CREATE TABLE rutina (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL
    )''',
    '''
    CREATE TABLE rutina_ejercicio (
      rutina_id INTEGER NOT NULL REFERENCES rutina(id) ON DELETE CASCADE,
      ejercicio_id INTEGER NOT NULL REFERENCES ejercicio(id) ON DELETE CASCADE,
      orden INTEGER NOT NULL,
      PRIMARY KEY (rutina_id, ejercicio_id)
    )''',
    'CREATE INDEX idx_serie_sesion ON serie(sesion_id)',
    'CREATE INDEX idx_sesion_fecha ON sesion(fecha)',
  ];
}
