class Venta {
  final int idVenta;
  final DateTime fechaVenta;
  final int idCliente;
  final int idSede;
  final String metodoPago;
  final String tipoVenta;
  final bool estadoVenta;

  Venta({
    required this.idVenta,
    required this.fechaVenta,
    required this.idCliente,
    required this.idSede,
    required this.metodoPago,
    required this.tipoVenta,
    required this.estadoVenta,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    // Handle both string and DateTime for fechaVenta
    DateTime parsedDate;
    if (json['fechaVenta'] is String) {
      // API might return "YYYY-MM-DD" for DateOnly, parse it carefully
      parsedDate = DateTime.parse(json['fechaVenta']);
    } else if (json['fechaVenta'] is DateTime) {
      parsedDate = json['fechaVenta'];
    } else {
      parsedDate = DateTime.now(); // Fallback
    }

    return Venta(
      idVenta: json['idVenta'],
      fechaVenta: parsedDate,
      idCliente: json['idCliente'],
      idSede: json['idSede'],
      metodoPago: json['metodoPago'],
      tipoVenta: json['tipoVenta'],
      estadoVenta: json['estadoVenta'],
    );
  }
}
