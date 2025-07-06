import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/General_models.dart';
import '../../../models/adicionModels.dart';
import '../../../models/Productconfiguration.dart';
import '../../../services/toppigYadiciones_services.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CatalogoAdicionesService _adicionesService = CatalogoAdicionesService();

  int quantity = 1;
  List<ProductConfiguration> productConfigurations = [];

  List<AdicionModel> adiciones = [];
  List<AdicionModel> toppings = [];
  List<AdicionModel> salsas = [];

  final Map<String, int> toppingLimits = {
    '9 oz': 1,
    '12 oz': 3,
    '16 oz': 5,
    '24 oz': 7,
  };

  final Map<String, int> salsaLimits = {
    '9 oz': 1,
    '12 oz': 2,
    '16 oz': 3,
    '24 oz': 3,
  };

  @override
  void initState() {
    super.initState();
    _initializeConfigurations();
    _cargarAdicionesDesdeApi();
  }

  void _initializeConfigurations() {
    productConfigurations = List.generate(
      quantity,
      (index) => ProductConfiguration(),
    );
  }

  Future<void> _cargarAdicionesDesdeApi() async {
    try {
      final todas = await _adicionesService.obtenerAdiciones();
      final activos = todas.where((a) => a.estado).toList();

      setState(() {
        adiciones = activos.where((a) => a.tipo == 'Adición').toList();
        toppings  = activos.where((a) => a.tipo == 'Topping').toList();
        salsas    = activos.where((a) => a.tipo == 'Salsa').toList();
      });
    } catch (e) {
      print('Error al cargar adiciones: $e');
    }
  }  @override
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
          widget.product.descripcion ?? '',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        _buildQuantitySelector(),
        const SizedBox(height: 16),
        ...List.generate(quantity, (index) => _buildProductConfiguration(index)),
        const SizedBox(height: 16),
        _buildPriceSummary(),
        const SizedBox(height: 16),
        _buildAddToCartBar(),
      ],
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
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () {
            if (quantity > 1) {
              setState(() {
                quantity--;
                productConfigurations.removeLast();
              });
            }
          },
        ),
        Text('$quantity', style: const TextStyle(fontSize: 18)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            setState(() {
              quantity++;
              productConfigurations.add(ProductConfiguration());
            });
          },
        ),
      ],
    );
  }  Widget _buildProductConfiguration(int index) {
    final config = productConfigurations[index];
    final sizeOptions = ['9 oz', '12 oz', '16 oz', '24 oz'];

    int maxToppings = toppingLimits[config.selectedSize] ?? 0;
    int maxSalsas   = salsaLimits[config.selectedSize] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Producto #${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

            const SizedBox(height: 10),

            _buildDropdown(
              'Tamaño',
              config.selectedSize,
              sizeOptions,
              (val) {
                setState(() {
                  config.selectedSize = val;
                  config.selectedToppings.clear();
                  config.selectedSalsas.clear();
                  config.selectedAdiciones.clear();
                });
              },
            ),

            const SizedBox(height: 10),

            Text('Puedes escoger hasta $maxToppings toppings:',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            _buildMultiDropdown(
              label: 'Toppings',
              options: toppings.map((t) => t.nombre).toList(),
              selectedValues: config.selectedToppings,
              max: maxToppings,
              config: config,
            ),

            const SizedBox(height: 10),

            Text('Puedes escoger hasta $maxSalsas salsas:',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            _buildMultiDropdown(
              label: 'Salsas',
              options: salsas.map((s) => s.nombre).toList(),
              selectedValues: config.selectedSalsas,
              max: maxSalsas,
              config: config,
            ),

            const SizedBox(height: 10),

            const Text('Puedes añadir hasta 10 adiciones (+\$1000 c/u):',
                style: TextStyle(fontWeight: FontWeight.w500)),
            _buildMultiDropdown(
              label: 'Adiciones (+\$1000 c/u)',
              options: adiciones.map((a) => a.nombre).toList(),
              selectedValues: config.selectedAdiciones,
              max: 10,
              config: config,
            ),
          ],
        ),
      ),
    );
  }  Widget _buildDropdown(String label, String currentValue, List<String> options,
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
        items: options.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: (val) => val != null ? onChanged(val) : null,
      ),
    );
  }

  Widget _buildMultiDropdown({
    required String label,
    required List<String> options,
    required List<String> selectedValues,
    required int max,
    required ProductConfiguration config,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: () => _showMultiSelectModal(
          label: label,
          options: options,
          selectedValues: selectedValues,
          max: max,
          config: config,
        ),
        child: InputDecorator(
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
          child: Text(
            selectedValues.isEmpty ? 'Selecciona opciones' : selectedValues.join(', '),
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ),
    );
  }

  void _showMultiSelectModal({
    required String label,
    required List<String> options,
    required List<String> selectedValues,
    required int max,
    required ProductConfiguration config,
  }) {
    List<String> tempSelected = List.from(selectedValues);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: options.map((option) {
                      final isSelected = tempSelected.contains(option);
                      return FilterChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              if (tempSelected.length < max) {
                                tempSelected.add(option);
                              }
                            } else {
                              tempSelected.remove(option);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedValues
                          ..clear()
                          ..addAll(tempSelected);
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Confirmar selección'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  double _getUnitPrice(ProductConfiguration config) {
    double basePrice;
    switch (config.selectedSize) {
      case '9 oz':
        basePrice = 7000;
        break;
      case '12 oz':
        basePrice = 12000;
        break;
      case '16 oz':
        basePrice = 16000;
        break;
      case '24 oz':
        basePrice = 20000;
        break;
      default:
        basePrice = 0;
    }

    return basePrice +
        (config.selectedToppings.length +
         config.selectedSalsas.length +
         config.selectedAdiciones.length) * 1000;
  }

  double get totalPrice {
    return productConfigurations.fold(
      0,
      (sum, config) => sum + _getUnitPrice(config),
    );
  }  Widget _buildPriceSummary() {
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
      color: Colors.pink[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total : \$${totalPrice.toStringAsFixed(0)}',
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

  void _handleAddToCart() {
    List<String> errors = [];

    for (int i = 0; i < productConfigurations.length; i++) {
      final config = productConfigurations[i];

      if (config.selectedSize.isEmpty) {
        errors.add('Producto ${i + 1}: Selecciona un tamaño');
      }
      if (config.selectedToppings.isEmpty) {
        errors.add('Producto ${i + 1}: Selecciona al menos 1 topping');
      }
      if (config.selectedSalsas.isEmpty) {
        errors.add('Producto ${i + 1}: Selecciona al menos 1 salsa');
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
                child: const Icon(Icons.error_outline, color: Colors.red, size: 30),
              ),
              const SizedBox(height: 16),
              const Text('Campos Requeridos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
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
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Entendido'),
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Producto añadido', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('El producto ha sido añadido exitosamente al carrito.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}