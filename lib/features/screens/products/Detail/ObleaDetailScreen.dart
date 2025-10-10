import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/General_models.dart';
import '../../../services/cart_services.dart';
import '../../../models/cart_models.dart';
import '../../../models/ProductConfiguration.dart';

class ObleaDetailScreen extends StatefulWidget {
  final ProductModel product;
  final CartItem? existingCartItem;

  const ObleaDetailScreen({
    super.key,
    required this.product,
    this.existingCartItem,
  });

  @override
  State<ObleaDetailScreen> createState() => _ObleaDetailScreenState();
}

class _ObleaDetailScreenState extends State<ObleaDetailScreen> {
  int quantity = 1;
  List<ObleaConfiguration> obleaConfigurations = [];
  
  // Datos de la API
  List<AdicionModel> adiciones = [];
  bool isLoadingAdiciones = true;

  final Map<String, ObleaDefaults> obleaDefaults = {
    'Oblea Sencilla (\$3000)': ObleaDefaults(
      precio: 3000,
      ingredientesFijos: ['Arequipe'],
      ingredientesPersonalizables: {'Chispitas': 'Chispitas'},
    ),
    'Oblea clasica (\$6000)': ObleaDefaults(
      precio: 6000,
      ingredientesFijos: ['Oreo', 'Arequipe', 'Queso', 'Crema de Leche'],
      ingredientesPersonalizables: {'Chips de Chocolate': 'Chips de Chocolate'},
    ),
    'Oblea grande (\$7000)': ObleaDefaults(
      precio: 7000,
      ingredientesFijos: ['Oreo', 'Arequipe', 'Queso', 'Crema de Leche'],
      ingredientesPersonalizables: {
        'Chips de Chocolate': 'Chips de Chocolate',
        'Maní': 'Maní'
      },
    ),
    'Oblea de la casa (\$8000)': ObleaDefaults(
      precio: 8000,
      ingredientesFijos: ['Oreo', 'Arequipe', 'Queso', 'Crema de Leche', 'Fresa'],
      ingredientesPersonalizables: {
        'Chips de Chocolate': 'Chips de Chocolate',
        'Maní': 'Maní'
      },
    ),
    'Oblea Premium (\$9000)': ObleaDefaults(
      precio: 9000,
      ingredientesFijos: ['Oreo', 'Arequipe', 'Queso', 'Crema de Leche', 'Fresa', 'Durazno'],
      ingredientesPersonalizables: {
        'Chips de Chocolate': 'Chips de Chocolate',
        'Maní': 'Maní'
      },
    ),
  };

  final List<String> tiposOblea = [
    'Oblea Sencilla (\$3000)',
    'Oblea clasica (\$6000)',
    'Oblea grande (\$7000)',
    'Oblea de la casa (\$8000)',
    'Oblea Premium (\$9000)',
  ];

  @override
  void initState() {
    super.initState();
    _fetchAdiciones();
    
    if (widget.existingCartItem != null) {
      quantity = widget.existingCartItem!.cantidad;
      obleaConfigurations = widget.existingCartItem!.configuraciones.map((cartObleaConfig) {
        return ObleaConfiguration(
          tipoOblea: cartObleaConfig.tipoOblea,
          ingredientesPersonalizados: Map<String, String>.from(cartObleaConfig.ingredientesPersonalizados),
          precio: cartObleaConfig.precio,
        );
      }).toList();
    } else {
      _initializeConfigurations();
    }
  }

  Future<void> _fetchAdiciones() async {
    try {
      final response = await http.get(
        Uri.parse('https://deliciasoft-backend-i6g9.onrender.com/api/catalogo-adiciones'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            adiciones = (data as List)
                .map((json) => AdicionModel.fromJson(json))
                .toList();
            isLoadingAdiciones = false;
          });
        }
      } else {
        throw Exception('Error al cargar adiciones');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingAdiciones = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar adiciones: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  List<String> _getOpcionesReemplazo(String ingredienteOriginal) {
    // Retornar TODOS los toppings disponibles desde la API
    return adiciones
        .where((adicion) => adicion.tipo == 'Topping')
        .map((adicion) => adicion.nombreAdicion)
        .toList();
  }

  void _initializeConfigurations() {
    obleaConfigurations = List.generate(
      quantity,
      (index) => ObleaConfiguration(),
    );
  }

  double _getUnitPrice(ObleaConfiguration config) {
    if (config.tipoOblea.isEmpty) return 0;
    final defaults = obleaDefaults[config.tipoOblea];
    return defaults?.precio ?? 0;
  }

  double get totalPrice {
    double total = 0;
    for (var config in obleaConfigurations) {
      total += _getUnitPrice(config);
    }
    return total;
  }

  void _handleAddToCart() async {
    List<String> errors = [];
    for (int i = 0; i < obleaConfigurations.length; i++) {
      final config = obleaConfigurations[i];
      if (config.tipoOblea.isEmpty) {
        errors.add('Oblea ${i + 1}: Selecciona un tipo de oblea');
      }
    }

    if (errors.isNotEmpty) {
      _showValidationAlert(errors);
      return;
    }

    final cartService = Provider.of<CartService>(context, listen: false);

    for (var config in obleaConfigurations) {
      config.precio = _getUnitPrice(config);
    }

    try {
      if (widget.existingCartItem != null) {
        await cartService.updateQuantity(widget.existingCartItem!.id, quantity);
        await cartService.updateConfiguration(widget.existingCartItem!.id, obleaConfigurations);
      } else {
        await cartService.addToCart(
          producto: widget.product,
          cantidad: quantity,
          configuraciones: obleaConfigurations,
        );
      }

      _showSuccessAlert();
    } catch (e) {
      _showErrorAlert('Error al agregar al carrito: $e');
    }
  }

  void _resetForm() {
    setState(() {
      quantity = 1;
      obleaConfigurations = [ObleaConfiguration()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            if (isLoadingAdiciones)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(
                  color: Colors.pinkAccent,
                  backgroundColor: Colors.pink,
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildFormContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.pinkAccent,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.product.nombreProducto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProductImage(),
        const SizedBox(height: 12),
        Text(
          widget.product.descripcion ?? 'Producto sin descripción',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        _buildMainQuantitySelector(),
        const SizedBox(height: 16),
        ...List.generate(quantity, (index) => _buildObleaConfiguration(index)),
        const SizedBox(height: 16),
        _buildPriceSummary(),
        const SizedBox(height: 16),
        _buildAddToCartBar(),
      ],
    );
  }

  Widget _buildObleaConfiguration(int index) {
    if (index >= obleaConfigurations.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && index >= obleaConfigurations.length) {
          setState(() {
            obleaConfigurations.add(ObleaConfiguration());
          });
        }
      });
      return Container();
    }

    final config = obleaConfigurations[index];
    final defaults = config.tipoOblea.isNotEmpty ? obleaDefaults[config.tipoOblea] : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Oblea ${index + 1}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              'Tipo de Oblea',
              config.tipoOblea,
              tiposOblea,
              (val) {
                setState(() {
                  config.tipoOblea = val;
                  config.ingredientesPersonalizados.clear();
                  final newDefaults = obleaDefaults[val];
                  if (newDefaults != null) {
                    config.ingredientesPersonalizados.addAll(newDefaults.ingredientesPersonalizables);
                  }
                });
              },
            ),

            if (defaults != null && defaults.ingredientesFijos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ingredientes incluidos:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: defaults.ingredientesFijos.map((ingrediente) =>
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ingrediente,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ],

            if (config.tipoOblea.isNotEmpty && defaults != null && defaults.ingredientesPersonalizables.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Personalización disponible:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              const SizedBox(height: 8),
              if (isLoadingAdiciones)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      color: Colors.pinkAccent,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else
                ...defaults.ingredientesPersonalizables.keys.map((ingrediente) =>
                    _buildIngredientePersonalizable(config, ingrediente),
                ).toList(),
            ],

            const SizedBox(height: 8),
            if (config.tipoOblea.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Precio: \$${_getUnitPrice(config).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Precio Fijo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientePersonalizable(ObleaConfiguration config, String ingredienteOriginal) {
    final opciones = _getOpcionesReemplazo(ingredienteOriginal);
    final valorActual = config.ingredientesPersonalizados[ingredienteOriginal] ?? ingredienteOriginal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Cambiar $ingredienteOriginal por:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: valorActual,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: [
                    DropdownMenuItem(
                      value: ingredienteOriginal,
                      child: Text('$ingredienteOriginal (Original)'),
                    ),
                    ...opciones.map((opcion) =>
                        DropdownMenuItem(
                          value: opcion,
                          child: Text(opcion),
                        ),
                    ).toList(),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        config.ingredientesPersonalizados[ingredienteOriginal] = val;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          widget.product.urlImg ?? '',
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.cookie, size: 100, color: Colors.pinkAccent),
        ),
      ),
    );
  }

  Widget _buildMainQuantitySelector() {
    return Column(
      children: [
        const Text(
          'Número de Obleas:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                if (quantity > 1) {
                  setState(() {
                    quantity--;
                    obleaConfigurations.removeLast();
                  });
                }
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$quantity ${quantity == 1 ? 'Oblea' : 'Obleas'}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                setState(() {
                  quantity++;
                  obleaConfigurations.add(ObleaConfiguration());
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'Total: \$${totalPrice.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAddToCartBar() {
    final bool isEditing = widget.existingCartItem != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.pink[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: \$${totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color.fromARGB(255, 175, 76, 119)),
          ),
          ElevatedButton.icon(
            onPressed: _handleAddToCart,
            icon: Icon(isEditing ? Icons.check_rounded : Icons.add_shopping_cart_rounded),
            label: Text(isEditing ? 'Actualizar' : 'Añadir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String currentValue, List<String> options,
      Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: currentValue.isEmpty ? null : currentValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: options
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (val) => val != null ? onChanged(val) : null,
      ),
    );
  }

  void _showValidationAlert(List<String> errors) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.red[50]!, Colors.red[100]!],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red[600],
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Campos Requeridos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    children: errors
                        .map((error) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(error)),
                        ],
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessAlert() {
    final bool isEditing = widget.existingCartItem != null;
    final String successMessage = isEditing
        ? 'Se ha actualizado la oblea en el carrito'
        : 'Se ${quantity == 1 ? 'ha' : 'han'} añadido $quantity ${quantity == 1 ? 'oblea' : 'obleas'} al carrito';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.green[50]!, const Color.fromARGB(255, 230, 200, 227)!],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color.fromARGB(255, 160, 67, 112),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEditing ? '¡Actualizado!' : '¡Éxito!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 175, 76, 137),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                successMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: \$${totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 175, 76, 122),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (!isEditing) {
                        _resetForm();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 175, 76, 119),
                      side: const BorderSide(color: Color.fromARGB(255, 175, 76, 140)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Seguir comprando'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 175, 76, 130),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Volver al inicio'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Modelo para las adiciones desde la API
class AdicionModel {
  final int idAdicion;
  final String nombreAdicion;
  final String tipo;
  final double precio;

  AdicionModel({
    required this.idAdicion,
    required this.nombreAdicion,
    required this.tipo,
    required this.precio,
  });

  factory AdicionModel.fromJson(Map<String, dynamic> json) {
    return AdicionModel(
      idAdicion: json['idAdicion'] ?? 0,
      nombreAdicion: json['nombreAdicion'] ?? '',
      tipo: json['tipo'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
    );
  }
}

class ObleaDefaults {
  final double precio;
  final List<String> ingredientesFijos;
  final Map<String, String> ingredientesPersonalizables;

  ObleaDefaults({
    required this.precio,
    required this.ingredientesFijos,
    required this.ingredientesPersonalizables,
  });
}