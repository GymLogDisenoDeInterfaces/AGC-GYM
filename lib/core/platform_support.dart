import 'dart:io' show Platform;

/// Los plugins de cámara, voz y ML Kit solo existen en Android e iOS.
/// En escritorio esas funciones muestran un aviso en lugar de fallar.
bool get esMovil => Platform.isAndroid || Platform.isIOS;
