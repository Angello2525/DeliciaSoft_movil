// venta.dart - CORREGIDO
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
    DateTime parsedDate;
    if (json['fechaVenta'] is String) {
      final dateString = json['fechaVenta'] as String;
      // Manejar diferentes formatos de fecha
      if (dateString.contains('T')) {
        parsedDate = DateTime.parse(dateString);
      } else {
        // Si solo viene la fecha sin tiempo, agregar tiempo por defecto
        parsedDate = DateTime.parse('${dateString}T00:00:00');
      }
    } else if (json['fechaVenta'] is DateTime) {
      parsedDate = json['fechaVenta'];
    } else {
      parsedDate = DateTime.now();
    }

    return Venta(
      idVenta: json['idVenta'] ?? 0,
      fechaVenta: parsedDate,
      idCliente: json['idCliente'] ?? 0,
      idSede: json['idSede'] ?? 0,
      metodoPago: json['metodoPago'] ?? '',
      tipoVenta: json['tipoVenta'] ?? '',
      estadoVenta: json['estadoVenta'] ?? false,
    );
  }

  // Método para crear JSON sin idVenta (para crear nuevas ventas)
  Map<String, dynamic> toCreateJson() {
    return {
      'fechaVenta': fechaVenta.toIso8601String().split('T')[0], // Solo fecha YYYY-MM-DD
      'idCliente': idCliente,
      'idSede': idSede,
      'metodoPago': metodoPago,
      'tipoVenta': tipoVenta,
      'estadoVenta': estadoVenta,
    };
  }

  // Método para crear JSON completo
  Map<String, dynamic> toJson() {
    return {
      'idVenta': idVenta,
      'fechaVenta': fechaVenta.toIso8601String().split('T')[0], // Solo fecha YYYY-MM-DD
      'idCliente': idCliente,
      'idSede': idSede,
      'metodoPago': metodoPago,
      'tipoVenta': tipoVenta,
      'estadoVenta': estadoVenta,
    };
  }
}