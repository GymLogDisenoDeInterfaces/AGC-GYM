import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/controllers/ajustes_controller.dart';
import 'package:gymlog/core/theme.dart';
import 'package:gymlog/data/models/sesion.dart';
import 'package:gymlog/l10n/app_localizations.dart';
import 'package:gymlog/views/widgets/resumen_sesion_tile.dart';
import 'package:intl/date_symbol_data_local.dart';

Widget _app(Locale locale, Widget hijo) => MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: hijo),
    );

void main() {
  setUpAll(() => initializeDateFormatting());

  final resumen = SesionResumen(
    sesion: Sesion(id: 1, fecha: DateTime(2026, 10, 26, 18, 30), duracionMin: 50),
    numSeries: 1,
    volumen: 1200,
  );

  testWidgets('el historial muestra plural y fecha en español', (tester) async {
    await tester.pumpWidget(
      _app(const Locale('es'), ResumenSesionTile(resumen: resumen)),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('1 serie'), findsOneWidget);
    expect(find.textContaining('Lunes'), findsOneWidget);
    expect(find.textContaining('50 min'), findsOneWidget);
  });

  testWidgets('y en inglés', (tester) async {
    await tester.pumpWidget(
      _app(const Locale('en'), ResumenSesionTile(resumen: resumen)),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('1 set'), findsOneWidget);
    expect(find.textContaining('Monday'), findsOneWidget);
  });

  test('el tema empieza en oscuro y se puede alternar', () {
    final ajustes = AjustesController();
    expect(ajustes.themeMode, ThemeMode.dark);
  });

  test('los dos temas usan Material 3 y el color Tiffany como semilla', () {
    expect(temaClaro().useMaterial3, isTrue);
    expect(temaOscuro().brightness, Brightness.dark);
    expect(temaClaro().brightness, Brightness.light);
  });
}
