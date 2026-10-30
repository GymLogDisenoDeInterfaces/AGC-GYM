import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'burpee_analyzer.dart';
import 'pose_geometry.dart';

/// Resultado de analizar un fotograma.
class PoseFrame {
  const PoseFrame({
    required this.pose,
    required this.imageSize,
    required this.rotation,
    required this.lensDirection,
    this.anguloRodilla,
    this.ratioVertical,
    this.anguloCodo,
  });

  final Pose pose;

  /// Tamaño del fotograma tal y como lo entrega la cámara.
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection lensDirection;

  /// Ángulo cadera-rodilla-tobillo del lado más visible (null si no se ve).
  final double? anguloRodilla;

  /// Relación vertical de elevación del cuerpo (0 a 1) para contar burpees.
  final double? ratioVertical;

  /// Ángulo muñeca-codo-hombro del lado más visible para contar dominadas.
  final double? anguloCodo;
}

/// Cámara + detector de pose de ML Kit. Solo Android e iOS.
class PoseService {
  CameraController? _camara;
  List<CameraDescription> _camaras = [];
  int _indice = 0;
  PoseDetector? _detector;
  bool _ocupado = false;
  bool _activo = false;

  CameraController? get camara => _camara;
  bool get lista => _camara?.value.isInitialized ?? false;
  bool get hayVariasCamaras => _camaras.length > 1;

  static const Map<DeviceOrientation, int> _orientaciones = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  /// Abre la cámara. Devuelve false si no hay ninguna.
  Future<bool> iniciar({bool frontal = false}) async {
    _camaras = await availableCameras();
    if (_camaras.isEmpty) return false;
    final deseada = frontal
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final i = _camaras.indexWhere((c) => c.lensDirection == deseada);
    _indice = i >= 0 ? i : 0;
    await _abrirCamara();
    return true;
  }

  Future<void> _abrirCamara() async {
    await _camara?.dispose();
    final nueva = CameraController(
      _camaras[_indice],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _camara = nueva;
    await nueva.initialize();
  }

  /// Cambia entre cámara trasera y frontal.
  Future<void> cambiarCamara(void Function(PoseFrame) alFotograma) async {
    if (_camaras.length < 2) return;
    final estabaActivo = _activo;
    await detener();
    _indice = (_indice + 1) % _camaras.length;
    await _abrirCamara();
    if (estabaActivo) await empezar(alFotograma);
  }

  /// Empieza a analizar fotogramas; [alFotograma] recibe solo los que tienen
  /// una persona detectada.
  Future<void> empezar(void Function(PoseFrame) alFotograma) async {
    final camara = _camara;
    if (camara == null || !camara.value.isInitialized || _activo) return;
    _detector ??= PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
    );
    _activo = true;
    await camara.startImageStream((imagen) async {
      if (_ocupado || !_activo) return;
      _ocupado = true;
      try {
        final entrada = _aInputImage(imagen);
        if (entrada == null) return;
        final poses = await _detector!.processImage(entrada);
        if (poses.isEmpty || !_activo) return;
        final metadata = entrada.metadata!;
        alFotograma(
          PoseFrame(
            pose: poses.first,
            imageSize: metadata.size,
            rotation: metadata.rotation,
            lensDirection: _camaras[_indice].lensDirection,
            anguloRodilla: anguloDeRodilla(poses.first),
            ratioVertical: ratioVerticalCuerpo(poses.first),
            anguloCodo: anguloDeCodo(poses.first),
          ),
        );
      } catch (_) {
        // Un fotograma fallido se ignora; llegará el siguiente.
      } finally {
        _ocupado = false;
      }
    });
  }

  Future<void> detener() async {
    _activo = false;
    final camara = _camara;
    if (camara != null && camara.value.isStreamingImages) {
      try {
        await camara.stopImageStream();
      } catch (_) {}
    }
  }

  /// Ángulo de la rodilla del lado cuyos tres puntos se ven mejor.
  static double? anguloDeRodilla(Pose pose) {
    double? lado(
      PoseLandmarkType cadera,
      PoseLandmarkType rodilla,
      PoseLandmarkType tobillo,
    ) {
      final a = pose.landmarks[cadera];
      final b = pose.landmarks[rodilla];
      final c = pose.landmarks[tobillo];
      if (a == null || b == null || c == null) return null;
      final seguridad = [a, b, c]
          .map((p) => p.likelihood)
          .reduce((x, y) => x < y ? x : y);
      if (seguridad < 0.5) return null;
      return anguloEntre(
        ax: a.x, ay: a.y, bx: b.x, by: b.y, cx: c.x, cy: c.y,
      );
    }

    final izquierdo = lado(
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
    );
    final derecho = lado(
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
    );
    return izquierdo ?? derecho;
  }

  /// Ratio vertical del cuerpo (0 a 1) para la detección de burpees.
  static double? ratioVerticalCuerpo(Pose pose) {
    double? lado(
      PoseLandmarkType hombro,
      PoseLandmarkType cadera,
      PoseLandmarkType tobillo,
      PoseLandmarkType rodilla,
    ) {
      final h = pose.landmarks[hombro];
      final c = pose.landmarks[cadera];
      final t = (pose.landmarks[tobillo]?.likelihood ?? 0) >= 0.4
          ? pose.landmarks[tobillo]
          : pose.landmarks[rodilla];
      if (h == null || c == null || t == null) return null;
      if (h.likelihood < 0.4 || c.likelihood < 0.4 || t.likelihood < 0.4) {
        return null;
      }
      return calcularRatioVertical(
        sx: h.x,
        sy: h.y,
        ax: t.x,
        ay: t.y,
      );
    }

    final izq = lado(
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.leftKnee,
    );
    final der = lado(
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightAnkle,
      PoseLandmarkType.rightKnee,
    );
    return izq ?? der;
  }

  /// Ángulo de codo (muñeca-codo-hombro) del lado cuyos tres puntos se ven mejor.
  static double? anguloDeCodo(Pose pose) {
    double? lado(
      PoseLandmarkType muneca,
      PoseLandmarkType codo,
      PoseLandmarkType hombro,
    ) {
      final a = pose.landmarks[muneca];
      final b = pose.landmarks[codo];
      final c = pose.landmarks[hombro];
      if (a == null || b == null || c == null) return null;
      final seguridad = [a, b, c]
          .map((p) => p.likelihood)
          .reduce((x, y) => x < y ? x : y);
      if (seguridad < 0.45) return null;
      return anguloEntre(
        ax: a.x,
        ay: a.y,
        bx: b.x,
        by: b.y,
        cx: c.x,
        cy: c.y,
      );
    }

    final izq = lado(
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftShoulder,
    );
    final der = lado(
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightShoulder,
    );
    return izq ?? der;
  }

  InputImage? _aInputImage(CameraImage imagen) {
    final camara = _camaras[_indice];
    final controlador = _camara;
    if (controlador == null) return null;
    final sensor = camara.sensorOrientation;

    InputImageRotation? rotacion;
    if (Platform.isIOS) {
      rotacion = InputImageRotationValue.fromRawValue(sensor);
    } else if (Platform.isAndroid) {
      var compensacion = _orientaciones[controlador.value.deviceOrientation];
      if (compensacion == null) return null;
      if (camara.lensDirection == CameraLensDirection.front) {
        compensacion = (sensor + compensacion) % 360;
      } else {
        compensacion = (sensor - compensacion + 360) % 360;
      }
      rotacion = InputImageRotationValue.fromRawValue(compensacion);
    }
    if (rotacion == null) return null;

    final formato = InputImageFormatValue.fromRawValue(imagen.format.raw);
    if (formato == null ||
        (Platform.isAndroid && formato != InputImageFormat.nv21) ||
        (Platform.isIOS && formato != InputImageFormat.bgra8888)) {
      return null;
    }
    if (imagen.planes.length != 1) return null;
    final plano = imagen.planes.first;

    return InputImage.fromBytes(
      bytes: plano.bytes,
      metadata: InputImageMetadata(
        size: Size(imagen.width.toDouble(), imagen.height.toDouble()),
        rotation: rotacion,
        format: formato,
        bytesPerRow: plano.bytesPerRow,
      ),
    );
  }

  /// Libera cámara y detector (se llama desde dispose()).
  Future<void> liberar() async {
    await detener();
    await _camara?.dispose();
    _camara = null;
    await _detector?.close();
    _detector = null;
  }
}
