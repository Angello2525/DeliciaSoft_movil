import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class CupcakeDetailScreen extends StatefulWidget {
  final ProductModel product;

  const CupcakeDetailScreen({super.key, required this.product});

  @override
  State<CupcakeDetailScreen> createState() => _CupcakeDetailScreenState();
}

class _CupcakeDetailScreenState extends State<CupcakeDetailScreen> {
  String relleno = '';
  String topping = '';
  String cobertura = '';
  int cantidad = 1;

  List<String> rellenosDisponibles = [];
List<String> toppingsDisponibles = [];


  final List<String> coberturasDisponibles = [
    'Crema de leche',
    'Crema chantilly',
    'Cobertura de chocolate',
  ];

  double _precioTotal() => cantidad * 5000;

  void _resetFormulario() {
    setState(() {
      relleno = '';
      topping = '';
      cobertura = '';
      cantidad = 1;
    });
  }

  @override
void initState() {
  super.initState();
  _cargarDatosDesdeAPI(); // 👈 Llamar la carga de API aquí
}


Future<void> _cargarDatosDesdeAPI() async {
  try {
    final rellenoResponse = await http.get(Uri.parse('http://deliciasoft.somee.com/api/CatalogoRellenoes'));
    final toppingResponse = await http.get(Uri.parse('http://deliciasoft.somee.com/api/CatalogoAdiciones'));

    if (rellenoResponse.statusCode == 200 && toppingResponse.statusCode == 200) {
      final List<dynamic> rellenoData = json.decode(rellenoResponse.body);
      final List<dynamic> toppingData = json.decode(toppingResponse.body);

      setState(() {
        rellenosDisponibles = rellenoData.map<String>((e) => e['nombre'].toString()).toList();
        toppingsDisponibles = toppingData.map<String>((e) => e['nombre'].toString()).toList();
      });
    } else {
      debugPrint('Error en respuestas: ${rellenoResponse.statusCode} / ${toppingResponse.statusCode}');
    }
  } catch (e) {
    debugPrint('Error al cargar datos desde API: $e');
  }
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
                    _buildImagenProducto(),
                    const SizedBox(height: 12),
                    Text(
                      widget.product.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    _buildCantidadSelector(),
                    const SizedBox(height: 20),
                    _buildDropdown('Relleno', rellenosDisponibles, relleno,
                        (val) => setState(() => relleno = val!)),
                    const SizedBox(height: 20),
                    _buildDropdown('Topping', toppingsDisponibles, topping,
                        (val) => setState(() => topping = val!)),
                    const SizedBox(height: 20),
                    _buildDropdown('Cobertura', coberturasDisponibles, cobertura,
                        (val) => setState(() => cobertura = val!)),
                    const SizedBox(height: 20),
                    _buildResumenTotal(),
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

  Widget _buildImagenProducto() {
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

  Widget _buildCantidadSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Cuántos cupcakes quieres?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                if (cantidad > 1) {
                  setState(() => cantidad--);
                }
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$cantidad ${cantidad == 1 ? 'Cupcake' : 'Cupcakes'}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => cantidad++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue.isEmpty ? null : selectedValue,
      decoration: _dropdownDecoration(label),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
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

  Widget _buildResumenTotal() {
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
              child: const Icon(
                Icons.add_shopping_cart_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart() {
    List<String> errores = [];

    if (relleno.isEmpty) errores.add('Selecciona un relleno');
    if (topping.isEmpty) errores.add('Selecciona un topping');
    if (cobertura.isEmpty) errores.add('Selecciona una cobertura');

    if (errores.isNotEmpty) {
      _showValidationAlert(errores);
    } else {
      _showSuccessAlert();
    }
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
      backgroundColor: const Color(0xFFFFF1F6), 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 60, color: Colors.green),
            const SizedBox(height: 10),
            const Text(
              '¡Éxito!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Se ${cantidad == 1 ? 'ha' : 'han'} añadido $cantidad ${cantidad == 1 ? 'cupcake' : 'cupcakes'} al carrito.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${_precioTotal().toStringAsFixed(0)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _resetFormulario();
                  },
                  child: const Text(
                    'Seguir comprando',
                    style: TextStyle(color: Colors.pinkAccent),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Volver al inicio',
                    style: TextStyle(color: Colors.pinkAccent),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}}