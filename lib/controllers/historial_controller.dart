import '../data/models/sesion.dart';
import '../data/models/serie.dart';
import '../data/repositories/serie_repository.dart';
import '../data/repositories/sesion_repository.dart';
import 'controller_base.dart';

class HistorialController extends ControllerBase {
  HistorialController({SesionRepository? sesiones})
      : _sesiones = sesiones ?? SesionRepository();

  final SesionRepository _sesiones;

  bool _cargando = true;
  List<SesionResumen> _items = [];

  bool get cargando => _cargando;
  List<SesionResumen> get items => List.unmodifiable(_items);

  Future<void> cargar() async {
    _items = await _sesiones.resumenes();
    _cargando = false;
    notifyListeners();
  }

  Future<void> eliminar(int sesionId) async {
    await _sesiones.eliminar(sesionId);
    await cargar();
  }
}

/// Controlador de "Detalle de sesión" (uno por sesión abierta).
class DetalleSesionController extends ControllerBase {
  DetalleSesionController({
    required this.sesionId,
    SesionRepository? sesiones,
    SerieRepository? series,
  })  : _sesiones = sesiones ?? SesionRepository(),
        _seriesRepo = series ?? SerieRepository() {
    cargar();
  }

  final int sesionId;
  final SesionRepository _sesiones;
  final SerieRepository _seriesRepo;

  bool _cargando = true;
  SesionResumen? _resumen;
  List<Serie> _series = [];

  bool get cargando => _cargando;
  SesionResumen? get resumen => _resumen;
  List<Serie> get series => List.unmodifiable(_series);

  Future<void> cargar() async {
    _resumen = await _sesiones.resumenPorId(sesionId);
    _series = await _seriesRepo.deSesion(sesionId);
    _cargando = false;
    notifyListeners();
  }
}
