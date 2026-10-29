import '../data/models/ejercicio.dart';
import '../data/models/serie.dart';
import '../data/repositories/ejercicio_repository.dart';
import '../data/repositories/serie_repository.dart';
import '../core/formatters.dart';
import 'voice_command.dart';
import 'voice_command_parser.dart';

/// Resultado de ejecutar una orden: el texto que se dice en voz alta.
class VoiceResult {
  const VoiceResult(this.mensaje, {this.exito = true, this.cambioDatos = false});

  final String mensaje;
  final bool exito;

  /// true si se ha escrito en la base de datos (la lista debe recargarse).
  final bool cambioDatos;
}

/// Ejecuta una [VoiceCommand] contra SQLite. Las respuestas van en español,
/// el idioma en que se reconocen las órdenes.
class VoiceCommandHandler {
  VoiceCommandHandler({
    required this.sesionId,
    VoiceCommandParser? parser,
    EjercicioRepository? ejercicios,
    SerieRepository? series,
  })  : _parser = parser ?? const VoiceCommandParser(),
        _ejercicios = ejercicios ?? EjercicioRepository(),
        _series = series ?? SerieRepository();

  final int sesionId;
  final VoiceCommandParser _parser;
  final EjercicioRepository _ejercicios;
  final SerieRepository _series;

  Future<VoiceResult> ejecutarTexto(String texto) =>
      ejecutar(_parser.parsear(texto));

  Future<VoiceResult> ejecutar(VoiceCommand orden) async {
    switch (orden) {
      case final AddSetsCommand add:
        return _anadir(add);
      case VolumeQueryCommand():
        final series = await _series.deSesion(sesionId);
        final total = series.fold<double>(0, (s, e) => s + e.volumen);
        if (series.isEmpty) {
          return const VoiceResult('Todavía no llevas ninguna serie hoy.');
        }
        return VoiceResult(
          'Llevas un volumen de ${formatearKg(total)} kilos en esta sesión.',
        );
      case SetsCountQueryCommand():
        final series = await _series.deSesion(sesionId);
        return VoiceResult(switch (series.length) {
          0 => 'Todavía no llevas ninguna serie.',
          1 => 'Llevas una serie.',
          final n => 'Llevas $n series.',
        });
      case UnknownCommand():
        return const VoiceResult(
          'No te he entendido. Prueba con: añade tres series de sentadilla '
          'con sesenta kilos.',
          exito: false,
        );
    }
  }

  Future<VoiceResult> _anadir(AddSetsCommand orden) async {
    final catalogo = await _ejercicios.obtener();
    final ejercicio = buscarEjercicio(catalogo, orden.ejercicio);
    if (ejercicio == null) {
      return VoiceResult(
        'No encuentro el ejercicio ${orden.ejercicio} en el catálogo.',
        exito: false,
      );
    }
    for (var i = 0; i < orden.series; i++) {
      await _series.insertar(
        Serie(
          sesionId: sesionId,
          ejercicioId: ejercicio.id!,
          reps: orden.reps,
          pesoKg: orden.pesoKg,
          origen: SerieOrigen.voz,
        ),
      );
    }
    final peso = orden.pesoKg > 0
        ? ' con ${formatearKg(orden.pesoKg)} kilos'
        : '';
    return VoiceResult(
      'Añadidas ${orden.series} ${orden.series == 1 ? 'serie' : 'series'} '
      'de ${orden.reps} repeticiones de ${ejercicio.nombre}$peso.',
      cambioDatos: true,
    );
  }

  /// Busca el ejercicio del catálogo que mejor coincide con lo que se ha dicho
  /// (ignora tildes y plurales). Devuelve null si no hay ninguno parecido.
  static Ejercicio? buscarEjercicio(List<Ejercicio> catalogo, String dicho) {
    String base(String s) {
      final n = VoiceCommandParser.normalizar(s);
      return n.endsWith('s') && n.length > 3 ? n.substring(0, n.length - 1) : n;
    }

    final buscado = base(dicho);
    if (buscado.isEmpty) return null;

    for (final e in catalogo) {
      if (base(e.nombre) == buscado) return e;
    }
    Ejercicio? mejor;
    var diferencia = 1 << 30;
    for (final e in catalogo) {
      final nombre = base(e.nombre);
      if (nombre.contains(buscado) || buscado.contains(nombre)) {
        final d = (nombre.length - buscado.length).abs();
        if (d < diferencia) {
          mejor = e;
          diferencia = d;
        }
      }
    }
    return mejor;
  }
}
