// Guillermo - 26/10/2026: Pantalla principal de la app con indicadores semanales, selector de tema y acceso rápido a entrenar.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/inicio_controller.dart';
import '../../core/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/resumen_sesion_tile.dart';
import '../widgets/serie_ui.dart';

/// Pantalla 1: resumen de la última semana y acceso a empezar una sesión.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InicioController>().cargar();
    });
  }

  Future<void> _empezar() async {
    final ctrl = context.read<InicioController>();
    final router = GoRouter.of(context);
    final id = await ctrl.empezarSesion();
    await router.push('/sesion/$id');
    await ctrl.cargar();
  }

  Future<void> _abrirModoSensores() async {
    final ctrl = context.read<InicioController>();
    final router = GoRouter.of(context);
    final id = await ctrl.empezarSesion();
    await router.push('/sesion/$id/pose');
    await ctrl.cargar();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ctrl = context.watch<InicioController>();
    final tema = Theme.of(context);
    final oscuro = tema.brightness == Brightness.dark;
    final idioma = idiomaActivo(context);

    if (ctrl.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.last7Days, style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Dato(
                valor: '${ctrl.semana.sesiones}',
                etiqueta: l.sessionsLabel,
                icono: Icons.event_available,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Dato(
                valor: formatearVolumen(ctrl.semana.volumen, idioma),
                etiqueta: l.volumeLabel,
                icono: Icons.scale,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _empezar,
          icon: const Icon(Icons.play_arrow),
          label: Text(l.startSession),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF0ABAB5).withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/push.jpg',
                height: 195,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(height: 195),
              ),
              Container(
                height: 195,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.94),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0ABAB5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PROGRAMA DESTACADO',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PPL Frecuencia 2',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Push 1 · Pecho & Tríceps (RIR 1)',
                            style: TextStyle(
                              color: Color(0xFF80CBC4),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0ABAB5),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => context.go('/rutinas'),
                      child: const Text(
                        'Ver Rutinas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          elevation: oscuro ? 2 : 1,
          color: oscuro ? const Color(0xFF101C1F) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFF00E676)
                  .withValues(alpha: oscuro ? 0.35 : 0.5),
              width: 1.2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00E676)
                      .withValues(alpha: oscuro ? 0.08 : 0.12),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676)
                        .withValues(alpha: oscuro ? 0.15 : 0.22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.accessibility_new,
                    color: Color(0xFF00C853),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Modo Sensores · IA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: oscuro
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676)
                                  .withValues(alpha: oscuro ? 0.2 : 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ML KIT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00A34F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Contador automático por cámara',
                        style: TextStyle(
                          fontSize: 12,
                          color: oscuro
                              ? Colors.white70
                              : const Color(0xFF475569),
                          fontWeight:
                              oscuro ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        oscuro ? null : const Color(0xFFE8F5E9),
                    foregroundColor:
                        oscuro ? null : const Color(0xFF1B5E20),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: _abrirModoSensores,
                  child: const Text(
                    'Entrenar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(l.lastWorkout, style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (ctrl.ultima == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(l.noWorkoutsYet),
          )
        else
          Card(
            child: ResumenSesionTile(
              resumen: ctrl.ultima!,
              onTap: () => context.push('/historial/${ctrl.ultima!.sesion.id}'),
            ),
          ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.valor,
    required this.etiqueta,
    required this.icono,
  });

  final String valor;
  final String etiqueta;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      color: tema.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: tema.colorScheme.onPrimaryContainer),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valor,
                style: tema.textTheme.headlineSmall?.copyWith(
                  color: tema.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              etiqueta,
              style: TextStyle(color: tema.colorScheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}
