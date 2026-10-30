import 'dart:io' show Platform;

import 'package:camera/camera.dart' show CameraLensDirection;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Dibuja el esqueleto sobre la vista previa de la cámara.
class PosePainter extends CustomPainter {
  PosePainter({
    required this.pose,
    required this.imageSize,
    required this.rotation,
    required this.lensDirection,
    required this.colorLinea,
    required this.colorPunto,
  });

  final Pose pose;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection lensDirection;
  final Color colorLinea;
  final Color colorPunto;

  static const List<List<PoseLandmarkType>> _huesos = [
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
  ];

  bool get _girada =>
      rotation == InputImageRotation.rotation90deg ||
      rotation == InputImageRotation.rotation270deg;

  double _x(double x, Size lienzo) {
    if (_girada) {
      final ancho = Platform.isIOS ? imageSize.width : imageSize.height;
      final px = x * lienzo.width / ancho;
      return rotation == InputImageRotation.rotation270deg
          ? lienzo.width - px
          : px;
    }
    final px = x * lienzo.width / imageSize.width;
    return lensDirection == CameraLensDirection.front
        ? lienzo.width - px
        : px;
  }

  double _y(double y, Size lienzo) {
    if (_girada) {
      final alto = Platform.isIOS ? imageSize.height : imageSize.width;
      return y * lienzo.height / alto;
    }
    return y * lienzo.height / imageSize.height;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final linea = Paint()
      ..color = colorLinea
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final punto = Paint()..color = colorPunto;

    for (final hueso in _huesos) {
      final a = pose.landmarks[hueso[0]];
      final b = pose.landmarks[hueso[1]];
      if (a == null || b == null) continue;
      canvas.drawLine(
        Offset(_x(a.x, size), _y(a.y, size)),
        Offset(_x(b.x, size), _y(b.y, size)),
        linea,
      );
    }
    for (final p in pose.landmarks.values) {
      canvas.drawCircle(Offset(_x(p.x, size), _y(p.y, size)), 5, punto);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter vieja) => vieja.pose != pose;
}
