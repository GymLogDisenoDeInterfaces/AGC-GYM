// Ayoub - 24/10/2026: He preparado los datos semilla iniciales con 22 ejercicios y 10 sesiones históricas de ejemplo.
import 'package:sqflite/sqflite.dart';

/// (nombre, grupo muscular)
const List<(String, String)> _ejercicios = [
  ('Press banca', 'Pecho'), //                         0
  ('Press inclinado con mancuernas', 'Pecho'), //      1
  ('Aperturas en polea', 'Pecho'), //                  2
  ('Dominadas', 'Espalda'), //                         3
  ('Remo con barra', 'Espalda'), //                    4
  ('Jalón al pecho', 'Espalda'), //                    5
  ('Sentadilla', 'Pierna'), //                         6
  ('Peso muerto rumano', 'Pierna'), //                 7
  ('Prensa de piernas', 'Pierna'), //                  8
  ('Press militar', 'Hombro'), //                      9
  ('Elevaciones laterales', 'Hombro'), //             10
  ('Curl de bíceps', 'Brazo'), //                     11
  ('Extensión de tríceps', 'Brazo'), //               12
  ('Elevación de piernas', 'Core'), //                13
  ('Crunch abdominal', 'Core'), //                    14
  ('Fondos en paralelas', 'Pecho'), //                15
  ('Remo en polea baja', 'Espalda'), //               16
  ('Hip Thrust con barra', 'Pierna'), //              17
  ('Face pull en polea', 'Hombro'), //                18
  ('Curl martillo', 'Brazo'), //                      19
  ('Press francés', 'Brazo'), //                      20
  ('Plancha isométrica', 'Core'), //                  21
];

class _Bloque {
  const _Bloque(this.ejercicio, this.reps, this.kg, this.series,
      [this.origen = 'manual', this.rir]);

  final int ejercicio;
  final int reps;
  final double kg;
  final int series;
  final String origen;
  final int? rir;
}

class _SesionSeed {
  const _SesionSeed(this.haceDias, this.minutos, this.bloques);

  final int haceDias;
  final int minutos;
  final List<_Bloque> bloques;
}

const List<_SesionSeed> _sesiones = [
  _SesionSeed(27, 55, [_Bloque(0, 10, 60, 3, 'manual', 1), _Bloque(1, 12, 22, 3, 'manual', 1), _Bloque(2, 15, 15, 2, 'manual', 0)]),
  _SesionSeed(24, 60, [_Bloque(6, 8, 80, 4, 'manual', 0), _Bloque(8, 12, 140, 3, 'manual', 1)]),
  _SesionSeed(20, 50, [_Bloque(3, 8, 0, 3, 'manual', 1), _Bloque(4, 10, 50, 3, 'manual', 1)]),
  _SesionSeed(15, 65, [_Bloque(0, 8, 65, 3, 'manual', 1), _Bloque(9, 10, 35, 3, 'manual', 0)]),
  _SesionSeed(12, 60, [_Bloque(6, 8, 85, 4, 'pose', 0), _Bloque(7, 10, 70, 3, 'manual', 1)]),
  _SesionSeed(7, 55, [_Bloque(5, 12, 55, 3, 'manual', 1), _Bloque(11, 12, 15, 3, 'manual', 0), _Bloque(12, 12, 25, 2, 'manual', 1)]),
  _SesionSeed(5, 50, [_Bloque(6, 8, 90, 4, 'manual', 0), _Bloque(7, 10, 80, 3, 'manual', 1), _Bloque(8, 12, 160, 3, 'manual', 0)]),
  _SesionSeed(3, 60, [_Bloque(3, 8, 0, 4, 'manual', 1), _Bloque(4, 10, 60, 3, 'manual', 1), _Bloque(11, 10, 17.5, 3, 'manual', 0)]),
  _SesionSeed(1, 45, [_Bloque(0, 8, 75, 4, 'manual', 1), _Bloque(1, 10, 26, 3, 'manual', 1), _Bloque(9, 10, 40, 3, 'voz', 0)]),
];

/// Rutinas de ejemplo: Programa PPL Frecuencia 2 completo (6 días con RIR 0 y 1).
const List<(String, List<int>)> _rutinas = [
  ('Push 1 · Pecho & Tríceps (RIR 1)', [0, 1, 15, 10, 12]),
  ('Pull 1 · Espalda & Bíceps (RIR 1)', [3, 5, 16, 18, 11]),
  ('Legs 1 · Cuádriceps (RIR 0 · Fallo)', [6, 8, 17, 13]),
  ('Push 2 · Hombro & Pecho (RIR 0 · Fallo)', [9, 1, 2, 10, 20]),
  ('Pull 2 · Grosor & Bíceps (RIR 1)', [4, 3, 16, 19, 14]),
  ('Legs 2 · Cadena Posterior (RIR 0 · Fallo)', [7, 17, 8, 6, 21]),
];

/// Datos de ejemplo de la primera ejecución: 15 ejercicios, 7 sesiones
/// repartidas en las últimas 4 semanas, 48 series y 2 rutinas.
Future<void> sembrarDatos(Database db) async {
  final idsEjercicio = <int>[];
  for (final e in _ejercicios) {
    idsEjercicio.add(
      await db.insert('ejercicio', {'nombre': e.$1, 'grupo_muscular': e.$2}),
    );
  }

  final ahora = DateTime.now();
  for (final s in _sesiones) {
    final fecha = DateTime(ahora.year, ahora.month, ahora.day - s.haceDias, 18, 30);
    final idSesion = await db.insert('sesion', {
      'fecha': fecha.toIso8601String(),
      'duracion_min': s.minutos,
    });
    for (final b in s.bloques) {
      for (var i = 0; i < b.series; i++) {
        await db.insert('serie', {
          'sesion_id': idSesion,
          'ejercicio_id': idsEjercicio[b.ejercicio],
          'reps': b.reps,
          'peso_kg': b.kg,
          'origen': b.origen,
          if (b.rir != null) 'rir': b.rir,
        });
      }
    }
  }

  for (final r in _rutinas) {
    final idRutina = await db.insert('rutina', {'nombre': r.$1});
    for (var orden = 0; orden < r.$2.length; orden++) {
      await db.insert('rutina_ejercicio', {
        'rutina_id': idRutina,
        'ejercicio_id': idsEjercicio[r.$2[orden]],
        'orden': orden,
      });
    }
  }
}
