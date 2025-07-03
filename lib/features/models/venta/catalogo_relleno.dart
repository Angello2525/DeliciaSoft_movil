// lib/models/catalogo_relleno.dart
class CatalogoRelleno {
  final int idRelleno;
  final String? nombre;
  final double? precioAdicion;
  final int? idInsumos;
  final bool? estado;

  CatalogoRelleno({
    required this.idRelleno,
    this.nombre,
    this.precioAdicion,
    this.idInsumos,
    this.estado,
  });

  factory CatalogoRelleno.fromJson(Map<String, dynamic> json) {
    return CatalogoRelleno(
      idRelleno: json['idRelleno'],
      nombre: json['nombre'],
      precioAdicion: (json['precioAdicion'] as num?)?.toDouble(),
      idInsumos: json['idInsumos'],
      estado: json['estado'],
    );
  }
}