import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/General_models.dart' as GeneralModels;

class DonasDetailScreen extends StatefulWidget {
  final GeneralModels.ProductModel product;

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

  List<String> toppingsDisponibles = [];
  final List<String> salsasDisponibles = [
    'Fresa',
    'Mora',
    'Chocolate',
    'Lecherita',
    'Crema de leche',
    'Chocolate derretido',
  ];

  bool cargandoToppings = false;

  @override
  void initState() {
    super.initState();
    _inicializarCombos();
    _cargarToppingsDesdeAPI();
  }

  void _inicializarCombos() {
    donasConfig.clear();
    for (int i = 0; i < cantidadCombos; i++) {
      donasConfig.add(DonaComboConfiguration());
    }
  }

  Future<void> _cargarToppingsDesdeAPI() async {
    setState(() => cargandoToppings = true);
    try {
      final resp = await http.get(Uri.parse('https://deliciasoft-backend-i6g9.onrender.com/api/catalogo-adiciones'));
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        toppingsDisponibles = data
            .where((e) => e['estado'] == true)
            .map<String>((e) => e['nombre'].toString())
            .toList();
      } else {
        print('Error al cargar toppings: ${resp.statusCode}');
      }
    } catch (e) {
      print('Error al conectar toppings: $e');
    } finally {
      setState(() => cargandoToppings = false);
    }
  }

  double _precioTotal() {
    return donasConfig.fold<double>(
        0,
        (prev, cfg) =>
            prev + (comboDefaults[cfg.tipoCombo]?.precio ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            if (cargandoToppings)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: Colors.pinkAccent),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProductImage(),
                    const SizedBox(height: 12),
                  Text(
                    'Personaliza tu combo de mini donas',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),
                    _buildComboQuantitySelector(),
                    const SizedBox(height: 20),
                    ...List.generate(cantidadCombos, (i) => _buildDonaCombo(i)),
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

  Widget _buildAppBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.pinkAccent,
        child: Row(
          children: [
            IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.product.nombreProducto ?? 'Producto',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(width: 48),
          ],
        ),
      );

  Widget _buildProductImage() => Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(widget.product.urlImg ?? '',
              height: 200, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
            return const Icon(Icons.donut_small,
                size: 100, color: Colors.pinkAccent);
          }),
        ),
      );

  Widget _buildDonaCombo(int index) {
    final config = donasConfig[index];
    final defaults = comboDefaults[config.tipoCombo];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Combo ${index + 1}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: _dropdownDecoration('Tipo de combo'),
            value: config.tipoCombo.isEmpty ? null : config.tipoCombo,
            items: tiposCombo
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (val) {
              config.tipoCombo = val!;
              config.toppingsSeleccionados.clear();
              config.salsaSeleccionada = '';
              setState(() {});
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
                  Text('Precio: \$${defaults.precio.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green)),
                  Text('${defaults.maxToppings} toppings máx.',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          fontSize: 14)),
                ])
        ]),
      ),
    );
  }

  Widget _buildToppingsSelector(DonaComboConfiguration cfg, DonaComboDefaults df) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Selecciona tus toppings:',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: toppingsDisponibles.map((t) {
            final sel = cfg.toppingsSeleccionados.contains(t);
            final lim = cfg.toppingsSeleccionados.length >= df.maxToppings && !sel;
            return FilterChip(
              selected: sel,
              label: Text(t),
              onSelected: lim
                  ? null
                  : (v) {
                      setState(() {
                        if (v) cfg.toppingsSeleccionados.add(t);
                        else cfg.toppingsSeleccionados.remove(t);
                      });
                    },
              selectedColor: Colors.pinkAccent.withOpacity(0.2),
              backgroundColor: Colors.grey[100],
              checkmarkColor: Colors.pinkAccent,
            );
          }).toList(),
        ),
      ]);

  Widget _buildSalsaSelector(DonaComboConfiguration cfg) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Deseas alguna salsa o crema?',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            decoration: _dropdownDecoration('Selecciona una opción'),
            value:
                cfg.salsaSeleccionada.isEmpty ? null : cfg.salsaSeleccionada,
            items: salsasDisponibles
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              cfg.salsaSeleccionada = v!;
              setState(() {});
            },
          ),
        ],
      );

  InputDecoration _dropdownDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  Widget _buildComboQuantitySelector() => Column(children: [
        const Text('¿Cuántos combos quieres?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              onPressed: () {
                if (cantidadCombos > 1) {
                  setState(() {
                    cantidadCombos--;
                    donasConfig.removeLast();
                  });
                }
              },
              icon: const Icon(Icons.remove_circle_outline)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.pink[100], borderRadius: BorderRadius.circular(12)),
            child: Text('$cantidadCombos ${cantidadCombos == 1 ? 'Combo' : 'Combos'}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  cantidadCombos++;
                  donasConfig.add(DonaComboConfiguration());
                });
              },
              icon: const Icon(Icons.add_circle_outline)),
        ])
      ]);

  Widget _buildTotalResumen() => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color.fromARGB(20, 0, 0, 0),
                blurRadius: 6,
                offset: Offset(0, 3)),
          ],
        ),
        child: Text('Total: \$${_precioTotal().toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _buildAddToCartBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
            color: Colors.pink[100], borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total: \$${_precioTotal().toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          GestureDetector(
            onTap: _handleAddToCart,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
                  ]),
              child: const Icon(Icons.add_shopping_cart_rounded,
                  color: Colors.white, size: 26),
            ),
          )
        ]),
      );

  void _handleAddToCart() {
    final errores = <String>[];
    for (int i = 0; i < donasConfig.length; i++) {
      if (donasConfig[i].tipoCombo.isEmpty) {
        errores.add('Combo ${i + 1}: Debes elegir un tipo de combo.');
      }
    }
    if (errores.isNotEmpty) {
      _showValidationAlert(errores);
    } else {
      _showSuccessAlert();
    }
  }

  void _showValidationAlert(List<String> errores) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Campos Requeridos'),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: errores.map((e) => Text('• $e')).toList()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'))
        ],
      ),
    );
  }

  void _showSuccessAlert() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¡Éxito!'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
              'Se ${cantidadCombos == 1 ? 'ha' : 'han'} añadido $cantidadCombos ${cantidadCombos == 1 ? 'combo' : 'combos'} al carrito.'),
          const SizedBox(height: 8),
          Text('Total: \$${_precioTotal().toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetFormulario();
              },
              child: const Text('Seguir comprando')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Volver al inicio'),
          )
        ],
      ),
    );
  }

  void _resetFormulario() {
    setState(() {
      cantidadCombos = 1;
      donasConfig
        ..clear()
        ..add(DonaComboConfiguration());
    });
  }
}

class DonaComboDefaults {
  final double precio;
  final int maxToppings;

  DonaComboDefaults({required this.precio, required this.maxToppings});
}

class DonaComboConfiguration {
  String tipoCombo = '';
  List<String> toppingsSeleccionados = [];
  String salsaSeleccionada = '';
}