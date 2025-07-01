class ProductModel {
  final String title;
  final String description;
  final String imageUrl;
  final double price;

  ProductModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  factory ProductModel.fromBackendJson(Map<String, dynamic> json, String imageUrl) {
  return ProductModel(
    title: json['nombreProducto'] ?? 'Sin título',
    description: 'Producto sin descripción', // si no viene desde el backend
    imageUrl: imageUrl,
    price: (json['precioProducto'] ?? 0).toDouble(),
  );
}
}
