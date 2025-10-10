// lib/models/General_models.dart
class ProductModel {
  final int idProductoGeneral;
  final String nombreProducto;
  final String? descripcion;
  final double precioProducto;
  final int cantidadProducto;
  final bool estado;
  final int idCategoriaProducto;
  final int? idImagen;
  final int? idReceta;
  final String? urlImg;
  final String? nombreCategoria;
  final String? nombreReceta;

  ProductModel({
    required this.idProductoGeneral,
    required this.nombreProducto,
    this.descripcion,
    required this.precioProducto,
    required this.cantidadProducto,
    required this.estado,
    required this.idCategoriaProducto,
    this.idImagen,
    this.idReceta,
    this.urlImg,
    this.nombreCategoria,
    this.nombreReceta,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    bool _toBool(dynamic v) {
      if (v == null) return true;
      if (v is bool) return v;
      if (v is int) return v == 1;
      if (v is String) {
        final s = v.toLowerCase();
        return s == 'true' || s == '1' || s == 'si' || s == 'yes';
      }
      return true;
    }

    String _toString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    // ID producto
    final id = _toInt(json['idproductogeneral'] ?? json['idProductoGeneral'] ?? json['id']);

    // Nombre producto
    final name = _toString(json['nombreproducto'] ?? json['nombreProducto'] ?? json['nombre']);

    // Descripción / especificaciones receta
    final desc = _toString(
      json['especificacionesreceta'] ??
      json['descripcion'] ??
      json['descripcionProducto'] ??
      json['detalle'] ??
      json['receta']?['especificaciones'] ??
      ''
    );

    // Precio
    final precio = _toDouble(json['precioproducto'] ?? json['precioProducto'] ?? json['precio']);

    // Cantidad
    final cantidad = _toInt(json['cantidadproducto'] ?? json['cantidadProducto'] ?? 1);

    // Estado
    final estado = _toBool(json['estado'] ?? json['isActive'] ?? json['activo']);

    // ID categoría
    final idCategoria = _toInt(json['idcategoriaproducto'] ?? json['idCategoriaProducto'] ?? 0);

    // ID imagen
    final idImg = _toInt(
      json['idimagen'] ?? json['idImagen'] ?? json['imagenId'] ?? json['imagenes']?['idimagen']
    );

    // URL imagen
    final url = _toString(
      json['urlimagen'] ?? json['urlImg'] ?? json['urlImagen'] ?? json['imagenes']?['urlimg']
    );

    // Nombre categoría
    final nombreCat = _toString(
      json['categoria'] ?? json['nombreCategoria'] ?? json['categoriaproducto']?['nombrecategoria']
    );

    // ID receta
    final idRec = _toInt(json['idreceta'] ?? json['idReceta'] ?? json['recetaId']);

    // Nombre receta
    final nombreRec = _toString(
      json['receta']?['nombrereceta'] ?? json['nombrereceta']
    );

    return ProductModel(
      idProductoGeneral: id,
      nombreProducto: name,
      descripcion: desc.isEmpty ? null : desc,
      precioProducto: precio,
      cantidadProducto: cantidad,
      estado: estado,
      idCategoriaProducto: idCategoria,
      idImagen: idImg != 0 ? idImg : null,
      idReceta: idRec != 0 ? idRec : null,
      urlImg: url.isEmpty ? null : url,
      nombreCategoria: nombreCat.isEmpty ? null : nombreCat,
      nombreReceta: nombreRec.isEmpty ? null : nombreRec,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idproductogeneral': idProductoGeneral,
      'nombreproducto': nombreProducto,
      'especificacionesreceta': descripcion,
      'precioproducto': precioProducto,
      'cantidadproducto': cantidadProducto,
      'estado': estado,
      'idcategoriaproducto': idCategoriaProducto,
      'idimagen': idImagen,
      'idreceta': idReceta,
      'urlimagen': urlImg,
      'categoria': nombreCategoria,
      'nombrereceta': nombreReceta,
    };
  }

  ProductModel copyWith({
    int? idProductoGeneral,
    String? nombreProducto,
    String? descripcion,
    double? precioProducto,
    int? cantidadProducto,
    bool? estado,
    int? idCategoriaProducto,
    int? idImagen,
    int? idReceta,
    String? urlImg,
    String? nombreCategoria,
    String? nombreReceta,
  }) {
    return ProductModel(
      idProductoGeneral: idProductoGeneral ?? this.idProductoGeneral,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      descripcion: descripcion ?? this.descripcion,
      precioProducto: precioProducto ?? this.precioProducto,
      cantidadProducto: cantidadProducto ?? this.cantidadProducto,
      estado: estado ?? this.estado,
      idCategoriaProducto: idCategoriaProducto ?? this.idCategoriaProducto,
      idImagen: idImagen ?? this.idImagen,
      idReceta: idReceta ?? this.idReceta,
      urlImg: urlImg ?? this.urlImg,
      nombreCategoria: nombreCategoria ?? this.nombreCategoria,
      nombreReceta: nombreReceta ?? this.nombreReceta,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $idProductoGeneral, nombre: $nombreProducto, precio: $precioProducto, categoria: $idCategoriaProducto, urlImg: $urlImg)';
  }

  bool get tieneImagen => urlImg != null && urlImg!.isNotEmpty;
  String get precioFormateado => '\$${precioProducto.toStringAsFixed(0)}';
  bool get estaDisponible => estado && cantidadProducto > 0;
}
