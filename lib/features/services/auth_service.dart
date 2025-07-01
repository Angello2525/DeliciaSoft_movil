import '../models/api_response.dart';
import '../models/cliente.dart';
import '../models/usuario.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'dart:convert';


class AuthService {

  static Future<void> _saveAuthData(AuthResponse authResponse) async {
    await StorageService.saveToken(authResponse.token);
    if (authResponse.refreshToken != null) {
      await StorageService.saveRefreshToken(authResponse.refreshToken!);
    }
    await StorageService.saveUserType(authResponse.userType);
    if (authResponse.user != null) {
      await StorageService.saveUserData(authResponse.user!);
    }
  }

  static Future<AuthResponse> login(String email, String password, String userType) async {
    try {
      final response = await ApiService.login(email, password, userType);
      if (response.success) {
        await _saveAuthData(response);
      }
      return response;
    } catch (e) {
      throw Exception('Error en autenticación: $e');
    }
  }

 static Future<bool> registerClient(Cliente cliente) async {
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
      fechaNacimiento: cliente.fechaNacimiento,
      celular: cliente.celular,
      estado: cliente.estado,
    );

    final apiResponse = await ApiService.registerClient(clienteParaRegistro);
    return apiResponse.success;
  } catch (e) {
    throw Exception('Error en registro de cliente: $e');
  }
}



  static Future<bool> registerUser(Usuario usuario) async {
    try {
      final apiResponse = await ApiService.registerUser(usuario);
      return apiResponse.success;
    } catch (e) {
      throw Exception('Error en registro de usuario: $e');
    }
  }

  static Future<void> logout() async {
    await StorageService.clearAll();
  }

static Future<bool> requestPasswordReset(String email) async {
  try {
    final response = await ApiService.requestPasswordReset(email);
    return response.success;
  } catch (e) {
    String errorMessage = e.toString();
    // Si el mensaje contiene "enviado" es porque sí se envió el código
    if (errorMessage.toLowerCase().contains('enviado') || 
        errorMessage.toLowerCase().contains('código de recuperación')) {
      return true; // Retornar éxito
    }
    throw Exception('Error al solicitar restablecimiento de contraseña: $e');
  }
}

  static Future<bool> resetPassword(String email, String verificationCode, String newPassword) async {
    try {
      final response = await ApiService.resetPassword(email, verificationCode, newPassword);
      return response.success;
    } catch (e) {
      throw Exception('Error al restablecer contraseña: $e');
    }
  }

  static Future<ApiResponse<dynamic>> updateAdminProfile(Usuario userData) async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('No authentication token found.');
    }
    return await ApiService.updateUserProfile(token, userData);
  }

  static Future<ApiResponse<dynamic>> updateClientProfile(Cliente userData) async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('No authentication token found.');
    }
    return await ApiService.updateClientProfileApi(token, userData);
  }

  static Future<AuthResponse?> autoLogin() async {
    final token = await StorageService.getToken();
    final refreshToken = await StorageService.getRefreshToken();
    final userType = await StorageService.getUserType();
    final userDataMap = await StorageService.getUserData();

    if (token != null && userType != null && userDataMap != null) {
      if (refreshToken != null) {
        try {
          final refreshResponse = await ApiService.refreshToken(refreshToken);
          if (refreshResponse.success) {
            await _saveAuthData(refreshResponse);
            return refreshResponse;
          }
        } catch (e) {
          print('Error refreshing token: $e');
        }
      }

      return AuthResponse(
        success: true,
        message: 'Auto-login exitoso',
        token: token,
        refreshToken: refreshToken,
        user: userDataMap,
        userType: userType,
        expiresIn: null,
      );
    }
    return null;
  }

static Future<String?> checkUserType(String email) async {
  final response = await ApiService.checkUserExists(email);
  if (response.success) {
    return response.data;  // data = adminType o clientType
  }
  return null;
}

static Future<String?> validateCredentials(String email, String password, String userType) async {
  try {
    final response = await ApiService.validateCredentials(email, password, userType);
    if (response.success) {
      return null; // Credenciales válidas
    } else {
      return response.message ?? 'Credenciales incorrectas';
    }
  } catch (e) {
    String errorMessage = e.toString();
    if (errorMessage.contains('Exception:')) {
      errorMessage = errorMessage.replaceFirst('Exception:', '').trim();
    }
    return errorMessage.isEmpty ? 'Error validando credenciales' : errorMessage;
  }
}

static Future<bool> checkIfAdmin(String email) async {
    try {
      final response = await http.get(Uri.parse(Constants.getUserEndpoint));
      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        final user = users.firstWhere(
          (u) => u['correo'] == email,
          orElse: () => null,
        );
        return user != null;
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error verificando tipo de usuario: $e');
    }
  }

  static Future<bool> checkIfClient(String email) async {
    try {
      final response = await http.get(Uri.parse(Constants.getClientEndpoint));
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<dynamic> clients;

        // ⚠️ Verificamos si el backend devuelve lista o un solo objeto
        if (data is List) {
          clients = data;
        } else if (data is Map) {
          clients = [data];
        } else {
          throw Exception('Respuesta inesperada del servidor');
        }

        final client = clients.firstWhere(
          (c) => c['correo'] == email,
          orElse: () => null,
        );
        return client != null;
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error verificando tipo de cliente: $e');
    }
  }

 // REEMPLAZAR el método verifyCodeAndLogin en auth_service.dart
static Future<AuthResponse> verifyCodeAndLogin(String email, String password, String userType, String code) async {
  try {
    final response = await ApiService.verifyCodeAndLogin(email, password, userType, code);

    if (response.success && response.data != null) {
      final responseData = response.data as Map<String, dynamic>;

      // Obtener datos con manejo seguro de nulls y valores por defecto
      final String token = responseData['token']?.toString() ?? '';
      final String? refreshToken = responseData['refreshToken']?.toString();
      final Map<String, dynamic> userData = responseData['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final String finalUserType = responseData['userType']?.toString() ?? userType;
      final int? expiresIn = responseData['expiresIn'] as int?;

      // Validar que el token no esté vacío
      if (token.isEmpty) {
        print('Error: Token vacío recibido del servidor');
        return AuthResponse(
          success: false,
          message: 'Error: Token no recibido del servidor',
          token: '',
          refreshToken: null,
          user: null,
          userType: userType,
          expiresIn: null,
        );
      }

      // Validar que userData no esté completamente vacío para un login exitoso
      if (userData.isEmpty) {
        print('Warning: userData vacío, pero continuando con el login');
      }

      print('=== AUTH SERVICE - DATOS PROCESADOS ===');
      print('Token: ${token.substring(0, 20)}...');
      print('RefreshToken: ${refreshToken ?? 'null'}');
      print('UserData: $userData');
      print('UserType: $finalUserType');
      print('======================================');

      // Crear AuthResponse con los datos seguros
      final authResponse = AuthResponse(
        success: true,
        message: response.message ?? 'Login exitoso',
        token: token,
        refreshToken: refreshToken,
        user: userData.isNotEmpty ? userData : null,
        userType: finalUserType,
        expiresIn: expiresIn,
      );

      // Guardar datos de autenticación
      await _saveAuthData(authResponse);
      
      print('=== AUTH SERVICE - GUARDADO EXITOSO ===');
      print('Datos guardados correctamente');
      print('======================================');
      
      return authResponse;
    } else {
      // Crear AuthResponse de error con mensaje específico
      print('=== AUTH SERVICE - ERROR ===');
      print('Success: ${response.success}');
      print('Message: ${response.message}');
      print('Data: ${response.data}');
      print('===========================');
      
      return AuthResponse(
        success: false,
        message: response.message ?? 'Error en la verificación',
        token: '',
        refreshToken: null,
        user: null,
        userType: userType,
        expiresIn: null,
      );
    }
  } catch (e) {
    print('=== AUTH SERVICE - EXCEPCIÓN ===');
    print('Error: $e');
    print('===============================');
    
    String errorMessage = e.toString();
    
    // Limpiar el mensaje de error
    if (errorMessage.contains('Exception:')) {
      errorMessage = errorMessage.replaceFirst('Exception:', '').trim();
    }
    
    // Crear AuthResponse de error
    return AuthResponse(
      success: false,
      message: errorMessage.isEmpty ? 'Error en verificación y login' : errorMessage,
      token: '',
      refreshToken: null,
      user: null,
      userType: userType,
      expiresIn: null,
    );
  }
}

static Future<bool> sendVerificationCode(String email, String userType) async {
  try {
    final response = await ApiService.sendVerificationCode(email, userType);
    
    if (response.success) {
      return true;
    } else {
      throw Exception(response.message ?? 'Error enviando código');
    }
  } catch (e) {
    String errorMessage = e.toString();
    
    if (errorMessage.contains('Exception:')) {
      errorMessage = errorMessage.replaceFirst('Exception:', '').trim();
    }
    
    if (errorMessage.toLowerCase().contains('correo no registrado') || 
      errorMessage.toLowerCase().contains('usuario no encontrado')) {
      throw Exception('El correo electrónico no está registrado.');
    } else if (errorMessage.toLowerCase().contains('límite de códigos')) {
      throw Exception('Has alcanzado el límite de códigos por hora. Intenta más tarde.');
    } else if (errorMessage.toLowerCase().contains('servicio de correo')) {
      throw Exception('Error en el servicio de correo. Intenta más tarde.');
    }
    
    throw Exception(errorMessage.isEmpty ? 'Error enviando código de verificación' : errorMessage);
  }
}

static Future<ApiResponse<Cliente>> getCurrentClientProfile(String email) async {
  final token = await StorageService.getToken();
  if (token == null) {
    throw Exception('No authentication token found.');
  }
  return await ApiService.getCurrentClientProfile(token, email);
}

}