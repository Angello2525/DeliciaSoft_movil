class ProductModel {
  final int idProductoGeneral;
  final String nombreProducto;
  final String? descripcion; // <-- añadido
  final double precioProducto;
  final int cantidadProducto;
  final bool estado;
  final int idCategoriaProducto;
  final int? idImagen;
  final int? idReceta;
  final String? urlImg;
  final String? nombreCategoria;

  ProductModel({
    required this.idProductoGeneral,
    required this.nombreProducto,
    this.descripcion, // <-- añadido
    required this.precioProducto,
    required this.cantidadProducto,
    required this.estado,
    required this.idCategoriaProducto,
    this.idImagen,
    this.idReceta,
    this.urlImg,
    this.nombreCategoria,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      idProductoGeneral: _parseToInt(json['idProductoGeneral']),
      nombreProducto: json['nombreProducto']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(), // <-- añadido
      precioProducto: _parseToDouble(json['precioProducto']),
      cantidadProducto: _parseToInt(json['cantidadProducto']),
      estado: json['estado'] == true || json['estado'] == 1 || json['estado'] == 'true',
      idCategoriaProducto: _parseToInt(json['idCategoriaProducto']),
      idImagen: json['idImagen'] != null ? _parseToInt(json['idImagen']) : null,
      idReceta: json['idReceta'] != null ? _parseToInt(json['idReceta']) : null,
      urlImg: json['urlImg']?.toString(),
      nombreCategoria: json['nombreCategoria']?.toString(),
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'idProductoGeneral': idProductoGeneral,
      'nombreProducto': nombreProducto,
      'descripcion': descripcion, // <-- añadido
      'precioProducto': precioProducto,
      'cantidadProducto': cantidadProducto,
      'estado': estado,
      'idCategoriaProducto': idCategoriaProducto,
      'idImagen': idImagen,
      'idReceta': idReceta,
      'urlImg': urlImg,
      'nombreCategoria': nombreCategoria,
    };
  }

  ProductModel copyWith({
    int? idProductoGeneral,
    String? nombreProducto,
    String? descripcion, // <-- añadido
    double? precioProducto,
    int? cantidadProducto,
    bool? estado,
    int? idCategoriaProducto,
    int? idImagen,
    int? idReceta,
    String? urlImg,
    String? nombreCategoria,
  }) {
    return ProductModel(
      idProductoGeneral: idProductoGeneral ?? this.idProductoGeneral,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      descripcion: descripcion ?? this.descripcion, // <-- añadido
      precioProducto: precioProducto ?? this.precioProducto,
      cantidadProducto: cantidadProducto ?? this.cantidadProducto,
      estado: estado ?? this.estado,
      idCategoriaProducto: idCategoriaProducto ?? this.idCategoriaProducto,
      idImagen: idImagen ?? this.idImagen,
      idReceta: idReceta ?? this.idReceta,
      urlImg: urlImg ?? this.urlImg,
      nombreCategoria: nombreCategoria ?? this.nombreCategoria,
    );
  }

  @override
  String toString() {
    return 'ProductModel{idProductoGeneral: $idProductoGeneral, nombreProducto: $nombreProducto, descripcion: $descripcion, precioProducto: $precioProducto, cantidadProducto: $cantidadProducto, estado: $estado, idCategoriaProducto: $idCategoriaProducto, idImagen: $idImagen, idReceta: $idReceta, urlImg: $urlImg, nombreCategoria: $nombreCategoria}';
  }

  bool get tieneImagen => urlImg != null && urlImg!.isNotEmpty;

  String get precioFormateado => '\$${precioProducto.toStringAsFixed(0)}';

  bool get estaDisponible => estado && cantidadProducto > 0;
}
