import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';

class CategoriaApiService {
  final String baseUrl = 'http://deliciasoft.somee.com/api';

  Future<List<Category>> obtenerCategorias() async {
    final response = await http.get(Uri.parse('$baseUrl/CategoriaProductoes'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('No se pudo cargar las categorías');
    }
  }
}