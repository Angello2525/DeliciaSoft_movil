import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/General_models.dart';

class ProductoApiService {
  static const String baseUrl = 'https://deliciasoft-backend.onrender.com/api';
  
  // Obtener productos por categoría
  Future<List<ProductModel>> obtenerProductosPorCategoria(String categoria) async {
    try {
      final url = '$baseUrl/categorias-productos';
      print('Llamando a: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Status code: ${response.statusCode}');
      print('Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        print('Total productos recibidos: ${jsonData.length}');
        
        // Agregar debugging detallado
        print('=== DEBUGGING DETALLADO ===');
        print('Total productos recibidos: ${jsonData.length}');
        
        if (jsonData.isNotEmpty) {
          print('Ejemplo de producto (primero):');
          print(jsonData[0]);
          
          // Verificar todas las categorías
          Set<int> categorias = {};
          for (var producto in jsonData) {
            int categoria = producto['idCategoriaProducto'];
            categorias.add(categoria);
            print('Producto: ${producto['nombreProducto']} - Categoría: $categoria');
          }
          print('Todas las categorías: $categorias');
        }
        
        // Filtrar productos de categoría 3 (fresas con crema)
        List<dynamic> productosCategoria3 = jsonData
            .where((producto) => producto['idCategoriaProducto'] == 5 )
            .toList();

        print('Productos de categoría 3 (cupcakes): ${productosCategoria3.length}');
        print('=== FIN DEBUGGING ===');

        // Obtener imágenes para cada producto
        List<ProductModel> productosConImagenes = [];
        
        for (var productoJson in productosCategoria3) {
          try {
            print('Procesando producto: ${productoJson['nombreProducto']}');
            
            // Obtener la imagen usando el idImagen
            String? urlImagen;
            if (productoJson['idImagen'] != null) {
              urlImagen = await obtenerUrlImagen(productoJson['idImagen']);
            }
            
            // Crear el producto usando fromJson y copyWith para la URL
            ProductModel producto = ProductModel.fromJson(productoJson).copyWith(
              urlImg: urlImagen,
              nombreCategoria: 'Cupcakes',
            );
            
            productosConImagenes.add(producto);
            print('Producto agregado: ${producto.nombreProducto}');
          } catch (e) {
            print('Error al procesar producto ${productoJson['nombreProducto']}: $e');
            // Agregar el producto sin imagen si hay error usando fromJson
            ProductModel producto = ProductModel.fromJson(productoJson).copyWith(
              urlImg: null,
              nombreCategoria: 'Cupcakes',
            );
            productosConImagenes.add(producto);
          }
        }

        print('Total productos con imágenes: ${productosConImagenes.length}');
        return productosConImagenes;
      } else {
        print('Error HTTP: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw HttpException('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: ${e.toString()}');
      throw HttpException('Error de conexión: ${e.toString()}');
    }
  }

  // Método para obtener la URL de imagen usando el idImagen
 Future<String?> obtenerUrlImagen(int idImagen) async {
  try {
    final url = '$baseUrl/Imagenes/$idImagen';
    print('Obteniendo imagen: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> imagenData = json.decode(response.body);

      // Aquí solo usamos directamente el campo 'urlImg'
      String? urlImagen = imagenData['urlImg'];

      print('URL imagen obtenida: $urlImagen');
      return urlImagen;
    } else {
      print('Error al obtener imagen $idImagen: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error al obtener imagen $idImagen: $e');
    return null;
  }
}


  // Método alternativo si necesitas obtener todas las imágenes de una vez
  Future<Map<int, String>> obtenerTodasLasImagenes() async {
    try {
      final url = '$baseUrl/Imagenes';
      print('Obteniendo todas las imágenes: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> imagenesData = json.decode(response.body);
        Map<int, String> mapaImagenes = {};
        
        for (var imagen in imagenesData) {
          int id = imagen['idImagen'] ?? imagen['id'];
          String url = imagen['url'] ?? imagen['urlImagen'] ?? imagen['rutaImagen'] ?? imagen['imagen'] ?? '';
          if (url.isNotEmpty) {
            mapaImagenes[id] = url;
          }
        }
        
        print('Total imágenes obtenidas: ${mapaImagenes.length}');
        return mapaImagenes;
      } else {
        print('Error al obtener imágenes: ${response.statusCode}');
        throw HttpException('Error al obtener imágenes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión al obtener imágenes: ${e.toString()}');
      throw HttpException('Error de conexión al obtener imágenes: ${e.toString()}');
    }
  }

  // Método optimizado que obtiene productos e imágenes en paralelo
  Future<List<ProductModel>> obtenerProductosConImagenesOptimizado() async {
    try {
      print('Iniciando obtención optimizada de productos e imágenes...');
      
      // Ejecutar ambas llamadas en paralelo
      final futures = await Future.wait([
        http.get(Uri.parse('$baseUrl/ProductoGenerals')),
        http.get(Uri.parse('$baseUrl/Imagenes')),
      ]);

      final productosResponse = futures[0];
      final imagenesResponse = futures[1];

      print('Respuesta productos: ${productosResponse.statusCode}');
      print('Respuesta imágenes: ${imagenesResponse.statusCode}');

      if (productosResponse.statusCode == 200 && imagenesResponse.statusCode == 200) {
        // Procesar productos
        List<dynamic> productosData = json.decode(productosResponse.body);
        print('Total productos recibidos: ${productosData.length}');
        
        List<dynamic> productosCategoria3 = productosData
    .where((producto) => int.tryParse(producto['idCategoriaProducto'].toString()) == 5)
    .toList();

        
        print('Productos de categoría 6 (mini donas): ${productosCategoria3.length}');

        // Procesar imágenes
        List<dynamic> imagenesData = json.decode(imagenesResponse.body);
        Map<int, String> mapaImagenes = {};
        
        for (var imagen in imagenesData) {
          int id = imagen['idImagen'] ?? imagen['id'];
          String url = imagen['url'] ?? imagen['urlImagen'] ?? imagen['rutaImagen'] ?? imagen['imagen'] ?? '';
          if (url.isNotEmpty) {
            mapaImagenes[id] = url;
          }
        }

        print('Total imágenes procesadas: ${mapaImagenes.length}');

        // Combinar productos con imágenes usando fromJson y copyWith
        List<ProductModel> productos = productosCategoria3.map((productoJson) {
          String? urlImagen = mapaImagenes[productoJson['idImagen']];
          
          return ProductModel.fromJson(productoJson).copyWith(
            urlImg: urlImagen,
            nombreCategoria: 'cupcakes',
          );
        }).toList();

        print('Productos finales con imágenes: ${productos.length}');
        return productos;
      } else {
        print('Error en una o ambas respuestas de la API');
        throw HttpException('Error al obtener datos de la API');
      }
    } catch (e) {
      print('Error de conexión optimizado: ${e.toString()}');
      throw HttpException('Error de conexión: ${e.toString()}');
    }
  }
}