import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_models.dart';
import '../models/General_models.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  static const String _cartKey = 'shopping_cart';
  static const double _ivaRate = 0.19; // 19% IVA

  List<CartItem> _items = [];
  bool _isLoading = false;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  // Calculaciones
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.cantidad);
  
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);
  
  double get iva => subtotal * _ivaRate;
  
  double get total => subtotal + iva;

  Cart get cart => Cart(
    items: _items,
    subtotal: subtotal,
    iva: iva,
    total: total,
    cantidadTotal: totalQuantity,
  );

  // Inicializar carrito
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _loadCartFromStorage();
    } catch (e) {
      print('Error al inicializar carrito: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar item al carrito
  Future<void> addToCart({
    required ProductModel producto,
    required int cantidad,
    required List<ObleaConfiguration> configuraciones,
    Map<String, dynamic>? detallesPersonalizacion,
  }) async {
    try {
      // Calcular precio total basado en las configuraciones
      double precioTotal = 0.0;
      for (var config in configuraciones) {
        precioTotal += config.precio;
      }

      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        producto: producto,
        cantidad: cantidad,
        precioUnitario: precioTotal,
        subtotal: precioTotal * cantidad,
        configuraciones: configuraciones,
        fechaAgregado: DateTime.now(),
        detallesPersonalizacion: detallesPersonalizacion ?? {},
      );

      _items.add(cartItem);
      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      print('Error al agregar al carrito: $e');
      rethrow;
    }
  }

  // Actualizar cantidad de un item
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(itemId);
        return;
      }

      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final item = _items[index];
        _items[index] = item.copyWith(
          cantidad: newQuantity,
          subtotal: item.precioUnitario * newQuantity,
        );
        await _saveCartToStorage();
        notifyListeners();
      }
    } catch (e) {
      print('Error al actualizar cantidad: $e');
      rethrow;
    }
  }

  // Actualizar configuración de un item
  Future<void> updateConfiguration(String itemId, List<ObleaConfiguration> newConfigurations) async {
    try {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final item = _items[index];
        
        // Calcular nuevo precio basado en las configuraciones
        double nuevoPrecio = 0.0;
        for (var config in newConfigurations) {
          nuevoPrecio += config.precio;
        }

        _items[index] = item.copyWith(
          configuraciones: newConfigurations,
          precioUnitario: nuevoPrecio,
          subtotal: nuevoPrecio * item.cantidad,
        );
        
        await _saveCartToStorage();
        notifyListeners();
      }
    } catch (e) {
      print('Error al actualizar configuración: $e');
      rethrow;
    }
  }

  // Eliminar item del carrito
  Future<void> removeFromCart(String itemId) async {
    try {
      _items.removeWhere((item) => item.id == itemId);
      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      print('Error al eliminar del carrito: $e');
      rethrow;
    }
  }

  // Limpiar carrito
  Future<void> clearCart() async {
    try {
      _items.clear();
      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      print('Error al limpiar carrito: $e');
      rethrow;
    }
  }

  // Obtener item por ID
  CartItem? getItemById(String itemId) {
    try {
      return _items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // Verificar si un producto está en el carrito
  bool isProductInCart(int productId) {
    return _items.any((item) => item.producto.idProductoGeneral == productId);
  }

  // Obtener cantidad de un producto específico
  int getProductQuantity(int productId) {
    return _items
        .where((item) => item.producto.idProductoGeneral == productId)
        .fold(0, (sum, item) => sum + item.cantidad);
  }

  // Guardar carrito en SharedPreferences
  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error al guardar carrito: $e');
    }
  }

  // Cargar carrito desde SharedPreferences
  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> cartData = jsonDecode(cartJson);
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
        
        // Limpiar items inválidos o expirados (opcional)
        _items = _items.where((item) => _isValidCartItem(item)).toList();
        
        if (_items.isNotEmpty) {
          await _saveCartToStorage(); // Guardar carrito limpio
        }
      }
    } catch (e) {
      print('Error al cargar carrito: $e');
      _items = [];
    }
  }

  // Validar si un item del carrito es válido
  bool _isValidCartItem(CartItem item) {
    // Verificar que el item no sea muy antiguo (ejemplo: 7 días)
    final daysSinceAdded = DateTime.now().difference(item.fechaAgregado).inDays;
    if (daysSinceAdded > 7) {
      return false;
    }

    // Verificar que tenga configuraciones válidas
    if (item.configuraciones.isEmpty) {
      return false;
    }

    // Verificar que el precio sea válido
    if (item.precioUnitario <= 0 || item.subtotal <= 0) {
      return false;
    }

    return true;
  }

  // Método para debug
  void printCartSummary() {
    print('=== RESUMEN DEL CARRITO ===');
    print('Items: ${_items.length}');
    print('Cantidad total: $totalQuantity');
    print('Subtotal: \$${subtotal.toStringAsFixed(2)}');
    print('IVA: \$${iva.toStringAsFixed(2)}');
    print('Total: \$${total.toStringAsFixed(2)}');
    print('===========================');
  }

  // Obtener resumen para mostrar en UI
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': _items.length,
      'totalQuantity': totalQuantity,
      'subtotal': subtotal,
      'iva': iva,
      'total': total,
      'isEmpty': isEmpty,
    };
  }
}