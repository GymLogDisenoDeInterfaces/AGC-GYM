import '../nui/tts_service.dart';
import '../nui/voice_command_handler.dart';
import '../nui/voice_service.dart';
import 'controller_base.dart';

enum EstadoVoz { inactivo, escuchando, procesando }

/// Controlador del micrófono de la pantalla de sesión.
class VozController extends ControllerBase {
  VozController({
    required int sesionId,
    required this.alCambiarDatos,
    VoiceService? voz,
    TtsService? tts,
    VoiceCommandHandler? manejador,
  })  : _voz = voz ?? VoiceService(),
        _tts = tts ?? TtsService(),
        _manejador = manejador ?? VoiceCommandHandler(sesionId: sesionId);

  /// Se llama cuando una orden ha escrito en SQLite (para recargar la lista).
  final Future<void> Function() alCambiarDatos;

  final VoiceService _voz;
  final TtsService _tts;
  final VoiceCommandHandler _manejador;

  EstadoVoz _estado = EstadoVoz.inactivo;
  String _texto = '';
  String _respuesta = '';
  bool _fallo = false;
  bool _noDisponible = false;

  EstadoVoz get estado => _estado;

  /// Lo que se está reconociendo en directo.
  String get texto => _texto;

  /// Lo que responde la app (también se dice en voz alta).
  String get respuesta => _respuesta;
  bool get fallo => _fallo;
  bool get noDisponible => _noDisponible;
  bool get escuchando => _estado == EstadoVoz.escuchando;

  Future<void> alternar() async {
    if (_estado == EstadoVoz.procesando) return;
    if (escuchando) {
      await _voz.parar();
      return;
    }
    _texto = '';
    _respuesta = '';
    _fallo = false;
    _noDisponible = false;
    final listo = await _voz.inicializar(
      onEstado: _alCambiarEstado,
      onError: (_) {
        if (_estado == EstadoVoz.escuchando) {
          _estado = EstadoVoz.inactivo;
          notifyListeners();
        }
      },
    );
    if (!listo) {
      _noDisponible = true;
      notifyListeners();
      return;
    }
    _estado = EstadoVoz.escuchando;
    notifyListeners();
    await _tts.parar();
    await _voz.escuchar((texto, definitivo) {
      _texto = texto;
      notifyListeners();
      if (definitivo) _procesar(texto);
    });
  }

  void _alCambiarEstado(String estado) {
    if ((estado == 'done' || estado == 'notListening') &&
        _estado == EstadoVoz.escuchando) {
      _estado = EstadoVoz.inactivo;
      notifyListeners();
    }
  }

  Future<void> _procesar(String texto) async {
    if (_estado == EstadoVoz.procesando || texto.trim().isEmpty) return;
    _estado = EstadoVoz.procesando;
    notifyListeners();
    final resultado = await _manejador.ejecutarTexto(texto);
    _respuesta = resultado.mensaje;
    _fallo = !resultado.exito;
    _estado = EstadoVoz.inactivo;
    notifyListeners();
    if (resultado.cambioDatos) await alCambiarDatos();
    await _tts.hablar(resultado.mensaje);
  }

  /// Permite probar una orden escribiéndola (sin micrófono).
  Future<void> ejecutarTexto(String texto) => _procesar(texto);

  @override
  void dispose() {
    _voz.liberar();
    _tts.liberar();
    super.dispose();
  }
}
