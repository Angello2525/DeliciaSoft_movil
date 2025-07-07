import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/relleno_models.dart';

class RellenoService {
  static const String baseUrl = 'http://deliciasoft.somee.com';
  static const Duration timeoutDuration = Duration(seconds: 10);
  
  // Obtener todos los rellenos
  static Future<List<RellenoModel>> getAllRellenos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/CatalogoRellenos'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => RellenoModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar rellenos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener rellenos activos solamente
  static Future<List<RellenoModel>> getRellenosActivos() async {
    try {
      List<RellenoModel> allRellenos = await getAllRellenos();
      return allRellenos.where((relleno) => relleno.estado == true).toList();
    } catch (e) {
      throw Exception('Error al obtener rellenos activos: $e');
    }
  }

  // Obtener relleno por ID
  static Future<RellenoModel?> getRellenoById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/CatalogoRellenos/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        return RellenoModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al cargar relleno: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear un nuevo relleno
  static Future<RellenoModel> createRelleno(RellenoModel relleno) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/CatalogoRellenos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(relleno.toJson()),
      ).timeout(timeoutDuration);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        return RellenoModel.fromJson(jsonData);
      } else {
        throw Exception('Error al crear relleno: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar un relleno existente
  static Future<RellenoModel> updateRelleno(int id, RellenoModel relleno) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/CatalogoRellenos/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(relleno.toJson()),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        return RellenoModel.fromJson(jsonData);
      } else {
        throw Exception('Error al actualizar relleno: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar un relleno
  static Future<bool> deleteRelleno(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/CatalogoRellenos/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}