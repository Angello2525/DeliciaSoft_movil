import '../models/General_models.dart';

class CartItem {
  final String id;
  final ProductModel producto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final List<ObleaConfiguration> configuraciones;
  final DateTime fechaAgregado;
  final Map<String, dynamic> detallesPersonalizacion;

  CartItem({
    required this.id,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.configuraciones,
    required this.fechaAgregado,
    required this.detallesPersonalizacion,
  });

  CartItem copyWith({
    String? id,
    ProductModel? producto,
    int? cantidad,
    double? precioUnitario,
    double? subtotal,
    List<ObleaConfiguration>? configuraciones,
    DateTime? fechaAgregado,
    Map<String, dynamic>? detallesPersonalizacion,
  }) {
    return CartItem(
      id: id ?? this.id,
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      configuraciones: configuraciones ?? this.configuraciones,
      fechaAgregado: fechaAgregado ?? this.fechaAgregado,
      detallesPersonalizacion: detallesPersonalizacion ?? this.detallesPersonalizacion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto': producto.toJson(),
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
      'configuraciones': configuraciones.map((config) => config.toJson()).toList(),
      'fechaAgregado': fechaAgregado.toIso8601String(),
      'detallesPersonalizacion': detallesPersonalizacion,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      producto: ProductModel.fromJson(json['producto']),
      cantidad: json['cantidad'],
      precioUnitario: json['precioUnitario'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
      configuraciones: (json['configuraciones'] as List)
          .map((config) => ObleaConfiguration.fromJson(config))
          .toList(),
      fechaAgregado: DateTime.parse(json['fechaAgregado']),
      detallesPersonalizacion: Map<String, dynamic>.from(json['detallesPersonalizacion']),
    );
  }
}

class ObleaConfiguration {
  String tipoOblea;
  Map<String, String> ingredientesPersonalizados;
  double precio;
  
  ObleaConfiguration({
    this.tipoOblea = '',
    Map<String, String>? ingredientesPersonalizados,
    this.precio = 0.0,
  }) : ingredientesPersonalizados = ingredientesPersonalizados ?? {};

  Map<String, dynamic> toJson() {
    return {
      'tipoOblea': tipoOblea,
      'ingredientesPersonalizados': ingredientesPersonalizados,
      'precio': precio,
    };
  }

  factory ObleaConfiguration.fromJson(Map<String, dynamic> json) {
    return ObleaConfiguration(
      tipoOblea: json['tipoOblea'] ?? '',
      ingredientesPersonalizados: Map<String, String>.from(json['ingredientesPersonalizados'] ?? {}),
      precio: (json['precio'] ?? 0.0).toDouble(),
    );
  }

  ObleaConfiguration copyWith({
    String? tipoOblea,
    Map<String, String>? ingredientesPersonalizados,
    double? precio,
  }) {
    return ObleaConfiguration(
      tipoOblea: tipoOblea ?? this.tipoOblea,
      ingredientesPersonalizados: ingredientesPersonalizados ?? this.ingredientesPersonalizados,
      precio: precio ?? this.precio,
    );
  }
}

class Cart {
  final List<CartItem> items;
  final double subtotal;
  final double iva;
  final double total;
  final int cantidadTotal;

  Cart({
    required this.items,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.cantidadTotal,
  });

  Cart copyWith({
    List<CartItem>? items,
    double? subtotal,
    double? iva,
    double? total,
    int? cantidadTotal,
  }) {
    return Cart(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      iva: iva ?? this.iva,
      total: total ?? this.total,
      cantidadTotal: cantidadTotal ?? this.cantidadTotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'iva': iva,
      'total': total,
      'cantidadTotal': cantidadTotal,
    };
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      iva: json['iva'].toDouble(),
      total: json['total'].toDouble(),
      cantidadTotal: json['cantidadTotal'],
    );
  }
}

// Modelos para la API
class VentaRequest {
  final int idVenta;
  final String fechaVenta;
  final int idCliente;
  final int idSede;
  final String metodoPago;
  final String tipoVenta;
  final bool estadoVenta;

  VentaRequest({
    this.idVenta = 0,
    required this.fechaVenta,
    required this.idCliente,
    required this.idSede,
    required this.metodoPago,
    required this.tipoVenta,
    this.estadoVenta = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'idVenta': idVenta,
      'fechaVenta': fechaVenta,
      'idCliente': idCliente,
      'idSede': idSede,
      'metodoPago': metodoPago,
      'tipoVenta': tipoVenta,
      'estadoVenta': estadoVenta,
    };
  }
}

class DetalleVentaRequest {
  final int idDetalleVenta;
  final int idVenta;
  final int idProductoGeneral;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final double iva;
  final double total;

  DetalleVentaRequest({
    this.idDetalleVenta = 0,
    required this.idVenta,
    required this.idProductoGeneral,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.iva,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'idDetalleVenta': idDetalleVenta,
      'idVenta': idVenta,
      'idProductoGeneral': idProductoGeneral,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
      'iva': iva,
      'total': total,
    };
  }
}

class PedidoRequest {
  final int idPedido;
  final int idVenta;
  final String observaciones;
  final String fechaEntrega;
  final String mensajePersonalizado;

  PedidoRequest({
    this.idPedido = 0,
    required this.idVenta,
    required this.observaciones,
    required this.fechaEntrega,
    required this.mensajePersonalizado,
  });

  Map<String, dynamic> toJson() {
    return {
      'idPedido': idPedido,
      'idVenta': idVenta,
      'observaciones': observaciones,
      'fechaEntrega': fechaEntrega,
      'mensajePersonalizado': mensajePersonalizado,
    };
  }
}

class DetalleAdicionRequest {
  final int idAdicion;
  final int idDetalleVenta;
  final int idAdiciones;
  final int idSabor;
  final int idRelleno;
  final int cantidadAdicionada;
  final double precioUnitario;
  final double subtotal;

  DetalleAdicionRequest({
    this.idAdicion = 0,
    required this.idDetalleVenta,
    required this.idAdiciones,
    required this.idSabor,
    required this.idRelleno,
    required this.cantidadAdicionada,
    required this.precioUnitario,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() {
    return {
      'idAdicion': idAdicion,
      'idDetalleVenta': idDetalleVenta,
      'idAdiciones': idAdiciones,
      'idSabor': idSabor,
      'idRelleno': idRelleno,
      'cantidadAdicionada': cantidadAdicionada,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}