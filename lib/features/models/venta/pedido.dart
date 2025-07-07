import 'package:intl/intl.dart';

class Pedido {
  final int idPedido;
  final int? idVenta;  
  final String observaciones;
  final DateTime fechaEntrega;
  final String mensajePersonalizado;

  Pedido({
    required this.idPedido,
    this.idVenta, 
    required this.observaciones,
    required this.fechaEntrega,
    required this.mensajePersonalizado,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['fechaEntrega'] is String) {
      final dateString = json['fechaEntrega'] as String;
      // Manejar diferentes formatos de fecha
      if (dateString.contains('T')) {
        parsedDate = DateTime.parse(dateString);
      } else {
        // Si solo viene la fecha sin tiempo, agregar tiempo por defecto
        parsedDate = DateTime.parse('${dateString}T00:00:00');
      }
    } else if (json['fechaEntrega'] is DateTime) {
      parsedDate = json['fechaEntrega'];
    } else {
      parsedDate = DateTime.now().add(const Duration(days: 1));
    }

    return Pedido(
      idPedido: json['idPedido'] ?? 0,
      idVenta: json['idVenta'],
      observaciones: json['observaciones'] ?? '',
      fechaEntrega: parsedDate,
      mensajePersonalizado: json['mensajePersonalizado'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPedido': idPedido,
      'idVenta': idVenta,
      'observaciones': observaciones,
      'fechaEntrega': fechaEntrega.toIso8601String().split('T')[0], // Solo fecha YYYY-MM-DD
      'mensajePersonalizado': mensajePersonalizado,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'idVenta': idVenta,
      'observaciones': observaciones,
      'fechaEntrega': fechaEntrega.toIso8601String().split('T')[0], // Solo fecha YYYY-MM-DD
      'mensajePersonalizado': mensajePersonalizado,
    };
  }
}