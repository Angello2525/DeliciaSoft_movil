class Sede {
  final int idSede;
  final String? nombre;  
  final String? telefono;
  final String? direccion;
  final bool? estado;

  Sede({
    required this.idSede,
    this.nombre, 
    this.telefono,
    this.direccion,
    this.estado,
  });

  factory Sede.fromJson(Map<String, dynamic> json) {
    return Sede(
      idSede: json['idSede'],
      nombre: json['nombre'],
      telefono: json['Telefono'],
      direccion: json['Direccion'],
      estado: json['Estado'],
    );
  }
}