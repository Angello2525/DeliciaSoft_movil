class ProductoGeneral {
  final int idProductoGeneral;
  final String? nombreProducto;
  final double? precioProducto;
  final double? cantidadProducto; // Assuming this is stock quantity
  final bool? estado;
  final int? idCategoriaProducto;
  final int? idImagen;
  final int? idReceta;

  ProductoGeneral({
    required this.idProductoGeneral,
    this.nombreProducto,
    this.precioProducto,
    this.cantidadProducto,
    this.estado,
    this.idCategoriaProducto,
    this.idImagen,
    this.idReceta,
  });

  factory ProductoGeneral.fromJson(Map<String, dynamic> json) {
    return ProductoGeneral(
      idProductoGeneral: json['idProductoGeneral'],
      nombreProducto: json['nombreProducto'],
      precioProducto: (json['precioProducto'] as num?)?.toDouble(),
      cantidadProducto: (json['cantidadProducto'] as num?)?.toDouble(),
      estado: json['estado'],
      idCategoriaProducto: json['idCategoriaProducto'],
      idImagen: json['idImagen'],
      idReceta: json['idReceta'],
    );
  }
}
