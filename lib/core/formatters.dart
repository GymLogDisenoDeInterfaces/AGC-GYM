import 'package:intl/intl.dart';

/// Pone en mayúscula la primera letra ("lunes" -> "Lunes").
String capitalizar(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

/// "Lunes, 26 de octubre de 2026, 18:30" según el idioma ('es' o 'en').
/// Requiere haber llamado a initializeDateFormatting().
String formatearFecha(DateTime fecha, String idioma) {
  return capitalizar(DateFormat.yMMMMEEEEd(idioma).add_Hm().format(fecha));
}

/// 60 -> "60", 62.5 -> "62.5".
String formatearKg(double kg) {
  return kg == kg.roundToDouble() ? kg.toInt().toString() : kg.toStringAsFixed(1);
}

/// 12345.6 -> "12.346 kg" (es) o "12,346 kg" (en).
String formatearVolumen(double volumen, String idioma) {
  return '${NumberFormat.decimalPattern(idioma).format(volumen.round())} kg';
}
