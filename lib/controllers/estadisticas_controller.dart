// Carlos - 28/10/2026: He implementado el controlador de estadísticas que consulta el volumen semanal acumulado mediante agregados SQL (SUM).
import '../data/models/estadisticas.dart';
import '../data/repositories/estadistica_repository.dart';
import 'controller_base.dart';

class EstadisticasController extends ControllerBase {
  EstadisticasController({EstadisticaRepository? repositorio})
      : _repo = repositorio ?? EstadisticaRepository();

  final EstadisticaRepository _repo;

  bool _cargando = true;
  List<VolumenSemana> _semanas = [];
  List<SeriesPorGrupo> _grupos = [];

  bool get cargando => _cargando;
  List<VolumenSemana> get semanas => List.unmodifiable(_semanas);
  List<SeriesPorGrupo> get grupos => List.unmodifiable(_grupos);
  bool get vacio => _semanas.isEmpty;

  Future<void> cargar() async {
    _semanas = await _repo.volumenSemanal();
    _grupos = await _repo.seriesPorGrupo();
    _cargando = false;
    notifyListeners();
  }
}
