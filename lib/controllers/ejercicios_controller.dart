// Carlos - 26/10/2026: He creado el controlador del catálogo de ejercicios con búsqueda por texto y filtrado por grupo muscular.
import 'package:sqflite/sqflite.dart';

import '../data/models/ejercicio.dart';
import '../data/repositories/ejercicio_repository.dart';
import 'controller_base.dart';

/// Errores posibles; la pantalla los traduce a texto en el idioma activo.
enum ErrorEjercicio { duplicado, enUso, guardar, borrar }

class EjerciciosController extends ControllerBase {
  EjerciciosController({EjercicioRepository? repositorio})
      : _repo = repositorio ?? EjercicioRepository();

  final EjercicioRepository _repo;

  List<Ejercicio> _items = [];
  String? _grupo;
  String _busqueda = '';
  bool _cargando = true;

  List<Ejercicio> get items => List.unmodifiable(_items);
  String? get grupo => _grupo;
  bool get cargando => _cargando;

  Future<void> cargar() async {
    _items = await _repo.obtener(grupo: _grupo, busqueda: _busqueda);
    _cargando = false;
    notifyListeners();
  }

  Future<void> setBusqueda(String texto) {
    _busqueda = texto;
    return cargar();
  }

  Future<void> setGrupo(String? grupo) {
    _grupo = grupo;
    return cargar();
  }

  /// Crea o edita. Devuelve el error, o null si todo fue bien.
  Future<ErrorEjercicio?> guardar(Ejercicio ejercicio) async {
    try {
      if (ejercicio.id == null) {
        await _repo.insertar(ejercicio);
      } else {
        await _repo.actualizar(ejercicio);
      }
      await cargar();
      return null;
    } on DatabaseException catch (e) {
      return e.isUniqueConstraintError()
          ? ErrorEjercicio.duplicado
          : ErrorEjercicio.guardar;
    }
  }

  /// Devuelve el error, o null si todo fue bien.
  Future<ErrorEjercicio?> eliminar(Ejercicio ejercicio) async {
    try {
      await _repo.eliminar(ejercicio.id!);
      await cargar();
      return null;
    } on DatabaseException catch (e) {
      return e.toString().contains('FOREIGN KEY')
          ? ErrorEjercicio.enUso
          : ErrorEjercicio.borrar;
    }
  }
}
