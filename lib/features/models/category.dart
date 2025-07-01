class Category {
  final String nombreCategoria;
  final int? idImagen;
  final String? urlImg;

  Category({
    required this.nombreCategoria,
    this.idImagen,
    this.urlImg,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final imagenObj = json['imagen'];
    return Category(
      nombreCategoria: json['nombreCategoria'] ?? 'Sin nombre',
      idImagen: json['idImagen'], // puede ser null
      urlImg: imagenObj != null && imagenObj['urlImg'] != null
          ? imagenObj['urlImg'] as String
          : null,
    );
  }
}