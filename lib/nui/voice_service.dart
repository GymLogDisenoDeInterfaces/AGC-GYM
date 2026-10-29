// Ayoub - 29/10/2026: He integrado el servicio de speech_to_text para escuchar órdenes en español y gestionar permisos.
import 'package:speech_to_text/speech_to_text.dart';

/// Envoltorio de speech_to_text: reconoce frases en español.
class VoiceService {
  final SpeechToText _stt = SpeechToText();
  bool _listo = false;
  String? _localeId;

  bool get escuchando => _stt.isListening;

  /// Pide el permiso del micrófono (lo hace el propio plugin) y prepara el
  /// reconocedor. Devuelve false si no está disponible.
  Future<bool> inicializar({
    void Function(String estado)? onEstado,
    void Function(String error)? onError,
  }) async {
    if (_listo) return true;
    try {
      _listo = await _stt.initialize(
        onStatus: (estado) => onEstado?.call(estado),
        onError: (error) => onError?.call(error.errorMsg),
      );
      if (_listo) {
        final idiomas = await _stt.locales();
        for (final l in idiomas) {
          if (l.localeId.toLowerCase().startsWith('es')) {
            _localeId = l.localeId;
            break;
          }
        }
      }
    } catch (_) {
      _listo = false;
    }
    return _listo;
  }

  Future<void> escuchar(
    void Function(String texto, bool definitivo) alResultado,
  ) async {
    if (!_listo) return;
    await _stt.listen(
      onResult: (r) => alResultado(r.recognizedWords, r.finalResult),
      listenOptions: SpeechListenOptions(
        localeId: _localeId,
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> parar() async {
    try {
      await _stt.stop();
    } catch (_) {}
  }

  Future<void> liberar() async {
    try {
      await _stt.cancel();
    } catch (_) {}
  }
}
