// Ayoub - 28/10/2026: He implementado el controlador de la sesión en curso con ChangeNotifier para manejar las series en tiempo real.
import '../data/models/ejercicio.dart';
import '../data/models/sesion.dart';
import '../data/models/serie.dart';
import '../data/repositories/ejercicio_repository.dart';
import '../data/repositories/rutina_repository.dart';
import '../data/repositories/serie_repository.dart';
import '../data/repositories/sesion_repository.dart';
import 'controller_base.dart';

/// Controlador de la pantalla "Sesión en curso" (uno por sesión).
class SesionController extends ControllerBase {
  SesionController({
    required this.sesionId,
    this.rutinaId,
    SesionRepository? sesiones,
    SerieRepository? series,
    EjercicioRepository? ejercicios,
    RutinaRepository? rutinas,
  })  : _sesiones = sesiones ?? SesionRepository(),
        _seriesRepo = series ?? SerieRepository(),
        _ejerciciosRepo = ejercicios ?? EjercicioRepository(),
        _rutinas = rutinas ?? RutinaRepository() {
    cargar();
  }

  /// Objetivo de repeticiones de la sesión que muestra el RepCounter.
  static const int objetivoRepeticiones = 50;

  final int sesionId;
  final int? rutinaId;
  final SesionRepository _sesiones;
  final SerieRepository _seriesRepo;
  final EjercicioRepository _ejerciciosRepo;
  final RutinaRepository _rutinas;

  bool _cargando = true;
  Sesion? _sesion;
  List<Serie> _series = [];
  List<Ejercicio> _ejercicios = [];

  bool get cargando => _cargando;
  Sesion? get sesion => _sesion;
  List<Serie> get series => List.unmodifiable(_series);

  /// Ejercicios para elegir: primero los de la rutina (si hay), luego el resto.
  List<Ejercicio> get ejercicios => List.unmodifiable(_ejercicios);

  double get volumenTotal => _series.fold(0, (suma, s) => suma + s.volumen);
  int get repeticionesTotales => _series.fold(0, (suma, s) => suma + s.reps);

  Future<void> cargar() async {
    _sesion = await _sesiones.obtener(sesionId);
    _series = await _seriesRepo.deSesion(sesionId);
    final todos = await _ejerciciosRepo.obtener();
    if (rutinaId != null) {
      final deRutina = await _rutinas.ejerciciosDe(rutinaId!);
      final ids = deRutina.map((e) => e.id).toSet();
      _ejercicios = [...deRutina, ...todos.where((e) => !ids.contains(e.id))];
    } else {
      _ejercicios = todos;
    }
    _cargando = false;
    notifyListeners();
  }

  /// Vuelve a leer las series (lo usan la voz y la pose al añadir filas).
  Future<void> recargarSeries() async {
    _series = await _seriesRepo.deSesion(sesionId);
    notifyListeners();
  }

  Future<void> anadirSerie(Serie serie) async {
    await _seriesRepo.insertar(serie);
    await recargarSeries();
  }

  Future<void> editarSerie(Serie serie) async {
    await _seriesRepo.actualizar(serie);
    await recargarSeries();
  }

  /// Quita la serie de la lista de inmediato (lo exige Dismissible) y después
  /// la borra de la base de datos.
  Future<void> eliminarSerie(Serie serie) async {
    _series.removeWhere((s) => s.id == serie.id);
    notifyListeners();
    await _seriesRepo.eliminar(serie.id!);
  }

  /// Deshacer: reinserta la serie con su mismo id (recupera su posición).
  Future<void> restaurarSerie(Serie serie) async {
    await _seriesRepo.insertar(serie);
    await recargarSeries();
  }

  /// Atajo de teclado: suma una repetición a la última serie.
  Future<void> sumarRepUltima() async {
    if (_series.isEmpty) return;
    final nueva = _series.last.copyWith(reps: _series.last.reps + 1);
    _series[_series.length - 1] = nueva;
    notifyListeners();
    await _seriesRepo.actualizar(nueva);
  }

  /// Si el usuario sale con la flecha atrás y no hay series, la sesión vacía
  /// se descarta para que no ensucie el historial.
  Future<void> descartarSiVacia() async {
    if (_series.isEmpty && _sesion != null) {
      await _sesiones.eliminar(_sesion!.id!);
    }
  }

  /// Cierra la sesión. Si no tiene series se descarta y devuelve false.
  Future<bool> terminar() async {
    final actual = _sesion;
    if (actual == null) return false;
    if (_series.isEmpty) {
      await _sesiones.eliminar(actual.id!);
      return false;
    }
    final minutos = DateTime.now().difference(actual.fecha).inMinutes;
    await _sesiones.actualizarDuracion(actual.id!, minutos < 1 ? 1 : minutos);
    return true;
  }
}
