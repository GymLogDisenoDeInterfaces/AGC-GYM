import 'package:flutter/material.dart';

import '../data/repositories/ajuste_repository.dart';
import 'controller_base.dart';

/// Tema (oscuro por defecto) e idioma, guardados en SQLite.
class AjustesController extends ControllerBase {
  AjustesController({AjusteRepository? repositorio})
      : _repo = repositorio ?? AjusteRepository();

  static const String _claveTema = 'tema';
  static const String _claveIdioma = 'idioma';

  final AjusteRepository _repo;

  ThemeMode _themeMode = ThemeMode.dark;
  Locale? _locale = const Locale('es');

  ThemeMode get themeMode => _themeMode;

  /// Por defecto en español; si el usuario guarda en ajustes, se persiste.
  Locale? get locale => _locale;

  Future<void> cargar() async {
    final tema = await _repo.obtener(_claveTema);
    final idioma = await _repo.obtener(_claveIdioma);
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == tema,
      orElse: () => ThemeMode.dark,
    );
    _locale = (idioma == 'es' || idioma == 'en')
        ? Locale(idioma!)
        : const Locale('es');
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode modo) async {
    if (modo == _themeMode) return;
    _themeMode = modo;
    notifyListeners();
    await _repo.guardar(_claveTema, modo.name);
  }

  /// Botón rápido: alterna entre oscuro y claro.
  Future<void> alternarTema() => setThemeMode(
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
      );

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    if (locale == null) {
      await _repo.borrar(_claveIdioma);
    } else {
      await _repo.guardar(_claveIdioma, locale.languageCode);
    }
  }
}
