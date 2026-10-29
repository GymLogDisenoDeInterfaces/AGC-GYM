// Ayoub - 29/10/2026: He creado el parser fonético de voz en Dart puro para interpretar órdenes de series y consultas.
import 'voice_command.dart';

/// Convierte el texto que devuelve el reconocedor de voz en una [VoiceCommand].
///
/// Es Dart puro (sin plugins), así que se prueba con tests unitarios.
class VoiceCommandParser {
  const VoiceCommandParser();

  /// Repeticiones por serie cuando la frase no las indica.
  static const int repsPorDefecto = 10;

  static const Map<String, int> _numeros = {
    'cero': 0, 'un': 1, 'uno': 1, 'una': 1, 'dos': 2, 'tres': 3,
    'cuatro': 4, 'cinco': 5, 'seis': 6, 'siete': 7, 'ocho': 8, 'nueve': 9,
    'diez': 10, 'once': 11, 'doce': 12, 'trece': 13, 'catorce': 14,
    'quince': 15, 'dieciseis': 16, 'diecisiete': 17, 'dieciocho': 18,
    'diecinueve': 19, 'veinte': 20, 'veintiun': 21, 'veintiuno': 21,
    'veintiuna': 21, 'veintidos': 22, 'veintitres': 23, 'veinticuatro': 24,
    'veinticinco': 25, 'veintiseis': 26, 'veintisiete': 27,
    'veintiocho': 28, 'veintinueve': 29, 'treinta': 30, 'cuarenta': 40,
    'cincuenta': 50, 'sesenta': 60, 'setenta': 70, 'ochenta': 80,
    'noventa': 90, 'cien': 100, 'ciento': 100, 'doscientos': 200,
    'trescientos': 300,
  };

  static final RegExp _verbo = RegExp(
    r'^(?:anade|agrega|anota|apunta|registra|pon|mete|guarda|suma)(?:me)?\s+',
  );

  static final RegExp _conSeries = RegExp(
    r'^(?:las\s+|unas\s+)?(\d+)\s+series?'
    r'(?:\s+de\s+(\d+)\s+(?:repeticiones|reps|veces))?'
    r'\s+(?:de|del)\s+(.+?)'
    r'(?:\s+con\s+(\d+(?:\.\d+)?)\s*(?:kilos?|kgs?|kg))?$',
  );

  static final RegExp _soloReps = RegExp(
    r'^(\d+)\s+(?:repeticiones|reps|veces)\s+(?:de|del)\s+(.+?)'
    r'(?:\s+con\s+(\d+(?:\.\d+)?)\s*(?:kilos?|kgs?|kg))?$',
  );

  /// Minúsculas, sin tildes ni signos; las comas decimales pasan a punto.
  static String normalizar(String texto) {
    const origen = 'áàäâéèëêíìïîóòöôúùüûñ';
    const destino = 'aaaaeeeeiiiioooouuuun';
    final sb = StringBuffer();
    for (final c in texto.toLowerCase().split('')) {
      final i = origen.indexOf(c);
      sb.write(i >= 0 ? destino[i] : c);
    }
    var t = sb.toString();
    t = t.replaceAllMapped(
      RegExp(r'(\d),(\d)'),
      (m) => '${m[1]}.${m[2]}',
    );
    t = t.replaceAll(RegExp(r'[^a-z0-9. ]'), ' ');
    t = t.replaceAll(RegExp(r'(?<!\d)\.|\.(?!\d)'), ' ');
    return t.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// "sesenta y cinco" -> "65", "sesenta y medio" -> "60.5".
  static String palabrasANumeros(String normalizado) {
    final tokens = normalizado.isEmpty ? <String>[] : normalizado.split(' ');
    final salida = <String>[];
    int? acum;
    var vioY = false;

    void volcar() {
      if (acum != null) salida.add('$acum');
      acum = null;
      vioY = false;
    }

    for (var i = 0; i < tokens.length; i++) {
      final t = tokens[i];
      final valor = _numeros[t];
      final siguiente = i + 1 < tokens.length ? tokens[i + 1] : null;

      if (valor != null) {
        final actual = acum;
        if (actual == null) {
          acum = valor;
        } else if (actual >= 100 && actual % 100 == 0 && valor < 100) {
          acum = actual + valor;
        } else if (vioY && actual >= 30 && actual < 100 && valor < 10) {
          acum = actual + valor;
        } else {
          volcar();
          acum = valor;
        }
        vioY = false;
      } else if (t == 'y' &&
          acum != null &&
          siguiente != null &&
          (_numeros.containsKey(siguiente) ||
              siguiente == 'medio' ||
              siguiente == 'media')) {
        vioY = true;
      } else if ((t == 'medio' || t == 'media') && acum != null && vioY) {
        salida.add('$acum.5');
        acum = null;
        vioY = false;
      } else {
        volcar();
        salida.add(t);
      }
    }
    volcar();
    return salida.join(' ');
  }

  /// Interpreta una frase dicha por el usuario.
  VoiceCommand parsear(String textoOriginal) {
    final t = palabrasANumeros(normalizar(textoOriginal));
    if (t.isEmpty) return UnknownCommand(textoOriginal);

    // Órdenes que LEEN de la base de datos.
    if (t.contains('volumen')) return const VolumeQueryCommand();
    if (RegExp(r'cuantas series|series (?:llevo|he hecho)').hasMatch(t)) {
      return const SetsCountQueryCommand();
    }

    // Orden que ESCRIBE en la base de datos.
    final sinVerbo = t.replaceFirst(_verbo, '');
    if (sinVerbo != t) {
      final m1 = _conSeries.firstMatch(sinVerbo);
      if (m1 != null) {
        final series = int.parse(m1[1]!);
        final reps = m1[2] == null ? repsPorDefecto : int.parse(m1[2]!);
        final peso = m1[4] == null ? 0.0 : double.parse(m1[4]!);
        if (series > 0 && reps > 0) {
          return AddSetsCommand(
            series: series,
            reps: reps,
            ejercicio: m1[3]!.trim(),
            pesoKg: peso,
          );
        }
      }
      final m2 = _soloReps.firstMatch(sinVerbo);
      if (m2 != null) {
        final reps = int.parse(m2[1]!);
        final peso = m2[3] == null ? 0.0 : double.parse(m2[3]!);
        if (reps > 0) {
          return AddSetsCommand(
            series: 1,
            reps: reps,
            ejercicio: m2[2]!.trim(),
            pesoKg: peso,
          );
        }
      }
    }
    return UnknownCommand(textoOriginal);
  }
}
