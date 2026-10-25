class Rutina {
  const Rutina({this.id, required this.nombre, this.numEjercicios = 0});

  final int? id;
  final String nombre;

  /// Solo viene rellenado en la consulta de listado (COUNT con JOIN).
  final int numEjercicios;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'nombre': nombre,
      };

  factory Rutina.fromMap(Map<String, Object?> map) => Rutina(
        id: map['id'] as int?,
        nombre: map['nombre'] as String,
        numEjercicios: (map['num_ejercicios'] as int?) ?? 0,
      );
}
