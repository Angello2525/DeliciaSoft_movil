import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/adicionModels.dart';

class CatalogoAdicionesService {
  static const String baseUrl = 'http://deliciasoft.somee.com';
  static const String endpoint = '/api/CatalogoAdiciones';
  
  // Timeout para las peticiones
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<List<AdicionModel>> obtenerAdiciones() async {
    try {
      print('🔄 Iniciando petición a: $baseUrl$endpoint');
      
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        final String responseBody = response.body;
        print('📄 Response Body: ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}...');
        
        // Verificar si la respuesta está vacía
        if (responseBody.isEmpty) {
          print('⚠️ Respuesta vacía del servidor');
          return [];
        }
        
        // Decodificar JSON
        final dynamic decodedJson = json.decode(responseBody);
        
        // Verificar el tipo de respuesta
        if (decodedJson is List) {
          print('✅ Respuesta es una lista con ${decodedJson.length} elementos');
          
          final List<AdicionModel> adiciones = [];
          
          for (int i = 0; i < decodedJson.length; i++) {
            try {
              final item = decodedJson[i];
              print('🔍 Procesando item $i: ${item.toString()}');
              
              final adicion = AdicionModel.fromJson(item);
              adiciones.add(adicion);
              
              print('✅ Adición procesada: ${adicion.nombre} (${adicion.tipo})');
            } catch (e) {
              print('❌ Error procesando item $i: $e');
              print('🔍 Item problemático: ${decodedJson[i]}');
              // Continuar con el siguiente item en lugar de fallar completamente
              continue;
            }
          }
          
          print('📊 Total de adiciones procesadas: ${adiciones.length}');
          return adiciones;
          
        } else {
          print('❌ La respuesta no es una lista: ${decodedJson.runtimeType}');
          throw Exception('Formato de respuesta inesperado: se esperaba una lista');
        }
        
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        print('❌ Response Body: ${response.body}');
        throw Exception('Error del servidor: ${response.statusCode} - ${response.reasonPhrase}');
      }
      
    } catch (e) {
      print('❌ Error en obtenerAdiciones: $e');
      
      // Proporcionar mensajes de error más específicos
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Tiempo de espera agotado. Verifica tu conexión a internet.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('No se pudo conectar al servidor. Verifica tu conexión a internet.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Error en el formato de datos del servidor.');
      } else {
        throw Exception('Error al cargar adiciones: $e');
      }
    }
  }

  // Método para obtener una adición específica por ID
  Future<AdicionModel?> obtenerAdicionPorId(int id) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint/$id');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);
      
      if (response.statusCode == 200) {
        final dynamic decodedJson = json.decode(response.body);
        return AdicionModel.fromJson(decodedJson);
      } else if (response.statusCode == 404) {
        return null; // Adición no encontrada
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error obteniendo adición por ID $id: $e');
      throw Exception('Error al obtener la adición: $e');
    }
  }

  // Método para verificar la conectividad con la API
  Future<bool> verificarConectividad() async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await http.head(uri).timeout(
        const Duration(seconds: 10),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error verificando conectividad: $e');
      return false;
    }
  }
} 