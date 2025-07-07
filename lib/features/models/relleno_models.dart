class RellenoModel {
  final int idRelleno;
  final String nombre;
  final double precioAdicion;
  final int idInsumos;
  final bool estado;

  RellenoModel({
    required this.idRelleno,
    required this.nombre,
    required this.precioAdicion,
    required this.idInsumos,
    required this.estado,
  });

  factory RellenoModel.fromJson(Map<String, dynamic> json) {
    return RellenoModel(
      idRelleno: json['idRelleno'] ?? 0,
      nombre: json['nombre'] ?? '',
      precioAdicion: (json['precioAdicion'] ?? 0).toDouble(),
      idInsumos: json['idInsumos'] ?? 0,
      estado: json['estado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRelleno': idRelleno,
      'nombre': nombre,
      'precioAdicion': precioAdicion,
      'idInsumos': idInsumos,
      'estado': estado,
    };
  }

  @override
  String toString() {
    return 'RellenoModel(idRelleno: $idRelleno, nombre: $nombre, precioAdicion: $precioAdicion, idInsumos: $idInsumos, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RellenoModel && other.idRelleno == idRelleno;
  }

  @override
  int get hashCode => idRelleno.hashCode;
}