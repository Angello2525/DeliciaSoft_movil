import 'package:flutter/material.dart';
import '../../../models/product_model.dart';

class DonasDetailScreen extends StatefulWidget {
  final ProductModel product;

  const DonasDetailScreen({super.key, required this.product});

  @override
  State<DonasDetailScreen> createState() => _DonasDetailScreenState();
}

class _DonasDetailScreenState extends State<DonasDetailScreen> {
  int cantidadCombos = 1;

  final List<DonaComboConfiguration> donasConfig = [];

  final List<String> tiposCombo = [
    'Combo 5 mini donas (\$7000)',
    'Combo 10 mini donas (\$12000)',
    'Combo 20 mini donas (\$22000)',
  ];

  final Map<String, DonaComboDefaults> comboDefaults = {
    'Combo 5 mini donas (\$7000)': DonaComboDefaults(precio: 7000, maxToppings: 3),
    'Combo 10 mini donas (\$12000)': DonaComboDefaults(precio: 12000, maxToppings: 5),
    'Combo 20 mini donas (\$22000)': DonaComboDefaults(precio: 22000, maxToppings: 7),
  };

  final List<String> toppingsDisponibles = [
    'Chispitas',
    'Galleta triturada',
    'Arequipe',
    'Oreo',
    'Maní',
    'Coco rallado',
    'Grajeas',
  ];

  final List<String> salsasDisponibles = [
    'Fresa',
    'Mora',
    'Chocolate',
    'Lecherita',
    'Crema de leche',
    'Chocolate derretido',
  ];

  @override
  void initState() {
    super.initState();
    _inicializarCombos();
  }

  void _inicializarCombos() {
    donasConfig.clear();
    for (int i = 0; i < cantidadCombos; i++) {
      donasConfig.add(DonaComboConfiguration());
    }
  }

  double _precioTotal() {
    double total = 0;
    for (var config in donasConfig) {
      final defaults = comboDefaults[config.tipoCombo];
      if (defaults != null) {
        total += defaults.precio;
      }
    }
    return total;
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
              const Icon(Icons.donut_small, size: 100, color: Colors.pinkAccent),
        ),
      ),
    );
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProductImage(),
                    const SizedBox(height: 12),
                    Text(
                      widget.product.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildComboQuantitySelector(),
                    const SizedBox(height: 20),
                    ...List.generate(cantidadCombos, (index) => _buildDonaCombo(index)),
                    const SizedBox(height: 12),
                    _buildTotalResumen(),
                    const SizedBox(height: 20),
                    _buildAddToCartBar(),
                  ],
                ),
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
    Widget _buildDonaCombo(int index) {
    if (index >= donasConfig.length) return Container();

    final config = donasConfig[index];
    final defaults = comboDefaults[config.tipoCombo];

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
              'Combo ${index + 1}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: config.tipoCombo.isEmpty ? null : config.tipoCombo,
              decoration: _dropdownDecoration('Tipo de combo'),
              items: tiposCombo
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    config.tipoCombo = val;
                    config.toppingsSeleccionados.clear();
                    config.salsaSeleccionada = '';
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            if (defaults != null) _buildToppingsSelector(config, defaults),
            const SizedBox(height: 16),
            _buildSalsaSelector(config),
            const SizedBox(height: 12),
            if (defaults != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Precio: \$${defaults.precio.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '${defaults.maxToppings} toppings máx.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
    Widget _buildToppingsSelector(DonaComboConfiguration config, DonaComboDefaults defaults) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona tus toppings:',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: toppingsDisponibles.map((topping) {
            final selected = config.toppingsSeleccionados.contains(topping);
            final limiteAlcanzado = config.toppingsSeleccionados.length >= defaults.maxToppings && !selected;

            return FilterChip(
              selected: selected,
              label: Text(topping),
              onSelected: limiteAlcanzado
                  ? null
                  : (val) {
                      setState(() {
                        if (val) {
                          config.toppingsSeleccionados.add(topping);
                        } else {
                          config.toppingsSeleccionados.remove(topping);
                        }
                      });
                    },
              selectedColor: Colors.pinkAccent.withOpacity(0.2),
              backgroundColor: Colors.grey[100],
              checkmarkColor: Colors.pinkAccent,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSalsaSelector(DonaComboConfiguration config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Deseas alguna salsa o crema?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: config.salsaSeleccionada.isEmpty ? null : config.salsaSeleccionada,
          decoration: _dropdownDecoration('Selecciona una opción'),
          items: salsasDisponibles
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                config.salsaSeleccionada = val;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildComboQuantitySelector() {
    return Column(
      children: [
        const Text(
          '¿Cuántos combos quieres?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                if (cantidadCombos > 1) {
                  setState(() {
                    cantidadCombos--;
                    donasConfig.removeLast();
                  });
                }
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$cantidadCombos ${cantidadCombos == 1 ? 'Combo' : 'Combos'}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  cantidadCombos++;
                  donasConfig.add(DonaComboConfiguration());
                });
              },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalResumen() {
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
        'Total: \$${_precioTotal().toStringAsFixed(0)}',
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
            'Total: \$${_precioTotal().toStringAsFixed(0)}',
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
    List<String> errores = [];

    for (int i = 0; i < donasConfig.length; i++) {
      final config = donasConfig[i];
      if (config.tipoCombo.isEmpty) {
        errores.add('Combo ${i + 1}: Debes elegir un tipo de combo.');
      }
    }

    if (errores.isNotEmpty) {
      _showValidationAlert(errores);
      return;
    }

    _showSuccessAlert();
  }

  void _showValidationAlert(List<String> errores) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Campos Requeridos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: errores.map((e) => Text('• $e')).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          )
        ],
      ),
    );
  }

  void _showSuccessAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Éxito!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Se ${cantidadCombos == 1 ? 'ha' : 'han'} añadido $cantidadCombos ${cantidadCombos == 1 ? 'combo' : 'combos'} al carrito.',
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${_precioTotal().toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetFormulario();
            },
            child: const Text('Seguir comprando'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    );
  }

  void _resetFormulario() {
    setState(() {
      cantidadCombos = 1;
      donasConfig.clear();
      donasConfig.add(DonaComboConfiguration());
    });
  }
}

class DonaComboDefaults {
  final double precio;
  final int maxToppings;

  DonaComboDefaults({
    required this.precio,
    required this.maxToppings,
  });
}

class DonaComboConfiguration {
  String tipoCombo = '';
  List<String> toppingsSeleccionados = [];
  String salsaSeleccionada = '';

  DonaComboConfiguration();
}