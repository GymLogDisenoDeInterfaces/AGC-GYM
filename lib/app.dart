import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'controllers/ajustes_controller.dart';
import 'controllers/ejercicios_controller.dart';
import 'controllers/estadisticas_controller.dart';
import 'controllers/historial_controller.dart';
import 'controllers/inicio_controller.dart';
import 'controllers/rutinas_controller.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'l10n/app_localizations.dart';

/// Raíz de agc-gym: providers globales, tema (oscuro por defecto) e idiomas.
class AgcGymApp extends StatelessWidget {
  const AgcGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AjustesController()..cargar()),
        ChangeNotifierProvider(create: (_) => InicioController()),
        ChangeNotifierProvider(create: (_) => EjerciciosController()),
        ChangeNotifierProvider(create: (_) => RutinasController()),
        ChangeNotifierProvider(create: (_) => HistorialController()),
        ChangeNotifierProvider(create: (_) => EstadisticasController()),
      ],
      child: Consumer<AjustesController>(
        builder: (context, ajustes, _) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: temaClaro(),
          darkTheme: temaOscuro(),
          themeMode: ajustes.themeMode,
          locale: ajustes.locale ?? const Locale('es'),
          supportedLocales: const [Locale('es'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
  }
}
