import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saborModels.dart';

class SaborService {
  static const String baseUrl = 'http://deliciasoft.somee.com/api';
  
  // Obtener todos los sabores
  static Future<List<SaborModel>> getAllSabores() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/CatalogoSabors'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => SaborModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener sabores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener sabores activos solamente
  static Future<List<SaborModel>> getSaboresActivos() async {
    try {
      List<SaborModel> allSabores = await getAllSabores();
      return allSabores.where((sabor) => sabor.estado).toList();
    } catch (e) {
      throw Exception('Error al obtener sabores activos: $e');
    }
  }

  // Obtener sabor por ID
  static Future<SaborModel?> getSaborById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/CatalogoSabors/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        return SaborModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener sabor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear nuevo sabor
  static Future<SaborModel> createSabor(SaborModel sabor) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/CatalogoSabors'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(sabor.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        return SaborModel.fromJson(jsonData);
      } else {
        throw Exception('Error al crear sabor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar sabor
  static Future<SaborModel> updateSabor(int id, SaborModel sabor) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/CatalogoSabors/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(sabor.toJson()),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        return SaborModel.fromJson(jsonData);
      } else {
        throw Exception('Error al actualizar sabor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar sabor
  static Future<bool> deleteSabor(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/CatalogoSabors/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}