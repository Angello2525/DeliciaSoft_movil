// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../models/cliente.dart';
import '../models/api_response.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  Usuario? _currentUser;
  Cliente? _currentClient;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  String? _userType;
  String? _token;

  bool _isSendingCode = false;
  bool _isVerifyingCode = false;

  // Getters
  Usuario? get currentUser => _currentUser;
  Cliente? get currentClient => _currentClient;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get userType => _userType;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearVerificationState() {
    _isSendingCode = false;
    _isVerifyingCode = false;
  }

 Future<String?> checkUserType(String email) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    // 1) Consultamos si existe como admin
    final isAdmin = await AuthService.checkIfAdmin(email);
    if (isAdmin) {
      return Constants.adminType;
    }

    // 2) Consultamos si existe como cliente
    final isClient = await AuthService.checkIfClient(email);
    if (isClient) {
      return Constants.clientType;
    }

    // 3) No existe en ninguno
    return null;
  } catch (e) {
    _error = e.toString().contains('Exception:')
        ? e.toString().replaceFirst('Exception:', '').trim()
        : 'Error verificando usuario';
    return null;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<Map<String, dynamic>?> sendVerificationCode(String email, String userType) async {
  if (_isSendingCode) {
    return {'error': 'Ya se está enviando un código, por favor espera...'};
  }

  _isSendingCode = true;

  try {
    final response = await AuthService.sendVerificationCode(email, userType);
    if (response) {
      return {'success': true, 'userType': userType};
    } else {
      return {'error': 'Error enviando código de verificación'};
    }
  } catch (e) {
    String errorMessage = e.toString();
    if (errorMessage.contains('Exception:')) {
      errorMessage = errorMessage.replaceFirst('Exception:', '').trim();
    }
    return {'error': errorMessage.isNotEmpty ? errorMessage : 'Error enviando código de verificación'};
  } finally {
    _isSendingCode = false;
  }
}


  Future<String?> verifyCodeAndLogin(
    String email,
    String password,
    String userType,
    String code,
  ) async {
    if (_isVerifyingCode) {
      return 'Ya se está verificando un código, por favor espera...';
    }

    _isVerifyingCode = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await AuthService.verifyCodeAndLogin(email, password, userType, code);

      if (response.success) {
        _isAuthenticated = true;
        _userType = response.userType;
        _token = response.token; // ASIGNAMOS EL TOKEN

        // AÑADIMOS LA LÓGICA PARA GUARDAR TOKEN Y USERDATA
        if (_token != null && _userType != null) {
          await StorageService.saveToken(_token!);
          await StorageService.saveUserType(_userType!);

          final userDataMap = response.user as Map<String, dynamic>?;
          if (userDataMap != null) {
            if (_userType == Constants.adminType) {
              _currentUser = Usuario.fromJson(userDataMap);
              _currentClient = null; // Limpia el otro tipo de usuario
              await StorageService.saveUserData(_currentUser!.toJson());
            } else if (_userType == Constants.clientType) {
              _currentClient = Cliente.fromJson(userDataMap);
              _currentUser = null; // Limpia el otro tipo de usuario
              await StorageService.saveUserData(_currentClient!.toJson());
            }
          } else {
            debugPrint('Advertencia: El campo "user" es null en la respuesta de login.');
            _error = 'Datos de usuario incompletos recibidos. Intente de nuevo.';
            _isAuthenticated = false;
          }
        } else { // Bloque ELSE si token o userType son nulos
          debugPrint('Advertencia: Token o UserType son null en la respuesta de login.');
          _error = 'Error en la respuesta de autenticación: token o tipo de usuario faltante.';
          _isAuthenticated = false;
        }

        notifyListeners();
        return _error; // Retorna _error (que será null en caso de éxito)
      } else {
        final msg = response.message.toLowerCase();

        if (msg.contains('código inválido')) {
          return 'El código ingresado no es válido. Verifica e intenta nuevamente.';
        } else if (msg.contains('código expirado')) {
          return 'El código ha expirado. Solicita un nuevo código.';
        } else if (msg.contains('contraseña')) {
          return 'La contraseña es incorrecta.';
        } else if (msg.contains('usuario no encontrado')) {
          return 'El usuario no está registrado.';
        }

        _error = response.message.isNotEmpty
            ? response.message
            : 'Error en la verificación';
        notifyListeners(); // Notifica el error aquí
        return _error;
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceFirst('Exception:', '').trim();
      }
      if (errorMessage.toLowerCase().contains('connection')) {
        return 'Error de conexión. Verifica tu internet e intenta nuevamente.';
      } else if (errorMessage.toLowerCase().contains('timeout')) {
        return 'Tiempo de espera agotado. Intenta nuevamente.';
      }

      _error = errorMessage.isNotEmpty
          ? errorMessage
          : 'Error en la verificación';
      notifyListeners(); // Notifica el error aquí
      return _error;
    } finally {
      _isVerifyingCode = false;
      _isLoading = false;
      // notifyListeners(); // Ya se llama dentro del if/else
    }
  }

Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final authResponse = await AuthService.autoLogin();
      if (authResponse != null && authResponse.success) {
        _isAuthenticated = true;
        _userType = authResponse.userType;
        _token = authResponse.token;

        if (authResponse.user != null && _userType != null && _token != null) {
          final userDataMap = authResponse.user as Map<String, dynamic>;
          if (authResponse.userType == Constants.adminType) {
            _currentUser = Usuario.fromJson(userDataMap);
          } else if (authResponse.userType == Constants.clientType) {
            _currentClient = Cliente.fromJson(userDataMap);
          }
        } else {
          _error = 'Datos de auto-login incompletos (token, tipo de usuario o datos de usuario).';
          _isAuthenticated = false;
          await AuthService.logout(); 
          // CORRECCIÓN: Usamos clearAuthData() en lugar de deletes individuales
          await StorageService.clearAuthData(); 

          if (kDebugMode) {
            print('Error en initialize: Datos incompletos en autoLogin.');
          }
        }
      }
    } catch (e) {
      _error = e.toString().contains('Exception:')
          ? e.toString().replaceFirst('Exception:', '').trim()
          : 'Error en inicialización de autenticación';
      _isAuthenticated = false;
      await AuthService.logout();
      // CORRECCIÓN: Usamos clearAuthData() en lugar de deletes individuales
      await StorageService.clearAuthData(); 

      if (kDebugMode) {
        print('Error en AuthProvider initialize: $_error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 Future<String?> login(String email, String password, String userType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final AuthResponse response = await AuthService.login(email, password, userType);
      if (response.success) {
        _isAuthenticated = true;
        _userType = response.userType;
        _token = response.token; // ASIGNAMOS EL TOKEN

        // AÑADIMOS LA LÓGICA PARA GUARDAR TOKEN Y USERDATA
        if (_token != null && _userType != null) {
          await StorageService.saveToken(_token!);
          await StorageService.saveUserType(_userType!);

          if (response.user != null) {
            final userDataMap = response.user as Map<String, dynamic>;
            if (_userType == Constants.adminType) {
              _currentUser = Usuario.fromJson(userDataMap);
              _currentClient = null; // Limpia el otro tipo de usuario
              await StorageService.saveUserData(_currentUser!.toJson());
            } else if (_userType == Constants.clientType) {
              _currentClient = Cliente.fromJson(userDataMap);
              _currentUser = null; // Limpia el otro tipo de usuario
              await StorageService.saveUserData(_currentClient!.toJson());
            }
          } else {
            debugPrint('Advertencia: El campo "user" es null en la respuesta de login.');
            _error = 'Datos de usuario incompletos recibidos. Intente de nuevo.';
            _isAuthenticated = false;
          }
        } else { // Bloque ELSE si token o userType son nulos
          debugPrint('Advertencia: Token o UserType son null en la respuesta de login.');
          _error = 'Error en la respuesta de autenticación: token o tipo de usuario faltante.';
          _isAuthenticated = false;
        }

        notifyListeners(); // Mueve notifyListeners aquí para actualizar después de todos los cambios
        return _error; // Retorna _error (que será null en caso de éxito)
      } else {
        _error = response.message.isNotEmpty ? response.message : Constants.loginError;
        notifyListeners(); // Notifica el error aquí también
        return _error;
      }
    } catch (e) {
      _error = e.toString().contains('Exception:')
          ? e.toString().replaceFirst('Exception:', '').trim()
          : Constants.loginError;
      if (kDebugMode) {
        print('Error en AuthProvider login: $_error');
      }
      notifyListeners(); // Notifica el error aquí
      return _error;
    } finally {
      _isLoading = false;
      // notifyListeners(); // Ya se llama dentro del if/else
    }
  }

  Future<String?> registerClient(Cliente cliente) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await AuthService.registerClient(cliente);
      if (success) {
        return null;
      } else {
        _error = Constants.registerError;
        return _error;
      }
    } catch (e) {
      _error = e.toString().contains('Exception:')
          ? e.toString().replaceFirst('Exception:', '').trim()
          : Constants.registerError;
      if (kDebugMode) {
        print('Error en AuthProvider registerClient: $_error');
      }
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> registerUser(Usuario usuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await AuthService.registerUser(usuario);
      if (success) {
        return null;
      } else {
        _error = Constants.registerError;
        return _error;
      }
    } catch (e) {
      _error = e.toString().contains('Exception:')
          ? e.toString().replaceFirst('Exception:', '').trim()
          : Constants.registerError;
      if (kDebugMode) {
        print('Error en AuthProvider registerUser: $_error');
      }
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await AuthService.logout();

   await StorageService.clearAuthData(); 

    _isAuthenticated = false;
    _currentUser = null;
    _currentClient = null;
    _userType = null;
    _token = null; // LIMPIAMOS LA PROPIEDAD _token
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await AuthService.requestPasswordReset(email);
      if (success) {
        return null;
      } else {
        _error = 'Error al solicitar restablecimiento de contraseña.';
        return _error;
      }
    } catch (e) {
      _error = e.toString().contains('Exception:')
          ? e.toString().replaceFirst('Exception:', '').trim()
          : 'Error al solicitar restablecimiento de contraseña';
      if (kDebugMode) {
        print('Error en AuthProvider forgotPassword: $_error');
      }
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

Future<String?> resetPassword(String email, String verificationCode, String newPassword) async {
  _isLoading = true;
  _error = null;
  notifyListeners();
  try {
    final success = await AuthService.resetPassword(email, verificationCode, newPassword);
    if (success) {
      return null;
    } else {
      _error = 'Error al restablecer contraseña.';
      return _error;
    }
  } catch (e) {
    _error = e.toString().contains('Exception:')
        ? e.toString().replaceFirst('Exception:', '').trim()
        : 'Error al restablecer contraseña';
    if (kDebugMode) {
      print('Error en AuthProvider resetPassword: $_error');
    }
    return _error;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

Future<String?> updateUserProfile(Map<String, dynamic> userData) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    // Crear Usuario desde el Map
    final usuario = Usuario.fromJson(userData);
    
    final response = await AuthService.updateAdminProfile(usuario);
    
    if (response.success) {
      // Actualizar currentUser con los nuevos datos
      if (response.data != null) {
        _currentUser = response.data as Usuario;
        // Guardar los datos actualizados en storage
        await StorageService.saveUserData(_currentUser!.toJson());
      }
      return null; // Sin error
    } else {
      _error = response.message.isNotEmpty ? response.message : 'Error al actualizar perfil';
      return _error;
    }
  } catch (e) {
    _error = 'Error al actualizar perfil: $e';
    return _error;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<String?> updateProfile(dynamic userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_userType == null) {
        _error = 'Tipo de usuario no definido para actualizar perfil.';
        return _error;
      }

      if (_userType == Constants.adminType) {
        if (userData is! Usuario) {
          _error = 'Datos de usuario inválidos para actualización de administrador';
          return _error;
        }
        
        final apiResponse = await AuthService.updateAdminProfile(userData);

        if (apiResponse.success && apiResponse.data != null) {
          _currentUser = apiResponse.data as Usuario;
          await StorageService.saveUserData(_currentUser!.toJson());
          return null;
        } else {
          _error = apiResponse.message.isNotEmpty
              ? apiResponse.message
              : 'Error al actualizar perfil de administrador';
          return _error;
        }
      } else if (_userType == Constants.clientType) {
        if (userData is! Cliente) {
          _error = 'Datos de cliente inválidos para actualización';
          return _error;
        }
        
        final apiResponse = await AuthService.updateClientProfile(userData);

        if (apiResponse.success && apiResponse.data != null) {
          _currentClient = apiResponse.data as Cliente;
          await StorageService.saveUserData(_currentClient!.toJson());
          return null;
        } else {
          _error = apiResponse.message.isNotEmpty
              ? apiResponse.message
              : 'Error al actualizar perfil de cliente';
          return _error;
        }
      }

      _error = 'Tipo de usuario desconocido al actualizar perfil';
      return _error;
    } catch (e) {
      _error = e.toString().contains('Exception:')
          ? e.toString().replaceFirst('Exception:', '').trim()
          : 'Error al actualizar perfil';
      if (kDebugMode) {
        print('Error al actualizar perfil: $_error');
      }
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}