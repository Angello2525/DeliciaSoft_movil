// lib/models/detalle_adicione.dart
class DetalleAdicione {
  final int idAdicion;
  final int? idDetalleVenta;
  final int? idAdiciones;
  final int? idSabor;
  final int? idRelleno;
  final double? cantidadAdicionada;
  final double? precioUnitario;
  final double? subtotal;

  DetalleAdicione({
    required this.idAdicion,
    this.idDetalleVenta,
    this.idAdiciones,
    this.idSabor,
    this.idRelleno,
    this.cantidadAdicionada,
    this.precioUnitario,
    this.subtotal,
  });
  
  factory DetalleAdicione.fromJson(Map<String, dynamic> json) {
    return DetalleAdicione(
      idAdicion: json['idAdicion'],
      idDetalleVenta: json['idDetalleVenta'],
      idAdiciones: json['idAdiciones'],
      idSabor: json['idSabor'],
      idRelleno: json['idRelleno'],
      cantidadAdicionada: (json['cantidadAdicionada'] as num?)?.toDouble(),
      precioUnitario: (json['precioUnitario'] as num?)?.toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
    );
  }
}