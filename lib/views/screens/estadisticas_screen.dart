// Carlos - 29/10/2026: Pantalla de estadísticas con gráficos interactivos de barras usando fl_chart para el tonelaje semanal.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/estadisticas_controller.dart';
import '../../core/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/serie_ui.dart';

/// Pantalla 9: volumen semanal (SUM + JOIN) y series por grupo (COUNT + JOIN).
class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<EstadisticasController>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ctrl = context.watch<EstadisticasController>();
    final tema = Theme.of(context);
    final idioma = idiomaActivo(context);

    if (ctrl.cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.vacio) {
      return EstadoVacio(icono: Icons.bar_chart, mensaje: l.noStats);
    }

    final semanas = ctrl.semanas;
    final maximo = semanas.fold<double>(0, (m, s) => s.volumen > m ? s.volumen : m);
    final maxSeries = ctrl.grupos.fold<int>(1, (m, g) => g.series > m ? g.series : m);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.weeklyVolume, style: tema.textTheme.titleMedium),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maximo <= 0 ? 1 : maximo * 1.2,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (var i = 0; i < semanas.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: semanas[i].volumen,
                        width: 18,
                        color: tema.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
              ],
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (valor, meta) {
                      final i = valor.toInt();
                      if (i < 0 || i >= semanas.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l.weekShort(semanas[i].numeroSemana),
                          style: tema.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (grupo, indiceGrupo, barra, indiceBarra) =>
                      BarTooltipItem(
                    formatearVolumen(barra.toY, idioma),
                    TextStyle(
                      color: tema.colorScheme.onInverseSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(l.setsByGroup, style: tema.textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final g in ctrl.grupos)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    nombreGrupo(l, g.grupo),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: g.series / maxSeries,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                    color: colorGrupo(g.grupo, oscuro: tema.brightness == Brightness.dark),
                    backgroundColor: colorGrupo(g.grupo, oscuro: tema.brightness == Brightness.dark).withValues(alpha: 0.18),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 40,
                  child: Text('${g.series}', textAlign: TextAlign.end),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
