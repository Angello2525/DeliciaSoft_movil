import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductoApiService {
  final String baseUrl = 'http://deliciasoft.somee.com/api';

  Future<List<dynamic>> obtenerProductos() async {
    final url = Uri.parse('$baseUrl/Producto');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // ← Esto es una lista de productos
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode}');
    }
  }
}