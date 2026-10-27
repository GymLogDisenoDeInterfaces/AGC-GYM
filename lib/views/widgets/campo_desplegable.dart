import 'package:flutter/material.dart';

/// Desplegable con el aspecto de un campo de formulario. Funciona dentro de
/// AlertDialog y no depende de APIs de formulario que han ido cambiando.
class CampoDesplegable<T> extends StatelessWidget {
  const CampoDesplegable({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.items,
    required this.onChanged,
    this.textoError,
  });

  final String etiqueta;
  final T? valor;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? textoError;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: etiqueta, errorText: textoError),
      isEmpty: valor == null,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          isDense: true,
          value: valor,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
