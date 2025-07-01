// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/cliente.dart';
import '../models/usuario.dart';
import '../utils/constants.dart';
import '../models/rol.dart';

class ApiService {
  static const String _baseUrl = Constants.baseUrl;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> _headersWithToken(String token) => {
        ..._headers,
        'Authorization': 'Bearer $token',
      };

  static void _handleHttpError(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage = 'Error HTTP ${response.statusCode}';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('message')) {
          errorMessage = decoded['message']?.toString() ?? errorMessage;
        } else if (decoded is Map && decoded.containsKey('errors') && decoded['errors'] is Map) {
          final Map<String, dynamic> errorsMap = decoded['errors'];
          errorMessage = errorsMap.values.expand((e) => (e as List).map((i) => i.toString())).join(', ');
        } else if (decoded is String) {
          errorMessage = decoded;
        } else {
          errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
        }
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  // ==================== MÉTODOS DE AUTENTICACIÓN ====================

  // LOGIN DIRECTO (para métodos que no requieren verificación)
  static Future<AuthResponse> login(String email, String password, String userType) async {
    try {
      String endpoint;
      if (userType == Constants.clientType) {
        endpoint = '${Constants.loginClientEndpoint}/login';
      } else {
        endpoint = '${Constants.loginUserEndpoint}/login';
      }

      final response = await http.post(
        Uri.parse(endpoint),
        headers: _headers,
        body: jsonEncode({
          'correo': email,
          'contrasena': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Generar token simple
        final token = base64Encode(utf8.encode('${email}_${DateTime.now().millisecondsSinceEpoch}'));
        
        return AuthResponse(
          success: true,
          message: 'Login exitoso',
          token: token,
          refreshToken: null,
          user: data,
          userType: userType,
          expiresIn: null,
        );
      } else {
        final errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message']?.toString() ?? 'Error en el login',
          token: '',
          refreshToken: null,
          user: null,
          userType: userType,
          expiresIn: null,
        );
      }
    } catch (e) {
      throw Exception('Error en el login: $e');
    }
  }

static Future<ApiResponse<dynamic>> sendVerificationCode(String email, String userType) async {
  try {
    // Primero verificar en qué tabla existe el usuario
    final userTypeCheck = await checkUserExists(email);
    String actualUserType = userType;
    
    if (userTypeCheck.success && userTypeCheck.data != null) {
      actualUserType = userTypeCheck.data!;
    } else {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Usuario no encontrado en el sistema',
        data: null,
      );
    }

    final response = await http.post(
      Uri.parse(Constants.sendVerificationCodeEndpoint),
      headers: _headers,
      body: jsonEncode({
        'correo': email,
        'userType': actualUserType,
      }),
    );
    
    print('=== ENVIANDO CÓDIGO DE VERIFICACIÓN ===');
    print('URL: ${Constants.sendVerificationCodeEndpoint}');
    print('Email: $email');
    print('UserType Original: $userType');
    print('UserType Verificado: $actualUserType');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('====================================');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        return ApiResponse<dynamic>(
          success: true,
          message: data['message']?.toString() ?? 'Código enviado exitosamente',
          data: {'userType': actualUserType}, // Devolver el tipo correcto
        );
      } catch (e) {
        return ApiResponse<dynamic>(
          success: true,
          message: 'Código enviado exitosamente',
          data: {'userType': actualUserType},
        );
      }
    } else {
      String errorMessage = 'Error enviando código';
      
      try {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message']?.toString() ?? errorMessage;
        }
      } catch (e) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      }
      
      return ApiResponse<dynamic>(
        success: false,
        message: errorMessage,
        data: null,
      );
    }
  } catch (e) {
    print('Error enviando código de verificación: $e');
    return ApiResponse<dynamic>(
      success: false,
      message: e.toString(),
      data: null,
    );
  }
}

static Future<ApiResponse<Map<String, dynamic>>> validateCredentials(String email, String password, String userType) async {
  try {
    String endpoint;
    if (userType == Constants.clientType) {
      endpoint = Constants.loginClientEndpoint;
    } else {
      endpoint = Constants.loginUserEndpoint;
    }

    final response = await http.post(
      Uri.parse('$endpoint/validate'), // Endpoint para solo validar
      headers: _headers,
      body: jsonEncode({
        'correo': email,
        'contrasena': password,
      }),
    );

    print('=== VALIDANDO CREDENCIALES ===');
    print('URL: $endpoint/validate');
    print('Email: $email');
    print('UserType: $userType');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('=============================');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: 'Credenciales válidas',
        data: data,
      );
    } else if (response.statusCode == 401) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Contraseña incorrecta',
        data: null,
      );
    } else if (response.statusCode == 404) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Usuario no encontrado',
        data: null,
      );
    } else {
      String errorMessage = 'Error validando credenciales';
      try {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message']?.toString() ?? errorMessage;
        }
      } catch (e) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      }
      
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: errorMessage,
        data: null,
      );
    }
  } catch (e) {
    print('Error validando credenciales: $e');
    return ApiResponse<Map<String, dynamic>>(
      success: false,
      message: 'Error de conexión',
      data: null,
    );
  }
}

  // REEMPLAZAR el método verifyCodeAndLogin en api_service.dart
static Future<ApiResponse<dynamic>> verifyCodeAndLogin(String email, String password, String userType, String code) async {
  try {
    final requestBody = {
      'Email': email,       
      'Password': password, 
      'UserType': userType, 
      'Code': code,         
    };

    final response = await http.post(
      Uri.parse(Constants.verifyCodeAndLoginEndpoint),
      headers: _headers,
      body: jsonEncode(requestBody),
    );
    
    print('=== VERIFICANDO CÓDIGO Y LOGIN (API Service) ===');
    print('URL: ${Constants.verifyCodeAndLoginEndpoint}');
    print('Request Body (sent): ${jsonEncode(requestBody)}');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('================================');
    
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        
        // Verificar si la respuesta indica éxito
        bool isSuccess = data['success'] == true || 
                        data.containsKey('token') || 
                        data.containsKey('user');
        
        if (isSuccess) {
          // Procesar los datos de forma segura con valores por defecto
          final processedData = <String, dynamic>{};
          
          // Token (requerido) - usar string vacío si es null
          processedData['token'] = data['token']?.toString() ?? '';
          
          // RefreshToken (opcional) - permitir null
          processedData['refreshToken'] = data['refreshToken']?.toString();
          
          // User data (requerido para login exitoso) - usar mapa vacío si es null
          if (data.containsKey('user') && data['user'] != null) {
            processedData['user'] = Map<String, dynamic>.from(data['user'] as Map);
          } else {
            processedData['user'] = <String, dynamic>{};
          }
          
          // UserType - usar el userType pasado como parámetro si no viene en la respuesta
          processedData['userType'] = data['userType']?.toString() ?? userType;
          
          // ExpiresIn (opcional) - permitir null
          if (data.containsKey('expiresIn') && data['expiresIn'] != null) {
            processedData['expiresIn'] = data['expiresIn'];
          }
          
          // Message - usar mensaje por defecto si es null
          final message = data['message']?.toString() ?? 'Login exitoso';
          
          return ApiResponse<dynamic>(
            success: true,
            message: message,
            data: processedData,
          );
        } else {
          return ApiResponse<dynamic>(
            success: false,
            message: data['message']?.toString() ?? 'Error en la verificación',
            data: null,
          );
        }
      } catch (e) {
        print('Error parseando respuesta exitosa: $e');
        return ApiResponse<dynamic>(
          success: false,
          message: 'Error procesando respuesta del servidor',
          data: null,
        );
      }
    } else if (response.statusCode == 400) {
      // Error de validación (código incorrecto, expirado, etc.)
      try {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message']?.toString() ?? 'Código inválido o expirado';
        
        return ApiResponse<dynamic>(
          success: false,
          message: errorMessage,
          data: null,
        );
      } catch (e) {
        return ApiResponse<dynamic>(
          success: false,
          message: 'Código inválido o expirado',
          data: null,
        );
      }
    } else if (response.statusCode == 401) {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Credenciales incorrectas',
        data: null,
      );
    } else if (response.statusCode == 404) {
      return ApiResponse<dynamic>(
        success: false,
        message: 'Usuario no encontrado',
        data: null,
      );
    } else {
      // Otros errores del servidor
      String errorMessage = 'Error del servidor';
      try {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message']?.toString() ?? errorMessage;
        }
      } catch (e) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      }
      
      return ApiResponse<dynamic>(
        success: false,
        message: errorMessage,
        data: null,
      );
    }
  } catch (e) {
    print('Excepción en verifyCodeAndLogin: $e');
    return ApiResponse<dynamic>(
      success: false,
      message: 'Error de conexión o inesperado. Intenta nuevamente.',
      data: null,
    );
  }
}

  // VERIFICAR SI USUARIO EXISTE Y OBTENER TIPO
 static Future<ApiResponse<String>> checkUserExists(String email) async {
  try {
    // Primero verificar en usuarios (admin)
    final userResponse = await http.get(
      Uri.parse('${Constants.getUserEndpoint}?correo=$email'),
      headers: _headers,
    );
    
    if (userResponse.statusCode == 200) {
      final userData = jsonDecode(userResponse.body);
      if (userData != null && userData.isNotEmpty) {
        return ApiResponse<String>(
          success: true,
          message: 'Usuario encontrado',
          data: Constants.adminType, // admin
        );
      }
    }
    
    // Luego verificar en clientes
    final clientResponse = await http.get(
      Uri.parse('${Constants.getClientEndpoint}?correo=$email'),
      headers: _headers,
    );
    
    if (clientResponse.statusCode == 200) {
      final clientData = jsonDecode(clientResponse.body);
      if (clientData != null && clientData.isNotEmpty) {
        return ApiResponse<String>(
          success: true,
          message: 'Usuario encontrado',
          data: Constants.clientType, // cliente
        );
      }
    }
    
    return ApiResponse<String>(
      success: false,
      message: 'Usuario no encontrado',
      data: null,
    );
  } catch (e) {
    throw Exception('Error verificando usuario: $e');
  }
}


  // ==================== REGISTRO ====================

 // REEMPLAZAR el método registerClient en api_service.dart
static Future<ApiResponse<Cliente>> registerClient(Cliente cliente) async {
  try {
    final clienteParaRegistro = Cliente.forRegistration(
      tipoDocumento: cliente.tipoDocumento,
      numeroDocumento: cliente.numeroDocumento,
      nombre: cliente.nombre,
      apellido: cliente.apellido,
      correo: cliente.correo,
      contrasena: cliente.contrasena,
      direccion: cliente.direccion,
      barrio: cliente.barrio,
      ciudad: cliente.ciudad,
      fechaNacimiento: cliente.fechaNacimiento,  // pasamos como DateTime
      celular: cliente.celular,
      estado: cliente.estado,
    );

    final clienteJson = clienteParaRegistro.toJson();
    // Aquí convertimos fechaNacimiento a "yyyy-MM-dd"
    clienteJson['fechaNacimiento'] = cliente.fechaNacimiento?.toIso8601String().split('T')[0];

    final body = jsonEncode(clienteJson);

    print('=== REGISTRANDO CLIENTE ===');
    print('URL: ${Constants.registerClientEndpoint}');
    print('JSON: $body');
    print('=========================');

    final response = await http.post(
      Uri.parse(Constants.registerClientEndpoint),
      headers: _headers,
      body: body,
    );

    print('=== RESPUESTA REGISTRO CLIENTE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('=================================');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ApiResponse<Cliente>(
        success: true,
        message: 'Cliente registrado exitosamente',
        data: Cliente.fromJson(data),
      );
    } else {
      _handleHttpError(response);
      return ApiResponse<Cliente>(
        success: false,
        message: 'Error en el registro',
        data: null,
      );
    }
  } catch (e) {
    print('Error en registerClient: $e');
    throw Exception('Error registrando cliente: $e');
  }
}


  static Future<ApiResponse<dynamic>> registerUser(Usuario usuario) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.registerUserEndpoint),
        headers: _headers,
        body: jsonEncode(usuario.toJson()),
      );
      _handleHttpError(response);
      final data = jsonDecode(response.body);
      return ApiResponse<Usuario>.fromJson(data, (Object? json) => Usuario.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      throw Exception('Error registrando usuario: $e');
    }
  }

  // ==================== RESETEO DE CONTRASEÑA ====================

  static Future<PasswordResetResponse> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.requestPasswordResetEndpoint),
        headers: _headers,
        body: jsonEncode({'Email': email}),
      );
      _handleHttpError(response);
      final data = jsonDecode(response.body);
      return PasswordResetResponse.fromJson(data);
    } catch (e) {
      throw Exception('Error solicitando reseteo de contraseña: $e');
    }
  }

  static Future<PasswordResetResponse> resetPassword(String email, String verificationCode, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.resetPasswordEndpoint),
        headers: _headers,
        body: jsonEncode({
          'Email': email,
          'Code': verificationCode,
          'NewPassword': newPassword,
        }),
      );
      _handleHttpError(response);
      final data = jsonDecode(response.body);
      return PasswordResetResponse.fromJson(data);
    } catch (e) {
      throw Exception('Error reseteando contraseña: $e');
    }
  }

  // ==================== REFRESH TOKEN ====================

  static Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.refreshTokenEndpoint),
        headers: _headers,
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      _handleHttpError(response);
      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      throw Exception('Error refreshing token: $e');
    }
  }

  // ==================== MÉTODOS ADMIN ====================
  // (Mantengo los nombres de clave JSON como los tenías si no hay indicaciones de lo contrario)

  static Future<ApiResponse<List<Usuario>>> getAllUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users'),
        headers: _headersWithToken(token),
      );
      _handleHttpError(response);
      final data = jsonDecode(response.body);
      return ApiResponse<List<Usuario>>.fromJson(data, (Object? json) => (json as List).map((i) => Usuario.fromJson(i as Map<String, dynamic>)).toList());
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  static Future<ApiResponse<Cliente>> getClientProfile(String token, int idCliente) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/Clientes/$idCliente'),
      headers: _headersWithToken(token),
    );
    _handleHttpError(response);
    final data = jsonDecode(response.body);
    return ApiResponse<Cliente>.fromJson(
      data, 
      (Object? json) => Cliente.fromJson(json as Map<String, dynamic>)
    );
  } catch (e) {
    throw Exception('Error obteniendo perfil del cliente: $e');
  }
}

static Future<ApiResponse<Usuario>> getUserProfile(String token, int idUsuario) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/Usuarios/$idUsuario'),
      headers: _headersWithToken(token),
    );
    _handleHttpError(response);
    final data = jsonDecode(response.body);
    return ApiResponse<Usuario>.fromJson(
      data,
      (Object? json) => Usuario.fromJson(json as Map<String, dynamic>),
    );
  } catch (e) {
    throw Exception('Error obteniendo perfil del usuario: $e');
  }
}



 static Future<ApiResponse<List<Cliente>>> getAllClients(String token) async {
  try {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/Clientes'), // ✅ RUTA CORRECTA
      headers: _headersWithToken(token),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse<List<Cliente>>(
        success: true,
        message: 'Clientes obtenidos exitosamente',
        data: (data as List).map((i) => Cliente.fromJson(i as Map<String, dynamic>)).toList(),
      );
    } else {
      _handleHttpError(response);
      return ApiResponse<List<Cliente>>(
        success: false,
        message: 'Error obteniendo clientes',
        data: null,
      );
    }
  } catch (e) {
    throw Exception('Error fetching clients: $e');
  }
}

  static Future<ApiResponse<List<Rol>>> getAllRoles(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/roles'),
        headers: _headersWithToken(token),
      );
      _handleHttpError(response);
      final data = jsonDecode(response.body);
      return ApiResponse<List<Rol>>.fromJson(data, (Object? json) => (json as List).map((i) => Rol.fromJson(i as Map<String, dynamic>)).toList());
    } catch (e) {
      throw Exception('Error fetching roles: $e');
    }
  }

  static Future<ApiResponse<Usuario>> updateUserProfile(String token, Usuario usuario) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/users/${usuario.idUsuario}'),
        headers: _headersWithToken(token),
        body: jsonEncode(usuario.toJson()),
      );
      _handleHttpError(response);
      final data = jsonDecode(response.body);
      return ApiResponse<Usuario>.fromJson(data, (Object? json) => Usuario.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      throw Exception('Error al actualizar perfil de usuario (admin): $e');
    }
  }

  static Future<ApiResponse<Cliente>> updateClientProfileApi(String token, Cliente cliente) async {
  try {
    final response = await http.put(
      Uri.parse('${Constants.baseUrl}/Clientes/${cliente.idCliente}'), // ✅ RUTA CORRECTA
      headers: _headersWithToken(token),
      body: jsonEncode(cliente.toJson()),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse<Cliente>(
        success: true,
        message: 'Cliente actualizado exitosamente',
        data: Cliente.fromJson(data),
      );
    } else {
      _handleHttpError(response);
      return ApiResponse<Cliente>(
        success: false,
        message: 'Error actualizando cliente',
        data: null,
      );
    }
  } catch (e) {
    throw Exception('Error al actualizar cliente (admin): $e');
  }
}

  static Future<ApiResponse<Usuario>> updateUsuarioStatus(String token, int idUsuario, bool newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/users/$idUsuario/status'),
        headers: _headersWithToken(token),
        body: jsonEncode({'estado': newStatus}), // Mantener camelCase si es lo que funciona
      );
      _handleHttpError(response);
      final data = jsonDecode(response.body);
      return ApiResponse<Usuario>.fromJson(data, (Object? json) => Usuario.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      throw Exception('Error actualizando estado de usuario: $e');
    }
  }

  static Future<ApiResponse<Cliente>> updateClientStatus(String token, int idCliente, bool newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/clients/$idCliente/status'),
        headers: _headersWithToken(token),
      );
      _handleHttpError(response);
      final data = jsonDecode(response.body);
      return ApiResponse<Cliente>.fromJson(data, (Object? json) => Cliente.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      throw Exception('Error actualizando estado de cliente: $e');
    }
  }

  static Future<ApiResponse<Cliente>> getClientById(String token, int idCliente) async {
  try {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/Clientes/$idCliente'), 
      headers: _headersWithToken(token),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse<Cliente>(
        success: true,
        message: 'Cliente obtenido exitosamente',
        data: Cliente.fromJson(data),
      );
    } else {
      _handleHttpError(response);
      return ApiResponse<Cliente>(
        success: false,
        message: 'Error obteniendo cliente',
        data: null,
      );
    }
  } catch (e) {
    throw Exception('Error al obtener el cliente por ID: $e');
  }
}

static Future<ApiResponse<Cliente>> getCurrentClientProfile(String token, String email) async {
  try {
    final response = await http.get(
      Uri.parse('${Constants.getClientEndpoint}?correo=$email'),
      headers: _headersWithToken(token),
    );
    _handleHttpError(response);
    final data = jsonDecode(response.body);
    return ApiResponse<Cliente>.fromJson(data, (Object? json) => Cliente.fromJson(json as Map<String, dynamic>));
  } catch (e) {
    throw Exception('Error al obtener cliente por email: $e');
  }
}
  
}
