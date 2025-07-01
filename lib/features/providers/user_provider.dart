// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../models/cliente.dart';
import '../models/rol.dart';
import '../models/rol_permiso.dart'; // Asegúrate de importar esto si lo usas
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/api_response.dart';
import '../services/auth_service.dart'; // Importa AuthService para acceder al token y a los métodos de admin

class UserProvider with ChangeNotifier {
  List<Usuario> _usuarios = [];
  List<Cliente> _clientes = [];
  List<Rol> _roles = [];
  List<RolPermiso> _permisos = []; // Si gestionas permisos directamente aquí
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Usuario> get usuarios => _usuarios;
  List<Cliente> get clientes => _clientes;
  List<Rol> get roles => _roles;
  List<RolPermiso> get permisos => _permisos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Cargar usuarios
  Future<void> loadUsuarios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        _error = 'Token de autenticación no encontrado.';
        notifyListeners();
        return;
      }

      final response = await ApiService.getAllUsers(token); // Usar el método correcto del ApiService
      if (response.success && response.data != null) {
        _usuarios = response.data as List<Usuario>; // Asegúrate que el tipo sea correcto
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception:', '').trim() : 'Error al cargar usuarios';
      if (kDebugMode) {
        print('Error en loadUsuarios: $_error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar clientes
  Future<void> loadClientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        _error = 'Token de autenticación no encontrado.';
        notifyListeners();
        return;
      }

      final response = await ApiService.getAllClients(token); // Usar el método correcto del ApiService
      if (response.success && response.data != null) {
        _clientes = response.data as List<Cliente>; // Asegúrate que el tipo sea correcto
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception:', '').trim() : 'Error al cargar clientes';
      if (kDebugMode) {
        print('Error en loadClientes: $_error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar roles
  Future<void> loadRoles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        _error = 'Token de autenticación no encontrado.';
        notifyListeners();
        return;
      }

      final response = await ApiService.getAllRoles(token);
      if (response.success && response.data != null) {
        _roles = response.data as List<Rol>;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception:', '').trim() : 'Error al cargar roles';
      if (kDebugMode) {
        print('Error en loadRoles: $_error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar usuario (campos distintos al estado)
  Future<String?> updateUsuario(Usuario usuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // El token se obtiene dentro de AuthService, ya que AuthService se encarga de la comunicación con la API para actualización de perfiles
      final apiResponse = await AuthService.updateAdminProfile(usuario);

      if (apiResponse.success && apiResponse.data != null) {
        // Encuentra y reemplaza el usuario en la lista
        _usuarios = _usuarios.map((u) => u.idUsuario == usuario.idUsuario ? (apiResponse.data as Usuario) : u).toList();
        return null; // No error
      } else {
        _error = apiResponse.message.isNotEmpty ? apiResponse.message : 'Error al actualizar usuario';
        return _error;
      }
    } catch (e) {
      _error = e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception:', '').trim() : 'Error al actualizar usuario';
      if (kDebugMode) {
        print('Error en updateUsuario: $_error');
      }
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar cliente (campos distintos al estado)
  Future<String?> updateCliente(Cliente cliente) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // El token se obtiene dentro de AuthService, ya que AuthService se encarga de la comunicación con la API para actualización de perfiles
      final apiResponse = await AuthService.updateClientProfile(cliente);

      if (apiResponse.success && apiResponse.data != null) {
        // Encuentra y reemplaza el cliente en la lista
        _clientes = _clientes.map((c) => c.idCliente == cliente.idCliente ? (apiResponse.data as Cliente) : c).toList();
        return null; // No error
      } else {
        _error = apiResponse.message.isNotEmpty ? apiResponse.message : 'Error al actualizar cliente';
        return _error;
      }
    } catch (e) {
      _error = e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception:', '').trim() : 'Error al actualizar cliente';
      if (kDebugMode) {
        print('Error en updateCliente: $_error');
      }
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();

    }
  }

  

  // Cambiar estado de usuario (activar/desactivar)
  Future<String?> toggleUsuarioStatus(int idUsuario, bool currentStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        _error = 'Token no encontrado.';
        return _error;
      }
      final apiResponse = await ApiService.updateUsuarioStatus(token, idUsuario, !currentStatus);
      if (apiResponse.success) {
        final index = _usuarios.indexWhere((u) => u.idUsuario == idUsuario);
        if (index != -1) {
          _usuarios[index] = _usuarios[index].copyWith(estado: !currentStatus);
        }
        return null;
      } else {
        _error = apiResponse.message;
        return _error;
      }
    } catch (e) {
      _error = e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception:', '').trim() : 'Error al cambiar estado de usuario';
      print('Error en UserProvider toggleUsuarioStatus: $_error');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> toggleClientStatus(int idCliente, bool currentStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        _error = 'Token no encontrado.';
        return _error;
      }
      final apiResponse = await ApiService.updateClientStatus(token, idCliente, !currentStatus);
      if (apiResponse.success) {
        final index = _clientes.indexWhere((c) => c.idCliente == idCliente);
        if (index != -1) {
          _clientes[index] = _clientes[index].copyWith(estado: !currentStatus);
        }
        return null;
      } else {
        _error = apiResponse.message;
        return _error;
      }
    } catch (e) {
      _error = e.toString().contains('Exception:') ? e.toString().replaceFirst('Exception:', '').trim() : 'Error al cambiar estado de cliente';
      print('Error en UserProvider toggleClientStatus: $_error');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}