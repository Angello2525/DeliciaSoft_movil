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
    // El objeto 'imagenes' puede venir null
    final imagenObj = json['imagenes'];

    return Category(
      // OJO: aquí usamos 'nombrecategoria' porque así viene en el JSON real
      nombreCategoria: json['nombrecategoria'] ?? 'Sin nombre',

      // El id de la imagen puede venir en 'idimagencat' o dentro del objeto 'imagenes'
      idImagen: json['idimagencat'] ?? (imagenObj != null ? imagenObj['idimagen'] : null),

      // El url de la imagen viene dentro de 'imagenes' como 'urlimg'
      urlImg: (imagenObj != null && imagenObj['urlimg'] != null)
          ? imagenObj['urlimg'] as String
          : null,
    );
  }
}
