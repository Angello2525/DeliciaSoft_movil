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
    return Pedido(
      idPedido: json['idPedido'],
      idVenta: json['idVenta'], // Leer idVenta del JSON
      observaciones: json['observaciones'] ?? '',
      fechaEntrega: DateTime.parse(json['fechaEntrega']),
      mensajePersonalizado: json['mensajePersonalizado'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss'); // Formato ISO 8601
    return {
      'idPedido': idPedido,
      'idVenta': idVenta, // Incluir idVenta
      'observaciones': observaciones,
      'fechaEntrega': formatter.format(fechaEntrega),
      'mensajePersonalizado': mensajePersonalizado,
    };
  }

  Map<String, dynamic> toCreateJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
    return {
      'idVenta': idVenta, // Incluir idVenta para creación
      'observaciones': observaciones,
      'fechaEntrega': formatter.format(fechaEntrega),
      'mensajePersonalizado': mensajePersonalizado,
    };
  }
}