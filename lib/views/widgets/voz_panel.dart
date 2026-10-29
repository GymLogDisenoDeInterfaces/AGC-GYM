import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/voz_controller.dart';
import '../../core/platform_support.dart';
import '../../l10n/app_localizations.dart';

/// Micrófono animado + texto reconocido en directo + respuesta de la app.
class VozPanel extends StatelessWidget {
  const VozPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final voz = context.watch<VozController>();
    final colores = Theme.of(context).colorScheme;

    String mensaje;
    if (!esMovil) {
      mensaje = l.voiceUnavailable;
    } else if (voz.noDisponible) {
      mensaje = l.voiceNotReady;
    } else if (voz.estado == EstadoVoz.escuchando) {
      mensaje = voz.texto.isEmpty ? l.voiceListening : voz.texto;
    } else if (voz.estado == EstadoVoz.procesando) {
      mensaje = l.voiceProcessing;
    } else if (voz.respuesta.isNotEmpty) {
      mensaje = voz.respuesta;
    } else {
      mensaje = l.voiceTapToSpeak;
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _Microfono(
              activo: voz.escuchando,
              habilitado: esMovil,
              tooltip: voz.escuchando ? l.voiceStopTooltip : l.voiceMicTooltip,
              onPressed: voz.alternar,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mensaje,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: voz.fallo ? colores.error : null,
                      fontWeight:
                          voz.escuchando ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.voiceHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colores.outline,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Microfono extends StatefulWidget {
  const _Microfono({
    required this.activo,
    required this.habilitado,
    required this.tooltip,
    required this.onPressed,
  });

  final bool activo;
  final bool habilitado;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  State<_Microfono> createState() => _MicrofonoState();
}

class _MicrofonoState extends State<_Microfono>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didUpdateWidget(covariant _Microfono viejo) {
    super.didUpdateWidget(viejo);
    if (widget.activo && !_pulso.isAnimating) {
      _pulso.repeat(reverse: true);
    } else if (!widget.activo && _pulso.isAnimating) {
      _pulso.stop();
      _pulso.value = 0;
    }
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return SizedBox(
      width: 64,
      height: 64,
      child: AnimatedBuilder(
        animation: _pulso,
        builder: (context, hijo) {
          final radio = 24 + 8 * _pulso.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: radio * 2,
                height: radio * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colores.primary
                      .withValues(alpha: widget.activo ? 0.25 : 0),
                ),
              ),
              hijo!,
            ],
          );
        },
        child: IconButton.filled(
          tooltip: widget.tooltip,
          onPressed: widget.habilitado ? widget.onPressed : null,
          icon: Icon(widget.activo ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }
}
