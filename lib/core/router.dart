// Guillermo - 25/10/2026: He configurado el enrutador de la app con go_router para enlazar las 11 pantallas con paso de parámetros.
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/historial_controller.dart';
import '../controllers/pose_controller.dart';
import '../controllers/rutinas_controller.dart';
import '../controllers/sesion_controller.dart';
import '../controllers/voz_controller.dart';
import '../views/screens/ajustes_screen.dart';
import '../views/screens/ar_screen.dart';
import '../views/screens/detalle_sesion_screen.dart';
import '../views/screens/ejercicios_screen.dart';
import '../views/screens/estadisticas_screen.dart';
import '../views/screens/historial_screen.dart';
import '../views/screens/inicio_screen.dart';
import '../views/screens/main_shell.dart';
import '../views/screens/pose_screen.dart';
import '../views/screens/rutina_detalle_screen.dart';
import '../views/screens/rutinas_screen.dart';
import '../views/screens/sesion_screen.dart';

int _idDe(GoRouterState state) => int.parse(state.pathParameters['id']!);

/// Rutas de la aplicación. Los controladores de las pantallas con parámetro
/// se crean aquí para que cada pantalla parta sin datos de la anterior.
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const InicioScreen()),
        GoRoute(
          path: '/rutinas',
          builder: (context, state) => const RutinasScreen(),
        ),
        GoRoute(
          path: '/ejercicios',
          builder: (context, state) => const EjerciciosScreen(),
        ),
        GoRoute(
          path: '/historial',
          builder: (context, state) => const HistorialScreen(),
        ),
        GoRoute(
          path: '/estadisticas',
          builder: (context, state) => const EstadisticasScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/rutinas/:id',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => RutinaDetalleController(rutinaId: _idDe(state)),
        child: const RutinaDetalleScreen(),
      ),
    ),
    GoRoute(
      path: '/historial/:id',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => DetalleSesionController(sesionId: _idDe(state)),
        child: const DetalleSesionScreen(),
      ),
    ),
    GoRoute(
      path: '/sesion/:id',
      builder: (context, state) {
        final id = _idDe(state);
        final rutina = int.tryParse(state.uri.queryParameters['rutina'] ?? '');
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => SesionController(sesionId: id, rutinaId: rutina),
            ),
            ChangeNotifierProvider(
              create: (ctx) => VozController(
                sesionId: id,
                alCambiarDatos: ctx.read<SesionController>().recargarSeries,
              ),
            ),
          ],
          child: const SesionScreen(),
        );
      },
      routes: [
        GoRoute(
          path: 'pose',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => PoseController(sesionId: _idDe(state)),
            child: const PoseScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/ajustes',
      builder: (context, state) => const AjustesScreen(),
      routes: [
        GoRoute(path: 'ar', builder: (context, state) => const ArScreen()),
      ],
    ),
  ],
);
