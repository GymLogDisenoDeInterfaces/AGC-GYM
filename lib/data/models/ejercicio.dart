class Ejercicio {
  const Ejercicio({this.id, required this.nombre, required this.grupoMuscular});

  final int? id;
  final String nombre;
  final String grupoMuscular;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'grupo_muscular': grupoMuscular,
      };

  factory Ejercicio.fromMap(Map<String, Object?> map) => Ejercicio(
        id: map['id'] as int?,
        nombre: map['nombre'] as String,
        grupoMuscular: map['grupo_muscular'] as String,
      );

  Ejercicio copyWith({int? id, String? nombre, String? grupoMuscular}) =>
      Ejercicio(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        grupoMuscular: grupoMuscular ?? this.grupoMuscular,
      );
}
