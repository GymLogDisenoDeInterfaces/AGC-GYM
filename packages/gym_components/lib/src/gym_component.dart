/// Contrato común de los componentes de agc-gym.
///
/// Obliga a cada componente a ofrecer una descripción textual, que se usa como
/// etiqueta de accesibilidad (`Semantics`).
///
/// Ejemplo:
///
/// ```dart
/// class MiComponente extends StatelessWidget implements GymComponent {
///   const MiComponente({super.key});
///
///   @override
///   String get semanticLabel => 'Mi componente';
///
///   @override
///   Widget build(BuildContext context) => Semantics(label: semanticLabel);
/// }
/// ```
abstract interface class GymComponent {
  /// Descripción del componente para lectores de pantalla.
  String get semanticLabel;
}
