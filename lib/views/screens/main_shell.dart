import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/ajustes_controller.dart';
import '../../l10n/app_localizations.dart';

/// Marco con barra inferior para las cinco pantallas principales.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const List<String> _rutas = [
    '/',
    '/rutinas',
    '/ejercicios',
    '/historial',
    '/estadisticas',
  ];

  int _indice(String ubicacion) {
    for (var i = _rutas.length - 1; i >= 0; i--) {
      if (i == 0 ? ubicacion == '/' : ubicacion.startsWith(_rutas[i])) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ubicacion = GoRouterState.of(context).uri.path;
    final indice = _indice(ubicacion);
    final titulos = [
      l.appTitle,
      l.navRoutines,
      l.navExercises,
      l.navHistory,
      l.navStats,
    ];
    final ajustes = context.watch<AjustesController>();
    final oscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: indice == 0
            ? Image.asset(
                'assets/images/logo_transparent.png',
                height: 48,
                fit: BoxFit.contain,
              )
            : Text(titulos[indice]),
        actions: [
          IconButton(
            tooltip: l.toggleTheme,
            icon: Icon(oscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: ajustes.alternarTema,
          ),
          IconButton(
            tooltip: l.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/ajustes'),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: indice,
        onDestinationSelected: (i) => context.go(_rutas[i]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: l.navRoutines,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined),
            selectedIcon: const Icon(Icons.fitness_center),
            label: l.navExercises,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l.navStats,
          ),
        ],
      ),
    );
  }
}
