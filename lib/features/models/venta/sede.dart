class Sede {
  final int idSede;
  final String nombre;
  final String telefono;
  final String direccion;
  final bool estado;

  Sede({
    required this.idSede,
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.estado,
  });

  factory Sede.fromJson(Map<String, dynamic> json) {
    return Sede(
      idSede: json['idSede'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSede': idSede,
      'nombre': nombre,
      'telefono': telefono,
      'direccion': direccion,
      'estado': estado,
    };
  }
}
