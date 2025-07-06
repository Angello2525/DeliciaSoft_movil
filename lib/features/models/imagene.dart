class Imagene {
  final int? id;
  final String url;
  final String? publicId;
  final String? nombre;
  final DateTime? fechaCreacion;
  
  Imagene({
    this.id,
    required this.url,
    this.publicId,
    this.nombre,
    this.fechaCreacion,
  });
  
  factory Imagene.fromJson(Map<String, dynamic> json) {
    return Imagene(
      id: json['id'],
      url: json['url'] ?? json['Url'] ?? '',
      publicId: json['publicId'] ?? json['PublicId'],
      nombre: json['nombre'] ?? json['Nombre'],
      fechaCreacion: json['fechaCreacion'] != null 
        ? DateTime.parse(json['fechaCreacion'])
        : json['FechaCreacion'] != null 
          ? DateTime.parse(json['FechaCreacion'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'publicId': publicId,
      'nombre': nombre,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
    };
  }
}