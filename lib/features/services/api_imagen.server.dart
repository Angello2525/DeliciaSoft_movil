import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class ApiService {
  
  // Método genérico GET
  static Future<dynamic> getData(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.get(uri, headers: ApiConstants.jsonHeaders);
      
      print('📍 GET: ${uri.toString()}');
      print('📥 Respuesta: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Método genérico POST
  static Future<dynamic> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.post(
        uri,
        headers: ApiConstants.jsonHeaders,
        body: json.encode(data),
      );
      
      print('📍 POST: ${uri.toString()}');
      print('📤 Datos: ${json.encode(data)}');
      print('📥 Respuesta: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al enviar datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Método genérico PUT
  static Future<dynamic> putData(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.put(
        uri,
        headers: ApiConstants.jsonHeaders,
        body: json.encode(data),
      );
      
      print('📍 PUT: ${uri.toString()}');
      print('📤 Datos: ${json.encode(data)}');
      print('📥 Respuesta: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isNotEmpty ? json.decode(response.body) : null;
      } else {
        throw Exception('Error al actualizar datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Método genérico DELETE
  static Future<bool> deleteData(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.delete(uri, headers: ApiConstants.jsonHeaders);
      
      print('📍 DELETE: ${uri.toString()}');
      print('📥 Respuesta: ${response.statusCode}');
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}