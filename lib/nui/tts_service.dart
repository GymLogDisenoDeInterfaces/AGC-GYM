// Ayoub - 30/10/2026: He configurado flutter_tts para dar respuesta por voz tras procesar cada orden.
import 'package:flutter_tts/flutter_tts.dart';

/// Envoltorio de flutter_tts para responder en voz alta.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _configurado = false;

  Future<void> hablar(String texto, {String idioma = 'es-ES'}) async {
    try {
      if (!_configurado) {
        await _tts.setLanguage(idioma);
        _configurado = true;
      }
      await _tts.stop();
      await _tts.speak(texto);
    } catch (_) {
      // Si el motor de voz del sistema falla, la app sigue funcionando.
    }
  }

  Future<void> parar() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> liberar() => parar();
}
