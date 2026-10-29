/// Órdenes de voz que entiende la aplicación (en español).
sealed class VoiceCommand {
  const VoiceCommand();
}

/// ESCRIBE en SQLite: "añade tres series de sentadilla con sesenta kilos".
class AddSetsCommand extends VoiceCommand {
  const AddSetsCommand({
    required this.series,
    required this.reps,
    required this.ejercicio,
    required this.pesoKg,
  });

  final int series;
  final int reps;
  final String ejercicio;
  final double pesoKg;
}

/// LEE de SQLite: "cuánto volumen llevo hoy".
class VolumeQueryCommand extends VoiceCommand {
  const VolumeQueryCommand();
}

/// LEE de SQLite: "cuántas series llevo".
class SetsCountQueryCommand extends VoiceCommand {
  const SetsCountQueryCommand();
}

/// Frase que no se ha entendido.
class UnknownCommand extends VoiceCommand {
  const UnknownCommand(this.texto);

  final String texto;
}
