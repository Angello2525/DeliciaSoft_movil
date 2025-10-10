import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/General_models.dart';

class ProductoApiService {
  static const String baseUrl = 'https://deliciasoft-backend.onrender.com/api';

  /// Obtener productos por categoría usando ID
  Future<List<ProductModel>> obtenerProductosPorCategoriaId(int idCategoria) async {
    try {
      final url = '$baseUrl/productoGeneral';
      print('=== INICIANDO PETICIÓN ===');
      print('URL: $url');
      print('Buscando categoría ID: $idCategoria');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        print('Total productos en API: ${jsonData.length}');

        // Filtrar productos por categoría
        List<dynamic> productosFiltrados = jsonData.where((producto) {
          int? categoriaId = int.tryParse(producto['idcategoriaproducto']?.toString() ?? '0');
          
          if (categoriaId == idCategoria) {
            print('✓ Encontrado: ${producto['nombreproducto']} (ID: $categoriaId)');
            return true;
          }
          return false;
        }).toList();

        print('=== RESUMEN ===');
        print('Productos filtrados: ${productosFiltrados.length}');

        // Convertir a ProductModel
        List<ProductModel> productos = productosFiltrados.map((json) {
          return ProductModel.fromJson(json);
        }).toList();

        // Mostrar productos finales
        print('=== PRODUCTOS FINALES ===');
        for (var p in productos) {
          print('${p.nombreProducto} - \$${p.precioProducto} - IMG: ${p.urlImg?.isNotEmpty == true ? "SÍ" : "NO"}');
        }
        print('=====================');

        return productos;
      } else {
        print('Error HTTP: ${response.statusCode}');
        throw HttpException('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
      rethrow;
    }
  }

  /// Obtener la URL de una imagen por ID
  Future<String?> obtenerUrlImagen(int idImagen) async {
    try {
      if (idImagen == 0) return null;
      final url = '$baseUrl/Imagenes/$idImagen';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> imagenData = json.decode(response.body);
        return imagenData['urlimg'] ?? imagenData['urlImg'];
      }
      return null;
    } catch (e) {
      print('Error al obtener imagen $idImagen: $e');
      return null;
    }
  }
}