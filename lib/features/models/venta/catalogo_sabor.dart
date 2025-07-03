// lib/models/catalogo_sabor.dart
class CatalogoSabor {
  final int idSabor;
  final String? nombre;
  final double? precioAdicion;
  final int? idInsumos;
  final bool? estado;

  CatalogoSabor({
    required this.idSabor,
    this.nombre,
    this.precioAdicion,
    this.idInsumos,
    this.estado,
  });

  factory CatalogoSabor.fromJson(Map<String, dynamic> json) {
    return CatalogoSabor(
      idSabor: json['idSabor'],
      nombre: json['nombre'],
      precioAdicion: (json['precioAdicion'] as num?)?.toDouble(),
      idInsumos: json['idInsumos'],
      estado: json['estado'],
    );
  }
}