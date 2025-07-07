import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Modelo actualizado según tu JSON
class CatalogoSaborModel {
  final int? idSabor;
  final String? nombre;
  final double? precioAdicion;
  final int? idInsumos;
  final bool? estado;

  CatalogoSaborModel({
    this.idSabor,
    this.nombre,
    this.precioAdicion,
    this.idInsumos,
    this.estado,
  });

  factory CatalogoSaborModel.fromJson(Map<String, dynamic> json) {
    return CatalogoSaborModel(
      idSabor: json['idSabor'] as int?,
      nombre: json['nombre'] as String?,
      precioAdicion: json['precioAdicion']?.toDouble(),
      idInsumos: json['idInsumos'] as int?,
      estado: json['estado'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSabor': idSabor,
      'nombre': nombre,
      'precioAdicion': precioAdicion,
      'idInsumos': idInsumos,
      'estado': estado,
    };
  }

  CatalogoSaborModel copyWith({
    int? idSabor,
    String? nombre,
    double? precioAdicion,
    int? idInsumos,
    bool? estado,
  }) {
    return CatalogoSaborModel(
      idSabor: idSabor ?? this.idSabor,
      nombre: nombre ?? this.nombre,
      precioAdicion: precioAdicion ?? this.precioAdicion,
      idInsumos: idInsumos ?? this.idInsumos,
      estado: estado ?? this.estado,
    );
  }

  @override
  String toString() {
    return 'CatalogoSaborModel(idSabor: $idSabor, nombre: $nombre, precioAdicion: $precioAdicion, idInsumos: $idInsumos, estado: $estado)';
  }
}

// Clase para manejo de respuestas de la API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });
}

// Excepciones personalizadas
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// Servicio principal para Sabores
class SaboresService {
  static const String _baseUrl = 'https://tu-api.com/api'; // Cambia por tu URL
  static const Duration _timeout = Duration(seconds: 30);

  // Headers por defecto
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Método para obtener todos los sabores
  static Future<ApiResponse<List<CatalogoSaborModel>>> getAllSabores() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sabores'),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      return _handleResponse<List<CatalogoSaborModel>>(
        response,
        (data) {
          if (data is List) {
            return data.map((json) => CatalogoSaborModel.fromJson(json)).toList();
          }
          throw ApiException('Formato de datos inválido');
        },
      );
    } catch (e) {
      return _handleError<List<CatalogoSaborModel>>(e);
    }
  }

  // Método para obtener sabores activos
  static Future<ApiResponse<List<CatalogoSaborModel>>> getSaboresActivos() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sabores/activos'),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      return _handleResponse<List<CatalogoSaborModel>>(
        response,
        (data) {
          if (data is List) {
            return data.map((json) => CatalogoSaborModel.fromJson(json)).toList();
          }
          throw ApiException('Formato de datos inválido');
        },
      );
    } catch (e) {
      return _handleError<List<CatalogoSaborModel>>(e);
    }
  }

  // Método para obtener un sabor por ID
  static Future<ApiResponse<CatalogoSaborModel>> getSaborById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sabores/$id'),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      return _handleResponse<CatalogoSaborModel>(
        response,
        (data) => CatalogoSaborModel.fromJson(data),
      );
    } catch (e) {
      return _handleError<CatalogoSaborModel>(e);
    }
  }

  // Método para crear un nuevo sabor
  static Future<ApiResponse<CatalogoSaborModel>> createSabor(
    CatalogoSaborModel sabor,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sabores'),
        headers: _defaultHeaders,
        body: jsonEncode(sabor.toJson()),
      ).timeout(_timeout);

      return _handleResponse<CatalogoSaborModel>(
        response,
        (data) => CatalogoSaborModel.fromJson(data),
      );
    } catch (e) {
      return _handleError<CatalogoSaborModel>(e);
    }
  }

  // Método para actualizar un sabor
  static Future<ApiResponse<CatalogoSaborModel>> updateSabor(
    int id,
    CatalogoSaborModel sabor,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/sabores/$id'),
        headers: _defaultHeaders,
        body: jsonEncode(sabor.toJson()),
      ).timeout(_timeout);

      return _handleResponse<CatalogoSaborModel>(
        response,
        (data) => CatalogoSaborModel.fromJson(data),
      );
    } catch (e) {
      return _handleError<CatalogoSaborModel>(e);
    }
  }

  // Método para eliminar un sabor
  static Future<ApiResponse<bool>> deleteSabor(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/sabores/$id'),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      return _handleResponse<bool>(
        response,
        (data) => true,
      );
    } catch (e) {
      return _handleError<bool>(e);
    }
  }

  // Método para cambiar el estado de un sabor
  static Future<ApiResponse<CatalogoSaborModel>> toggleSaborEstado(
    int id,
    bool estado,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/sabores/$id/estado'),
        headers: _defaultHeaders,
        body: jsonEncode({'estado': estado}),
      ).timeout(_timeout);

      return _handleResponse<CatalogoSaborModel>(
        response,
        (data) => CatalogoSaborModel.fromJson(data),
      );
    } catch (e) {
      return _handleError<CatalogoSaborModel>(e);
    }
  }

  // Método privado para manejar respuestas
  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic) parser,
  ) {
    final statusCode = response.statusCode;

    // Verificar si la respuesta es exitosa
    if (statusCode >= 200 && statusCode < 300) {
      try {
        final jsonData = jsonDecode(response.body);
        final data = parser(jsonData);
        
        return ApiResponse<T>(
          success: true,
          data: data,
          statusCode: statusCode,
        );
      } catch (e) {
        return ApiResponse<T>(
          success: false,
          message: 'Error al procesar la respuesta: $e',
          statusCode: statusCode,
        );
      }
    } else {
      // Manejar errores HTTP
      String errorMessage = _getErrorMessage(statusCode);
      
      try {
        final jsonData = jsonDecode(response.body);
        if (jsonData['message'] != null) {
          errorMessage = jsonData['message'];
        }
      } catch (e) {
        // Si no se puede decodificar, usar el mensaje por defecto
      }

      return ApiResponse<T>(
        success: false,
        message: errorMessage,
        statusCode: statusCode,
      );
    }
  }

  // Método privado para manejar errores
  static ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is SocketException) {
      return ApiResponse<T>(
        success: false,
        message: 'Sin conexión a internet',
      );
    } else if (error is HttpException) {
      return ApiResponse<T>(
        success: false,
        message: 'Error HTTP: ${error.message}',
      );
    } else if (error is FormatException) {
      return ApiResponse<T>(
        success: false,
        message: 'Error de formato de datos',
      );
    } else {
      return ApiResponse<T>(
        success: false,
        message: 'Error inesperado: ${error.toString()}',
      );
    }
  }

  // Método privado para obtener mensajes de error por código de estado
  static String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Solicitud incorrecta';
      case 401:
        return 'No autorizado';
      case 403:
        return 'Acceso denegado';
      case 404:
        return 'Recurso no encontrado';
      case 405:
        return 'Método no permitido';
      case 408:
        return 'Tiempo de espera agotado';
      case 409:
        return 'Conflicto en los datos';
      case 422:
        return 'Datos no válidos';
      case 500:
        return 'Error interno del servidor';
      case 502:
        return 'Puerta de enlace incorrecta';
      case 503:
        return 'Servicio no disponible';
      default:
        return 'Error en la solicitud (Código: $statusCode)';
    }
  }
}

// Ejemplo de uso del servicio
class EjemploUso {
  static Future<void> ejemploGetSabores() async {
    // Obtener todos los sabores
    final response = await SaboresService.getAllSabores();
    
    if (response.success) {
      print('Sabores obtenidos: ${response.data?.length}');
      for (var sabor in response.data ?? []) {
        print('- ${sabor.nombre}: \$${sabor.precioAdicion}');
      }
    } else {
      print('Error: ${response.message}');
    }
  }

  static Future<void> ejemploCreateSabor() async {
    // Crear un nuevo sabor
    final nuevoSabor = CatalogoSaborModel(
      nombre: 'Fresa',
      precioAdicion: 1200.0,
      idInsumos: 2,
      estado: true,
    );

    final response = await SaboresService.createSabor(nuevoSabor);
    
    if (response.success) {
      print('Sabor creado exitosamente: ${response.data?.nombre}');
    } else {
      print('Error al crear sabor: ${response.message}');
    }
  }
}