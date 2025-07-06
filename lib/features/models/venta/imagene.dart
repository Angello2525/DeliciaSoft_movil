// lib/models/venta/imagene.dart
class Imagene {
  int? idImagen; // Asegúrate de que sea int?
  String? urlImg; // Asegúrate de que sea String?

  Imagene({
    this.idImagen,
    this.urlImg,
  });

  factory Imagene.fromJson(Map<String, dynamic> json) {
    return Imagene(
      idImagen: json['idImagen'], // Mapea a int
      urlImg: json['urlImg'], // Mapea a String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idImagen': idImagen,
      'urlImg': urlImg,
    };
  }
}