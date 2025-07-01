import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductoApiService {
  final String baseUrl = 'http://deliciasoft.somee.com/api';

  // Obtener todos los productos
  Future<List<dynamic>> obtenerProductos() async {
    final response = await http.get(Uri.parse('$baseUrl/Producto'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('No se pudo cargar la lista de productos');
    }
  }

  // Obtener la URL de una imagen usando su ID
  Future<String> obtenerUrlImagen(int idImagen) async {
    final response = await http.get(Uri.parse('$baseUrl/Imagen/$idImagen'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['urlImg'];
    } else {
      throw Exception('No se pudo cargar la imagen con ID $idImagen');
    }
  }
}