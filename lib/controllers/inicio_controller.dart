// Guillermo - 26/10/2026: He implementado el controlador de inicio con ChangeNotifier para los resúmenes y KPIs semanales.
import '../data/models/sesion.dart';
import '../data/repositories/sesion_repository.dart';
import 'controller_base.dart';

class InicioController extends ControllerBase {
  InicioController({SesionRepository? sesiones})
      : _sesiones = sesiones ?? SesionRepository();

  final SesionRepository _sesiones;

  bool _cargando = true;
  ResumenSemana _semana = const ResumenSemana(sesiones: 0, volumen: 0);
  SesionResumen? _ultima;

  bool get cargando => _cargando;
  ResumenSemana get semana => _semana;
  SesionResumen? get ultima => _ultima;

  Future<void> cargar() async {
    _semana = await _sesiones.resumenSemana();
    final recientes = await _sesiones.resumenes(limite: 1);
    _ultima = recientes.isEmpty ? null : recientes.first;
    _cargando = false;
    notifyListeners();
  }

  /// Crea una sesión vacía con la fecha actual y devuelve su id.
  Future<int> empezarSesion() =>
      _sesiones.insertar(Sesion(fecha: DateTime.now()));
}
