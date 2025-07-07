class DetalleVenta {
  final int idDetalleVenta;
  final int? idVenta;
  final int? idProductoGeneral;
  final int? cantidad;
  final double? precioUnitario;
  final double? subtotal;
  final double? iva;
  final double? total;

  DetalleVenta({
    required this.idDetalleVenta,
    this.idVenta,
    this.idProductoGeneral,
    this.cantidad,
    this.precioUnitario,
    this.subtotal,
    this.iva,
    this.total,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      idDetalleVenta: json['idDetalleVenta'] ?? 0,
      idVenta: json['idVenta'],
      idProductoGeneral: json['idProductoGeneral'],
      cantidad: json['cantidad'],
      precioUnitario: (json['precioUnitario'] as num?)?.toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      iva: (json['iva'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
    );
  }

  // Método para crear JSON sin idDetalleVenta (para crear nuevos detalles)
  Map<String, dynamic> toCreateJson() {
    return {
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
