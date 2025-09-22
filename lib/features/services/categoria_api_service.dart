import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';

class CategoriaApiService {
  // URL completa del endpoint de categorías
  static const String _baseUrl =
      'https://deliciasoft-backend.onrender.com/api/categorias-productos';

  Future<List<Category>> obtenerCategorias() async {
    final uri = Uri.parse(_baseUrl); // usamos _baseUrl
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body is List) {
        return body.map((item) => Category.fromJson(item)).toList();
      }

      if (body is Map && body.containsKey('data')) {
        final List<dynamic> data = body['data'];
        return data.map((item) => Category.fromJson(item)).toList();
      }

      throw Exception('Formato de respuesta inesperado');
    } else {
      throw Exception(
          'No se pudo cargar las categorías. Código: ${response.statusCode}');
    }
  }
}
