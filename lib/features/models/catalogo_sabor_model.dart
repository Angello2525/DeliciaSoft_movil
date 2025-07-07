class CatalogoSaborModel {
  final int? idSabor;
  final String? nombre;
  final double? precioAdicion;
  final int? idInsumos;
  final bool? estado;

  CatalogoSaborModel({
    this.idSabor,
    this.nombre,
    this.precioAdicion,
    this.idInsumos,
    this.estado,
  });

  // Constructor para crear desde JSON
  factory CatalogoSaborModel.fromJson(Map<String, dynamic> json) {
    return CatalogoSaborModel(
      idSabor: json['idSabor'] as int?,
      nombre: json['nombre'] as String?,
      precioAdicion: json['precioAdicion']?.toDouble(),
      idInsumos: json['idInsumos'] as int?,
      estado: json['estado'] as bool?,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'idSabor': idSabor,
      'nombre': nombre,
      'precioAdicion': precioAdicion,
      'idInsumos': idInsumos,
      'estado': estado,
    };
  }

  // Método copyWith actualizado
  CatalogoSaborModel copyWith({
    int? idSabor,
    String? nombre,
    double? precioAdicion,
    int? idInsumos,
    bool? estado,
  }) {
    return CatalogoSaborModel(
      idSabor: idSabor ?? this.idSabor,
      nombre: nombre ?? this.nombre,
      precioAdicion: precioAdicion ?? this.precioAdicion,
      idInsumos: idInsumos ?? this.idInsumos,
      estado: estado ?? this.estado,
    );
  }

  @override
  String toString() {
    return 'CatalogoSaborModel(idSabor: $idSabor, nombre: $nombre, precioAdicion: $precioAdicion, idInsumos: $idInsumos, estado: $estado)';
  }
}