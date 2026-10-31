import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Envuelve un widget en una app Material con el tema Tiffany claro u oscuro.
Widget app(Widget hijo, {Brightness brillo = Brightness.light}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0ABAB5),
        brightness: brillo,
      ),
    ),
    home: Scaffold(body: Center(child: hijo)),
  );
}

/// Compara con la imagen golden `test/goldens/<nombre>`.
///
/// Si la imagen todavía no existe, se genera (primera ejecución) y hay que
/// subirla al repositorio.
Future<void> comparaGolden(WidgetTester tester, String nombre) async {
  final existe = File('test/goldens/$nombre').existsSync();
  if (!existe) autoUpdateGoldenFiles = true;
  try {
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$nombre'),
    );
  } finally {
    autoUpdateGoldenFiles = false;
  }
}
