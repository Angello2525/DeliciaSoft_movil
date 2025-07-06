  import 'dart:convert';
  import 'dart:io';
  import 'package:http/http.dart' as http;
  import '../models/General_models.dart';

  class ProductoApiService {
    static const String baseUrl = 'http://deliciasoft.somee.com/api';

    // Mapa de nombres de categoría a su respectivo ID
    static const Map<String, int> categoriaIds = {
      'fresas con crema': 5,
      'obleas': 4,
      'tortas': 6,
      // Puedes agregar más categorías si necesitas
    };

    /// Obtener productos por nombre de categoría (dinámico)
    Future<List<ProductModel>> obtenerProductosPorCategoria(String categoria) async {
      try {
        final url = '$baseUrl/ProductoGenerals';
        final response = await http.get(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);

          final categoriaId = categoriaIds[categoria.toLowerCase()];
          if (categoriaId == null) {
            throw HttpException('Categoría no reconocida: $categoria');
          }

          final productosFiltrados = jsonData
              .where((producto) => producto['idCategoriaProducto'] == categoriaId)
              .toList();

          List<ProductModel> productosConImagenes = [];

          for (var productoJson in productosFiltrados) {
            try {
              String? urlImagen;
              if (productoJson['idImagen'] != null) {
                urlImagen = await obtenerUrlImagen(productoJson['idImagen']);
              }

              final producto = ProductModel.fromJson(productoJson).copyWith(
                urlImg: urlImagen,
                nombreCategoria: categoria,
              );

              productosConImagenes.add(producto);
            } catch (_) {
              final producto = ProductModel.fromJson(productoJson).copyWith(
                urlImg: null,
                nombreCategoria: categoria,
              );
              productosConImagenes.add(producto);
            }
          }

          return productosConImagenes;
        } else {
          throw HttpException('Error al obtener productos: ${response.statusCode}');
        }
      } catch (e) {
        throw HttpException('Error de conexión: ${e.toString()}');
      }
    }

    /// Obtener la URL de una imagen por su ID
    Future<String?> obtenerUrlImagen(int idImagen) async {
      try {
        final url = '$baseUrl/Imagenes/$idImagen';
        final response = await http.get(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final imagenData = json.decode(response.body);
          return imagenData['urlImg'];
        } else {
          print('Error al obtener imagen $idImagen: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        print('Error al obtener imagen $idImagen: $e');
        return null;
      }
    }
  }