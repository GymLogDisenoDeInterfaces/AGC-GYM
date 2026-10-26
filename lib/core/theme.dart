// Guillermo - 24/10/2026: He definido el tema Material 3 con ColorScheme.fromSeed usando el color Tiffany para claro y oscuro.
import 'package:flutter/material.dart';

/// Azul eléctrico Tiffany: color semilla de toda la paleta Material 3.
const Color colorTiffany = Color(0xFF0ABAB5);

ThemeData _construirTema(Brightness brillo) {
  final oscuro = brillo == Brightness.dark;
  final esquema = ColorScheme.fromSeed(
    seedColor: colorTiffany,
    brightness: brillo,
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    // Oscuro: casi negro con un toque azulado (aspecto de gimnasio).
    // Claro: fondo limpio y casi blanco.
    scaffoldBackgroundColor:
        oscuro ? const Color(0xFF0B1416) : const Color(0xFFF7FBFB),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: esquema.onSurface,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: oscuro ? const Color(0xFF101C1F) : Colors.white,
      indicatorColor: esquema.primaryContainer,
    ),
  );
}

ThemeData temaClaro() => _construirTema(Brightness.light);
ThemeData temaOscuro() => _construirTema(Brightness.dark);
