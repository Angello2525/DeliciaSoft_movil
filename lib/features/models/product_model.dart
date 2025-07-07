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

 // En tu clase ProductModel, cambia el método fromBackendJson:
factory ProductModel.fromBackendJson(dynamic generalModel) {
  return ProductModel(
    title: generalModel.nombreProducto ?? 'Sin título',
    description: generalModel.descripcion ?? 'Producto sin descripción',
    imageUrl: generalModel.urlImg ?? '',
    price: (generalModel.precioProducto ?? 0).toDouble(),
  );
}
}
