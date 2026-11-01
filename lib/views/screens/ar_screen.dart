// Carlos - 31/10/2026: Maqueta interactiva de realidad aumentada con cámara y superposición 2D para guiar la postura de los pies.
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/platform_support.dart';
import '../../l10n/app_localizations.dart';

/// Maqueta de realidad aumentada: vista previa de la cámara con una
/// superposición 2D de dos huellas que marcan dónde colocar los pies.
class ArScreen extends StatefulWidget {
  const ArScreen({super.key});

  @override
  State<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {
  CameraController? _camara;
  bool _sinCamara = false;
  double _separacionCm = 40;
  double _escala = 1;

  @override
  void initState() {
    super.initState();
    _abrirCamara();
  }

  Future<void> _abrirCamara() async {
    if (!esMovil) {
      setState(() => _sinCamara = true);
      return;
    }
    try {
      final camaras = await availableCameras();
      if (camaras.isEmpty) throw StateError('sin camaras');
      final trasera = camaras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => camaras.first,
      );
      final nueva = CameraController(
        trasera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await nueva.initialize();
      if (!mounted) {
        await nueva.dispose();
        return;
      }
      setState(() => _camara = nueva);
    } catch (_) {
      if (mounted) setState(() => _sinCamara = true);
    }
  }

  @override
  void dispose() {
    _camara?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context);
    final camara = _camara;

    return Scaffold(
      appBar: AppBar(title: Text(l.arTitle)),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (camara != null && camara.value.isInitialized)
                  ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: camara.value.previewSize?.height ?? 1,
                        height: camara.value.previewSize?.width ?? 1,
                        child: CameraPreview(camara),
                      ),
                    ),
                  )
                else
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          tema.colorScheme.surfaceContainerHighest,
                          tema.colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                CustomPaint(
                  painter: _HuellasPainter(
                    separacionCm: _separacionCm,
                    escala: _escala,
                    color: tema.colorScheme.primary,
                  ),
                ),
                if (_sinCamara)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 16,
                    child: Text(
                      l.arCameraUnavailable,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: tema.colorScheme.outline),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.arExplain, style: tema.textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(
                  '${l.arSeparation}: ${l.arSeparationValue(_separacionCm.round())}',
                ),
                Slider(
                  min: 20,
                  max: 70,
                  value: _separacionCm,
                  onChanged: (v) => setState(() => _separacionCm = v),
                ),
                Text(l.arFootSize),
                Slider(
                  min: 0.6,
                  max: 1.4,
                  value: _escala,
                  onChanged: (v) => setState(() => _escala = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HuellasPainter extends CustomPainter {
  _HuellasPainter({
    required this.separacionCm,
    required this.escala,
    required this.color,
  });

  final double separacionCm;
  final double escala;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Se supone un ancho de pantalla de unos 120 cm a la altura del suelo.
    final pxPorCm = size.width / 120;
    final centro = Offset(size.width / 2, size.height * 0.72);
    final mitad = separacionCm * pxPorCm / 2;
    final alto = 110.0 * escala;
    final ancho = 46.0 * escala;

    final relleno = Paint()..color = color.withValues(alpha: 0.35);
    final borde = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (final lado in [-1, 1]) {
      final c = Offset(centro.dx + lado * mitad, centro.dy);
      final huella = RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: ancho, height: alto),
        Radius.circular(ancho / 2),
      );
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(lado * 0.12);
      canvas.translate(-c.dx, -c.dy);
      canvas.drawRRect(huella, relleno);
      canvas.drawRRect(huella, borde);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _HuellasPainter vieja) =>
      vieja.separacionCm != separacionCm ||
      vieja.escala != escala ||
      vieja.color != color;
}
