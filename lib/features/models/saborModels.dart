class SaborModel {
  final int idSabor;
  final String nombre;
  final double precioAdicion;
  final int idInsumos;
  final bool estado;

  SaborModel({
    required this.idSabor,
    required this.nombre,
    required this.precioAdicion,
    required this.idInsumos,
    required this.estado,
  });

  factory SaborModel.fromJson(Map<String, dynamic> json) {
    return SaborModel(
      idSabor: json['idSabor'] ?? 0,
      nombre: json['nombre'] ?? '',
      precioAdicion: (json['precioAdicion'] ?? 0).toDouble(),
      idInsumos: json['idInsumos'] ?? 0,
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSabor': idSabor,
      'nombre': nombre,
      'precioAdicion': precioAdicion,
      'idInsumos': idInsumos,
      'estado': estado,
    };
  }

  @override
  String toString() {
    return 'SaborModel(idSabor: $idSabor, nombre: $nombre, precioAdicion: $precioAdicion, idInsumos: $idInsumos, estado: $estado)';
  }
}