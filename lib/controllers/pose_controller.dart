import 'package:flutter/foundation.dart';

import '../data/models/ejercicio.dart';
import '../data/models/serie.dart';
import '../data/repositories/ejercicio_repository.dart';
import '../data/repositories/serie_repository.dart';
import '../nui/burpee_analyzer.dart';
import '../nui/pose_service.dart';
import '../nui/pull_up_analyzer.dart';
import '../nui/squat_analyzer.dart';
import '../nui/tts_service.dart';
import 'controller_base.dart';

enum EstadoPose { parado, iniciando, activo, error }

/// Modo de ejercicio activo en el contador por cámara.
enum ModoEjercicioPose { sentadillas, burpees, dominadas }

/// Controlador de la pantalla del contador por pose.
class PoseController extends ControllerBase {
  PoseController({
    required this.sesionId,
    PoseService? servicio,
    TtsService? tts,
    SquatAnalyzer? analizador,
    BurpeeAnalyzer? analizadorBurpee,
    PullUpAnalyzer? analizadorDominadas,
    EjercicioRepository? ejercicios,
    SerieRepository? series,
  })  : _servicio = servicio ?? PoseService(),
        _tts = tts ?? TtsService(),
        _analizador = analizador ?? SquatAnalyzer(),
        _analizadorBurpee = analizadorBurpee ?? BurpeeAnalyzer(),
        _analizadorDominadas = analizadorDominadas ?? PullUpAnalyzer(),
        _ejercicios = ejercicios ?? EjercicioRepository(),
        _series = series ?? SerieRepository() {
    cargarSeries();
  }

  static const String nombreSentadilla = 'Sentadilla';
  static const String nombreBurpees = 'Burpees';
  static const String nombreDominadas = 'Dominadas';

  final int sesionId;
  final PoseService _servicio;
  final TtsService _tts;
  final SquatAnalyzer _analizador;
  final BurpeeAnalyzer _analizadorBurpee;
  final PullUpAnalyzer _analizadorDominadas;
  final EjercicioRepository _ejercicios;
  final SerieRepository _series;

  ModoEjercicioPose _modo = ModoEjercicioPose.sentadillas;

  /// Textos que se dicen en voz alta; la pantalla los rellena con el idioma
  /// activo.
  String avisoIncompleto = 'Sentadilla incompleta';
  String avisoDominadaIncompleta = 'Dominada incompleta';
  String avisoObjetivo = '¡Objetivo alcanzado!';
  String idiomaTts = 'es-ES';

  EstadoPose _estado = EstadoPose.parado;
  PoseFrame? _ultimo;
  bool _incompleta = false;
  bool _objetivoAvisado = false;
  int _objetivo = 10;
  double _peso = 0;
  List<Serie> _seriesSesion = [];
  bool _sinCamara = false;

  ModoEjercicioPose get modo => _modo;
  EstadoPose get estado => _estado;
  PoseFrame? get ultimoFotograma => _ultimo;
  double? get anguloRodilla => _ultimo?.anguloRodilla;
  double? get ratioVertical => _ultimo?.ratioVertical;
  double? get anguloCodo => _ultimo?.anguloCodo;
  BurpeeFase get faseBurpee => _analizadorBurpee.fase;
  bool get incompleta => _incompleta;
  bool get sinCamara => _sinCamara;
  int get reps {
    switch (_modo) {
      case ModoEjercicioPose.sentadillas:
        return _analizador.reps;
      case ModoEjercicioPose.burpees:
        return _analizadorBurpee.reps;
      case ModoEjercicioPose.dominadas:
        return _analizadorDominadas.reps;
    }
  }
  int get objetivo => _objetivo;
  double get peso => _peso;
  List<Serie> get seriesSesion => List.unmodifiable(_seriesSesion);
  PoseService get servicio => _servicio;

  void cambiarModo(ModoEjercicioPose nuevoModo) {
    if (_modo == nuevoModo) return;
    _modo = nuevoModo;
    reiniciar();
  }

  void setObjetivo(int valor) {
    if (valor < 1) return;
    _objetivo = valor;
    _objetivoAvisado = reps >= valor;
    notifyListeners();
  }

  void setPeso(double valor) {
    _peso = valor < 0 ? 0 : valor;
    notifyListeners();
  }

  Future<void> cargarSeries() async {
    _seriesSesion = await _series.deSesion(sesionId);
    notifyListeners();
  }

  /// Abre la cámara y empieza a contar.
  Future<void> empezar() async {
    if (_estado == EstadoPose.iniciando || _estado == EstadoPose.activo) {
      return;
    }
    _estado = EstadoPose.iniciando;
    _sinCamara = false;
    notifyListeners();
    try {
      final hay = await _servicio.iniciar();
      if (!hay) {
        _sinCamara = true;
        _estado = EstadoPose.error;
        notifyListeners();
        return;
      }
      await _servicio.empezar(_alFotograma);
      _estado = EstadoPose.activo;
    } catch (_) {
      _estado = EstadoPose.error;
    }
    notifyListeners();
  }

  Future<void> parar() async {
    await _servicio.detener();
    _estado = EstadoPose.parado;
    _ultimo = null;
    notifyListeners();
  }

  Future<void> cambiarCamara() => _servicio.cambiarCamara(_alFotograma);

  void _alFotograma(PoseFrame fotograma) {
    _ultimo = fotograma;
    switch (_modo) {
      case ModoEjercicioPose.sentadillas:
        final angulo = fotograma.anguloRodilla;
        if (angulo != null) _procesarAngulo(angulo);
      case ModoEjercicioPose.burpees:
        final ratio = fotograma.ratioVertical;
        if (ratio != null) _procesarRatioBurpee(ratio);
      case ModoEjercicioPose.dominadas:
        final codo = fotograma.anguloCodo;
        if (codo != null) _procesarAnguloDominada(codo);
    }
    notifyListeners();
  }

  /// Procesa un ángulo de rodilla (público para poder probarlo sin cámara).
  @visibleForTesting
  void procesarAnguloParaPruebas(double angulo) {
    _procesarAngulo(angulo);
    notifyListeners();
  }

  /// Procesa un ratio vertical (público para poder probarlo sin cámara).
  @visibleForTesting
  void procesarRatioParaPruebas(double ratio) {
    _procesarRatioBurpee(ratio);
    notifyListeners();
  }

  /// Procesa un ángulo de codo para dominadas (público para poder probarlo sin cámara).
  @visibleForTesting
  void procesarCodoParaPruebas(double angulo) {
    _procesarAnguloDominada(angulo);
    notifyListeners();
  }

  void _procesarAngulo(double angulo) {
    switch (_analizador.update(angulo)) {
      case SquatEvent.repCounted:
        _incompleta = false;
        _comprobarObjetivo();
      case SquatEvent.incomplete:
        _incompleta = true;
        _tts.hablar(avisoIncompleto, idioma: idiomaTts);
      case SquatEvent.none:
        break;
    }
  }

  void _procesarRatioBurpee(double ratio) {
    final evento = _analizadorBurpee.update(ratio);
    if (evento == BurpeeEvent.repCounted) {
      _incompleta = false;
      _comprobarObjetivo();
    }
  }

  void _procesarAnguloDominada(double angulo) {
    switch (_analizadorDominadas.update(angulo)) {
      case PullUpEvent.repCounted:
        _incompleta = false;
        _comprobarObjetivo();
      case PullUpEvent.incomplete:
        _incompleta = true;
        _tts.hablar(avisoDominadaIncompleta, idioma: idiomaTts);
      case PullUpEvent.none:
        break;
    }
  }

  /// Alternativa táctil: suma una repetición sin cámara.
  void sumarManual() {
    switch (_modo) {
      case ModoEjercicioPose.sentadillas:
        _analizador.sumarManual();
      case ModoEjercicioPose.burpees:
        _analizadorBurpee.sumarManual();
      case ModoEjercicioPose.dominadas:
        _analizadorDominadas.sumarManual();
    }
    _incompleta = false;
    _comprobarObjetivo();
    notifyListeners();
  }

  void _comprobarObjetivo() {
    if (!_objetivoAvisado && reps >= _objetivo) {
      _objetivoAvisado = true;
      _tts.hablar(avisoObjetivo, idioma: idiomaTts);
    }
  }

  void reiniciar() {
    _analizador.reiniciar();
    _analizadorBurpee.reiniciar();
    _analizadorDominadas.reiniciar();
    _incompleta = false;
    _objetivoAvisado = false;
    notifyListeners();
  }

  /// Guarda las repeticiones contadas como una serie con origen 'pose'.
  /// Devuelve el número de repeticiones guardadas (0 si no había ninguna).
  Future<int> guardarSerie() async {
    final repeticiones = reps;
    if (repeticiones <= 0) return 0;
    final Ejercicio ejercicio;
    switch (_modo) {
      case ModoEjercicioPose.sentadillas:
        ejercicio = await _ejercicioSentadilla();
      case ModoEjercicioPose.burpees:
        ejercicio = await _ejercicioBurpees();
      case ModoEjercicioPose.dominadas:
        ejercicio = await _ejercicioDominadas();
    }
    await _series.insertar(
      Serie(
        sesionId: sesionId,
        ejercicioId: ejercicio.id!,
        reps: repeticiones,
        pesoKg: _peso,
        origen: SerieOrigen.pose,
      ),
    );
    reiniciar();
    await cargarSeries();
    return repeticiones;
  }

  Future<Ejercicio> _ejercicioDominadas() async {
    final todos = await _ejercicios.obtener(busqueda: 'dominadas');
    final existente = todos.where(
      (e) => e.nombre.toLowerCase() == nombreDominadas.toLowerCase(),
    );
    if (existente.isNotEmpty) return existente.first;
    if (todos.isNotEmpty) return todos.first;
    final id = await _ejercicios.insertar(
      const Ejercicio(nombre: nombreDominadas, grupoMuscular: 'Espalda'),
    );
    return Ejercicio(
      id: id,
      nombre: nombreDominadas,
      grupoMuscular: 'Espalda',
    );
  }

  Future<Ejercicio> _ejercicioBurpees() async {
    final todos = await _ejercicios.obtener(busqueda: 'burpee');
    final existente = todos.where(
      (e) => e.nombre.toLowerCase() == nombreBurpees.toLowerCase(),
    );
    if (existente.isNotEmpty) return existente.first;
    if (todos.isNotEmpty) return todos.first;
    final id = await _ejercicios.insertar(
      const Ejercicio(nombre: nombreBurpees, grupoMuscular: 'Pierna'),
    );
    return Ejercicio(
      id: id,
      nombre: nombreBurpees,
      grupoMuscular: 'Pierna',
    );
  }

  Future<Ejercicio> _ejercicioSentadilla() async {
    final todos = await _ejercicios.obtener(busqueda: 'sentadilla');
    final existente = todos.where(
      (e) => e.nombre.toLowerCase() == nombreSentadilla.toLowerCase(),
    );
    if (existente.isNotEmpty) return existente.first;
    if (todos.isNotEmpty) return todos.first;
    final id = await _ejercicios.insertar(
      const Ejercicio(nombre: nombreSentadilla, grupoMuscular: 'Pierna'),
    );
    return Ejercicio(
      id: id,
      nombre: nombreSentadilla,
      grupoMuscular: 'Pierna',
    );
  }

  @override
  void dispose() {
    _servicio.liberar();
    _tts.liberar();
    super.dispose();
  }
}
