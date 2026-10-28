// Carlos - 27/10/2026: He programado el controlador de rutinas con ChangeNotifier para gestionar el listado y detalle de entrenamientos.
import '../data/models/ejercicio.dart';
import '../data/models/rutina.dart';
import '../data/models/sesion.dart';
import '../data/repositories/ejercicio_repository.dart';
import '../data/repositories/rutina_repository.dart';
import '../data/repositories/sesion_repository.dart';
import 'controller_base.dart';

class RutinasController extends ControllerBase {
  RutinasController({
    RutinaRepository? rutinas,
    EjercicioRepository? ejercicios,
  })  : _rutinas = rutinas ?? RutinaRepository(),
        _ejerciciosRepo = ejercicios ?? EjercicioRepository();

  final RutinaRepository _rutinas;
  final EjercicioRepository _ejerciciosRepo;

  bool _cargando = true;
  List<Rutina> _items = [];

  bool get cargando => _cargando;
  List<Rutina> get items => List.unmodifiable(_items);

  Future<void> cargar() async {
    _items = await _rutinas.todas();
    _cargando = false;
    notifyListeners();
  }

  /// Catálogo completo para elegir los ejercicios de una rutina nueva.
  Future<List<Ejercicio>> catalogo() => _ejerciciosRepo.obtener();

  Future<void> crear(String nombre, List<int> ejercicioIds) async {
    await _rutinas.crear(nombre, ejercicioIds);
    await cargar();
  }
}

/// Controlador de "Detalle de rutina" (uno por rutina abierta).
class RutinaDetalleController extends ControllerBase {
  RutinaDetalleController({
    required this.rutinaId,
    RutinaRepository? rutinas,
    SesionRepository? sesiones,
  })  : _rutinas = rutinas ?? RutinaRepository(),
        _sesiones = sesiones ?? SesionRepository() {
    cargar();
  }

  final int rutinaId;
  final RutinaRepository _rutinas;
  final SesionRepository _sesiones;

  bool _cargando = true;
  Rutina? _rutina;
  List<Ejercicio> _ejercicios = [];

  bool get cargando => _cargando;
  Rutina? get rutina => _rutina;
  List<Ejercicio> get ejercicios => List.unmodifiable(_ejercicios);

  Future<void> cargar() async {
    _rutina = await _rutinas.obtener(rutinaId);
    _ejercicios = await _rutinas.ejerciciosDe(rutinaId);
    _cargando = false;
    notifyListeners();
  }

  Future<void> eliminar() => _rutinas.eliminar(rutinaId);

  /// Crea una sesión vacía para empezar con esta rutina y devuelve su id.
  Future<int> empezarSesion() =>
      _sesiones.insertar(Sesion(fecha: DateTime.now()));
}
