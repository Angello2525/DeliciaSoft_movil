import 'package:flutter/material.dart';
import '../../../models/product_model.dart';

class PostreDetailScreen extends StatefulWidget {
  final ProductModel product;

  const PostreDetailScreen({super.key, required this.product});

  @override
  State<PostreDetailScreen> createState() => _PostreDetailScreenState();
}

class _PostreDetailScreenState extends State<PostreDetailScreen> {
  int quantity = 1;
  
  List<PostreConfiguration> postreConfigurations = [];

  // Sabores disponibles para cada tipo de postre
  final Map<String, List<String>> saboresDisponibles = {
    'Gelatina (\$2000)': ['Fresa', 'Uva', 'Limón', 'Naranja', 'Cereza'],
    'Flan (\$3000)': ['Vainilla', 'Caramelo', 'Chocolate', 'Coco'],
    'Mousse (\$4000)': ['Chocolate', 'Fresa', 'Maracuyá', 'Limón'],
    'Tiramisú (\$5000)': ['Tradicional', 'Chocolate', 'Frutos Rojos'],
    'Cheesecake (\$6000)': ['Frutos Rojos', 'Maracuyá', 'Chocolate', 'Natural'],
  };

  // Precios de cada tipo de postre
  final Map<String, PostreDefaults> postreDefaults = {
    'Gelatina (\$2000)': PostreDefaults(
      precio: 2000,
      descripcion: 'Gelatina refrescante y deliciosa',
      saboresDisponibles: ['Fresa', 'Uva', 'Limón', 'Naranja', 'Cereza'],
    ),
    'Flan (\$3000)': PostreDefaults(
      precio: 3000,
      descripcion: 'Flan cremoso con textura suave',
      saboresDisponibles: ['Vainilla', 'Caramelo', 'Chocolate', 'Coco'],
    ),
    'Mousse (\$4000)': PostreDefaults(
      precio: 4000,
      descripcion: 'Mousse ligero y esponjoso',
      saboresDisponibles: ['Chocolate', 'Fresa', 'Maracuyá', 'Limón'],
    ),
    'Tiramisú (\$5000)': PostreDefaults(
      precio: 5000,
      descripcion: 'Tiramisú italiano auténtico',
      saboresDisponibles: ['Tradicional', 'Chocolate', 'Frutos Rojos'],
    ),
    'Cheesecake (\$6000)': PostreDefaults(
      precio: 6000,
      descripcion: 'Cheesecake cremoso con base de galleta',
      saboresDisponibles: ['Frutos Rojos', 'Maracuyá', 'Chocolate', 'Natural'],
    ),
  };

  final List<String> tiposPostre = [
    'Gelatina (\$2000)',
    'Flan (\$3000)',
    'Mousse (\$4000)',
    'Tiramisú (\$5000)',
    'Cheesecake (\$6000)',
  ];

  @override
  void initState() {
    super.initState();
    _initializeConfigurations();
  }

  void _initializeConfigurations() {
    postreConfigurations = List.generate(
      quantity, 
      (index) => PostreConfiguration()
    );
  }

  double _getUnitPrice(PostreConfiguration config) {
    if (config.tipoPostre.isEmpty) return 0;
    
    final defaults = postreDefaults[config.tipoPostre];
    return defaults?.precio ?? 0;
  }

  double get totalPrice {
    double total = 0;
    for (var config in postreConfigurations) {
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
        
        ...List.generate(quantity, (index) => _buildPostreConfiguration(index)),
        
        const SizedBox(height: 16),
        _buildPriceSummary(),
        const SizedBox(height: 16),
        _buildAddToCartBar(),
      ],
    );
  }

  Widget _buildPostreConfiguration(int index) {
    if (index >= postreConfigurations.length) return Container();
    
    final config = postreConfigurations[index];
    final defaults = config.tipoPostre.isNotEmpty ? postreDefaults[config.tipoPostre] : null;
    
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
              'Postre ${index + 1}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 12),

            _buildDropdown(
              'Tipo de Postre',
              config.tipoPostre,
              tiposPostre,
              (val) {
                setState(() {
                  config.tipoPostre = val;
                  config.sabor = ''; // Reset sabor when changing type
                });
              },
            ),
            
            // Mostrar descripción del postre
            if (defaults != null) ...[
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
                      'Descripción:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      defaults.descripcion,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Selector de sabor
            if (config.tipoPostre.isNotEmpty && defaults != null) ...[
              const SizedBox(height: 12),
              _buildDropdown(
                'Sabor',
                config.sabor,
                defaults.saboresDisponibles,
                (val) {
                  setState(() {
                    config.sabor = val;
                  });
                },
              ),
            ],

            // Mostrar sabores disponibles
            if (config.tipoPostre.isNotEmpty && defaults != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sabores disponibles:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: defaults.saboresDisponibles.map((sabor) => 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: config.sabor == sabor ? Colors.purple[200] : Colors.purple[100],
                            borderRadius: BorderRadius.circular(12),
                            border: config.sabor == sabor ? Border.all(color: Colors.purple[400]!, width: 2) : null,
                          ),
                          child: Text(
                            sabor,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: config.sabor == sabor ? FontWeight.bold : FontWeight.w500,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 8),
            if (config.tipoPostre.isNotEmpty)
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
              const Icon(Icons.cake, size: 100, color: Colors.pinkAccent),
        ),
      ),
    );
  }

  Widget _buildMainQuantitySelector() {
    return Column(
      children: [
        const Text(
          'Cantidad de Postres:',
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
                    postreConfigurations.removeLast();
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
                '$quantity ${quantity == 1 ? 'Postre' : 'Postres'}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                setState(() {
                  quantity++;
                  postreConfigurations.add(PostreConfiguration());
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
    
    for (int i = 0; i < postreConfigurations.length; i++) {
      final config = postreConfigurations[i];
      
      if (config.tipoPostre.isEmpty) {
        errors.add('Postre ${i + 1}: Selecciona un tipo de postre');
      }
      
      if (config.sabor.isEmpty) {
        errors.add('Postre ${i + 1}: Selecciona un sabor');
      }
    }
    
    if (errors.isNotEmpty) {
      _showValidationAlert(errors);
      return;
    }

    // Aquí agregarías los postres al carrito.
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
                'Se ${quantity == 1 ? 'ha' : 'han'} añadido $quantity ${quantity == 1 ? 'postre' : 'postres'} al carrito',
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
      postreConfigurations = [PostreConfiguration()];
    });
  }
}

class PostreConfiguration {
  String tipoPostre = '';
  String sabor = '';
  
  PostreConfiguration();
}

class PostreDefaults {
  final double precio;
  final String descripcion;
  final List<String> saboresDisponibles;
  
  PostreDefaults({
    required this.precio,
    required this.descripcion,
    required this.saboresDisponibles,
  });
}