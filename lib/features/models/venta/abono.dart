// lib/models/venta/abono.dart
class Abono {
  final int? idAbono;
  final int? idPedido;
  final String? metodoPago;
  final int? idImagen;
  final double? cantidadPagar;
  final double? TotalPagado; // ✅ AGREGADO
  final String? urlImagen;

  Abono({
    this.idAbono,
    this.idPedido,
    this.metodoPago,
    this.idImagen,
    this.cantidadPagar,
    this.TotalPagado, // ✅ AGREGADO
    this.urlImagen,
  });

  /// Constructor desde JSON - Maneja múltiples formatos del backend
  factory Abono.fromJson(Map<String, dynamic> json) {
    return Abono(
      idAbono: json['idAbono'] ?? json['id'] ?? json['idabono'],
      idPedido: json['idPedido'] ?? json['idpedido'],
      metodoPago: json['metodoPago'] ?? json['metodopago'] ?? json['metodo_pago'],
      idImagen: json['idImagen'] ?? json['idimagen'],
      cantidadPagar: _parseDouble(
        json['cantidadPagar'] ?? 
        json['cantidadpagar'] ?? 
        json['monto'] ??
        json['totalPagado'] ??
        json['TotalPagado']
      ),
      TotalPagado: _parseDouble(
        json['TotalPagado'] ?? 
        json['totalPagado'] ?? 
        json['cantidadpagar'] ??
        json['cantidadPagar']
      ),
      urlImagen: json['urlImagen'] ?? 
                 json['comprobante_imagen'] ?? 
                 json['urlimg'] ??
                 (json['imagenes'] != null ? json['imagenes']['urlimg'] : null),
    );
  }

  /// Helper para parsear doubles de forma segura
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Para actualizar un abono existente
  Map<String, dynamic> toJson() {
    return {
      if (idAbono != null) 'idAbono': idAbono,
      if (idPedido != null) 'idPedido': idPedido,
      if (metodoPago != null) 'metodoPago': metodoPago,
      if (idImagen != null) 'idImagen': idImagen,
      if (cantidadPagar != null) 'cantidadPagar': cantidadPagar,
      if (TotalPagado != null) 'TotalPagado': TotalPagado,
    };
  }

  /// Para crear un nuevo abono (omite idAbono)
  Map<String, dynamic> toCreateJson() {
    return {
      'idPedido': idPedido,
      'metodoPago': metodoPago,
      if (idImagen != null) 'idImagen': idImagen,
      'cantidadPagar': cantidadPagar,
      'TotalPagado': TotalPagado ?? cantidadPagar,
    };
  }

  /// Validar antes de enviar
  bool validate() {
    if (idPedido == null || idPedido! <= 0) {
      print('❌ Validación falló: idPedido inválido');
      return false;
    }
    if (metodoPago == null || metodoPago!.isEmpty) {
      print('❌ Validación falló: metodoPago vacío');
      return false;
    }
    if (metodoPago!.length > 20) {
      print('❌ Validación falló: metodoPago muy largo (${metodoPago!.length} caracteres)');
      return false;
    }
    if (cantidadPagar == null || cantidadPagar! <= 0) {
      print('❌ Validación falló: cantidadPagar inválida');
      return false;
    }
    return true;
  }

  /// Copiar con nuevos valores
  Abono copyWith({
    int? idAbono,
    int? idPedido,
    String? metodoPago,
    int? idImagen,
    double? cantidadPagar,
    double? TotalPagado,
    String? urlImagen,
  }) {
    return Abono(
      idAbono: idAbono ?? this.idAbono,
      idPedido: idPedido ?? this.idPedido,
      metodoPago: metodoPago ?? this.metodoPago,
      idImagen: idImagen ?? this.idImagen,
      cantidadPagar: cantidadPagar ?? this.cantidadPagar,
      TotalPagado: TotalPagado ?? this.TotalPagado,
      urlImagen: urlImagen ?? this.urlImagen,
    );
  }

  @override
  String toString() {
    return 'Abono{idAbono: $idAbono, idPedido: $idPedido, metodoPago: $metodoPago, '
           'cantidadPagar: $cantidadPagar, TotalPagado: $TotalPagado, '
           'idImagen: $idImagen, urlImagen: $urlImagen}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Abono &&
        other.idAbono == idAbono &&
        other.idPedido == idPedido &&
        other.metodoPago == metodoPago &&
        other.idImagen == idImagen &&
        other.cantidadPagar == cantidadPagar &&
        other.TotalPagado == TotalPagado &&
        other.urlImagen == urlImagen;
  }

  @override
  int get hashCode {
    return idAbono.hashCode ^
        idPedido.hashCode ^
        metodoPago.hashCode ^
        idImagen.hashCode ^
        cantidadPagar.hashCode ^
        TotalPagado.hashCode ^
        urlImagen.hashCode;
  }
}