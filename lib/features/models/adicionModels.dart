class AdicionModel {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio; // Cambiado a double para manejar decimales
  final String tipo;
  final bool estado;
  final int? categoriaId;
  final String? urlImagen;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;

  AdicionModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.tipo,
    required this.estado,
    this.categoriaId,
    this.urlImagen,
    this.fechaCreacion,
    this.fechaModificacion,
  });

  factory AdicionModel.fromJson(Map<String, dynamic> json) {
    return AdicionModel(
      id: _parseToInt(json['id']),
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      precio: _parseToDouble(json['precio']), // Manejo seguro de double
      tipo: json['tipo']?.toString() ?? '',
      estado: _parseToBool(json['estado']),
      categoriaId: json['categoriaId'] != null ? _parseToInt(json['categoriaId']) : null,
      urlImagen: json['urlImagen']?.toString(),
      fechaCreacion: json['fechaCreacion'] != null 
        ? DateTime.tryParse(json['fechaCreacion'].toString()) 
        : null,
      fechaModificacion: json['fechaModificacion'] != null 
        ? DateTime.tryParse(json['fechaModificacion'].toString()) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'tipo': tipo,
      'estado': estado,
      'categoriaId': categoriaId,
      'urlImagen': urlImagen,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaModificacion': fechaModificacion?.toIso8601String(),
    };
  }

  // Métodos helper para conversión segura de tipos
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

  static bool _parseToBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }

  @override
  String toString() {
    return 'AdicionModel(id: $id, nombre: $nombre, tipo: $tipo, precio: $precio, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdicionModel &&
        other.id == id &&
        other.nombre == nombre &&
        other.tipo == tipo;
  }

  @override
  int get hashCode => id.hashCode ^ nombre.hashCode ^ tipo.hashCode;
}