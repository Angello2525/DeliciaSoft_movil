// lib/models/catalogo_adicione.dart
class CatalogoAdicione {
  final int idAdiciones;
  final int? idInsumos;
  final String? nombre;
  final double? precioAdicion;
  final bool? estado;

  CatalogoAdicione({
    required this.idAdiciones,
    this.idInsumos,
    this.nombre,
    this.precioAdicion,
    this.estado,
  });

  factory CatalogoAdicione.fromJson(Map<String, dynamic> json) {
    return CatalogoAdicione(
      idAdiciones: json['idAdiciones'],
      idInsumos: json['idInsumos'],
      nombre: json['nombre'],
      precioAdicion: (json['precioAdicion'] as num?)?.toDouble(),
      estado: json['estado'],
    );
  }
}