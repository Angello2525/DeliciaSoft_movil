import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/product_model.dart';

// Modelo para CatalogoAdiciones
class CatalogoAdicion {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final bool activo;

  CatalogoAdicion({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.activo,
  });

  factory CatalogoAdicion.fromJson(Map<String, dynamic> json) {
    return CatalogoAdicion(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] ?? 0.0).toDouble(),
      activo: json['activo'] ?? true,
    );
  }
}

class ObleaDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ObleaDetailScreen({super.key, required this.product});

  @override
  State<ObleaDetailScreen> createState() => _ObleaDetailScreenState();
}

class _ObleaDetailScreenState extends State<ObleaDetailScreen> {
  int quantity = 1;
  List<ObleaConfiguration> obleaConfigurations = [];
  List<CatalogoAdicion> toppingsDisponibles = [];
  bool isLoadingToppings = false;

  // Mantener la lógica original de obleas
  final Map<String, ObleaDefaults> obleaDefaults = {
    'Oblea Sencilla (\$300)': ObleaDefaults(
      precio: 300,
      ingredientesFijos: ['Arequipe'],
      ingredientesPersonalizablesOriginales: {'Chispitas': 'Chispitas'},
    ),
    'Oblea Premium (\$6000)': ObleaDefaults(
      precio: 6000,
      ingredientesFijos: ['Oreo', 'Arequipe', 'Queso', 'Crema de Leche'],
      ingredientesPersonalizablesOriginales: {'Chips de Chocolate': 'Chips de Chocolate'},
    ),
    'Oblea Premium (\$7000)': ObleaDefaults(
      precio: 7000,
      ingredientesFijos: ['Oreo', 'Arequipe', 'Queso', 'Crema de Leche'],
      ingredientesPersonalizablesOriginales: {
        'Chips de Chocolate': 'Chips de Chocolate',
        'Maní': 'Maní'
      },
    ),
    'Oblea Premium (\$8000)': ObleaDefaults(
      precio: 8000,
      ingredientesFijos: ['Oreo', 'Arequipe', 'Queso', 'Crema de Leche', 'Fresa'],
      ingredientesPersonalizablesOriginales: {
        'Chips de Chocolate': 'Chips de Chocolate',
        'Maní': 'Maní'
      },
    ),
    'Oblea Premium (\$9000)': ObleaDefaults(
      precio: 9000,
      ingredientesFijos: ['Oreo', 'Arequipe', 'Queso', 'Crema de Leche', 'Fresa', 'Durazno'],
      ingredientesPersonalizablesOriginales: {
        'Chips de Chocolate': 'Chips de Chocolate',
        'Maní': 'Maní'
      },
    ),
  };

  final List<String> tiposOblea = [
    'Oblea Sencilla (\$300)',
    'Oblea clasica (\$6000)',
    'Oblea grande (\$7000)',
    'Oblea de la casa (\$8000)',
    'Oblea Premium (\$9000)',
  ];

  @override
  void initState() {
    super.initState();
    _initializeConfigurations();
    _loadToppingsFromAPI();
  }

  // Método para cargar toppings desde la API
  Future<void> _loadToppingsFromAPI() async {
    setState(() {
      isLoadingToppings = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://deliciasoft.somee.com/api/CatalogoAdiciones'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          // Solo usar los toppings que vienen de la API y están activos
          toppingsDisponibles = data
              .map((item) => CatalogoAdicion.fromJson(item))
              .where((topping) => topping.activo)
              .toList();
        });
        
        print('Toppings cargados desde API: ${toppingsDisponibles.length}');
        for (var topping in toppingsDisponibles) {
          print('- ${topping.nombre} (ID: ${topping.id})');
        }
      } else {
        print('Error al cargar toppings: ${response.statusCode}');
        print('Response body: ${response.body}');
        _useFallbackToppings();
      }
    } catch (e) {
      print('Error de conexión: $e');
      _useFallbackToppings();
    } finally {
      setState(() {
        isLoadingToppings = false;
      });
    }
  }

  void _useFallbackToppings() {
    // En caso de error con la API, mantener la lista vacía
    // y mostrar mensaje de error al usuario
    setState(() {
      toppingsDisponibles = [];
    });
    
    // Mostrar mensaje de error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error al cargar los toppings. Intenta nuevamente.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _initializeConfigurations() {
    obleaConfigurations = List.generate(
      quantity, 
      (index) => ObleaConfiguration()
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            if (isLoadingToppings)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.pinkAccent),
                    SizedBox(width: 12),
                    Text('Cargando toppings...', style: TextStyle(color: Colors.pinkAccent)),
                  ],
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
              widget.product.title,
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
          widget.product.description,
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
    if (index >= obleaConfigurations.length) return Container();
    
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
                  if (defaults != null) {
                    config.ingredientesPersonalizados.addAll(defaults.ingredientesPersonalizablesOriginales);
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
            
            if (config.tipoOblea.isNotEmpty && defaults != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Personalización disponible:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              const SizedBox(height: 8),
              ...defaults.ingredientesPersonalizablesOriginales.keys.map((ingrediente) => 
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
    // Usar solo los toppings que vienen de la API
    final opcionesFromAPI = toppingsDisponibles.map((t) => t.nombre).toList();
    final valorActual = config.ingredientesPersonalizados[ingredienteOriginal] ?? ingredienteOriginal;
    
    // Si no hay toppings disponibles, mostrar mensaje
    if (toppingsDisponibles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[600], size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'No se pudieron cargar los toppings disponibles',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
              TextButton(
                onPressed: _loadToppingsFromAPI,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    
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
                  value: opcionesFromAPI.contains(valorActual) ? valorActual : ingredienteOriginal,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: [
                    DropdownMenuItem(
                      value: ingredienteOriginal,
                      child: Text('$ingredienteOriginal (Original)'),
                    ),
                    ...opcionesFromAPI.where((opcion) => opcion != ingredienteOriginal).map((opcion) => 
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
          widget.product.imageUrl,
          height: 200,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.pink[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: \$${totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          GestureDetector(
            onTap: _handleAddToCart,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 26),
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

  void _handleAddToCart() {
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

    _showSuccessAlert();
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
                child: Icon(
                  Icons.check_circle_outline,
                  color: const Color.fromARGB(255, 160, 67, 112),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Éxito!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 175, 76, 137),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Se ${quantity == 1 ? 'ha' : 'han'} añadido $quantity ${quantity == 1 ? 'oblea' : 'obleas'} al carrito',
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
                      _resetForm();
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

  void _resetForm() {
    setState(() {
      quantity = 1;
      obleaConfigurations = [ObleaConfiguration()];
    });
  }
}

class ObleaConfiguration {
  String tipoOblea = '';
  Map<String, String> ingredientesPersonalizados = {};
  
  ObleaConfiguration();
}

class ObleaDefaults {
  final double precio;
  final List<String> ingredientesFijos;
  final Map<String, String> ingredientesPersonalizablesOriginales;
  
  ObleaDefaults({
    required this.precio,
    required this.ingredientesFijos,
    required this.ingredientesPersonalizablesOriginales,
  });
}