import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/nui/voice_command.dart';
import 'package:gymlog/nui/voice_command_parser.dart';

void main() {
  const parser = VoiceCommandParser();

  group('normalizar', () {
    test('quita tildes, signos y mayúsculas', () {
      expect(VoiceCommandParser.normalizar('¡Añade, 3 Series!'), 'anade 3 series');
    });
    test('convierte la coma decimal en punto', () {
      expect(VoiceCommandParser.normalizar('62,5 kilos'), '62.5 kilos');
    });
  });

  group('palabrasANumeros', () {
    test('números simples', () {
      expect(VoiceCommandParser.palabrasANumeros('tres series'), '3 series');
    });
    test('decenas compuestas', () {
      expect(VoiceCommandParser.palabrasANumeros('sesenta y cinco kilos'),
          '65 kilos');
    });
    test('y medio', () {
      expect(VoiceCommandParser.palabrasANumeros('sesenta y medio kilos'),
          '60.5 kilos');
    });
    test('cientos', () {
      expect(VoiceCommandParser.palabrasANumeros('ciento veinte'), '120');
    });
    test('deja los dígitos como están', () {
      expect(VoiceCommandParser.palabrasANumeros('3 series'), '3 series');
    });
  });

  group('parsear: orden que escribe', () {
    test('series, ejercicio y peso con palabras', () {
      final c = parser.parsear(
        'Añade tres series de sentadilla con sesenta kilos',
      );
      expect(c, isA<AddSetsCommand>());
      final a = c as AddSetsCommand;
      expect(a.series, 3);
      expect(a.reps, VoiceCommandParser.repsPorDefecto);
      expect(a.ejercicio, 'sentadilla');
      expect(a.pesoKg, 60);
    });

    test('con repeticiones y dígitos', () {
      final a = parser.parsear(
        'agrega 4 series de 8 repeticiones de press banca con 62,5 kilos',
      ) as AddSetsCommand;
      expect(a.series, 4);
      expect(a.reps, 8);
      expect(a.ejercicio, 'press banca');
      expect(a.pesoKg, 62.5);
    });

    test('una serie sin peso', () {
      final a = parser.parsear('anota una serie de 12 repeticiones de dominadas')
          as AddSetsCommand;
      expect(a.series, 1);
      expect(a.reps, 12);
      expect(a.ejercicio, 'dominadas');
      expect(a.pesoKg, 0);
    });

    test('solo repeticiones', () {
      final a = parser.parsear('registra 10 repeticiones de curl con 15 kg')
          as AddSetsCommand;
      expect(a.series, 1);
      expect(a.reps, 10);
      expect(a.pesoKg, 15);
    });
  });

  group('parsear: órdenes que leen', () {
    test('volumen', () {
      expect(parser.parsear('¿Cuánto volumen llevo hoy?'),
          isA<VolumeQueryCommand>());
    });
    test('número de series', () {
      expect(parser.parsear('cuántas series llevo'),
          isA<SetsCountQueryCommand>());
    });
  });

  test('frase desconocida', () {
    expect(parser.parsear('pon música'), isA<UnknownCommand>());
    expect(parser.parsear(''), isA<UnknownCommand>());
  });
}
