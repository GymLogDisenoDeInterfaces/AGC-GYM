import 'package:flutter/foundation.dart';

/// ChangeNotifier que no falla si una operación asíncrona termina cuando la
/// pantalla ya se ha cerrado.
abstract class ControllerBase extends ChangeNotifier {
  bool _liberado = false;

  @override
  void notifyListeners() {
    if (!_liberado) super.notifyListeners();
  }

  @override
  void dispose() {
    _liberado = true;
    super.dispose();
  }
}
