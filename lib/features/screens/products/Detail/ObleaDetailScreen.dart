import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/General_models.dart';
import '../../../services/cart_services.dart';
import '../../../models/cart_models.dart';

class ObleaDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ObleaDetailScreen({
    super.key,
    required this.product,
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

  @override
  void initState() {
    super.initState();
    _fetchAdiciones();
    _initializeConfigurationsWithProduct();
  }
  
  // Obtener precio del producto por nombre
  double _getPrecioProducto() {
    final nombre = widget.product.nombreProducto.toLowerCase();
    
    // Mapear según el nombre del producto
    if (nombre.contains('crema') && nombre.contains('mani')) {
      return 5000;
    } else if (nombre.contains('coco') && nombre.contains('leche')) {
      return 5200;
    } else if (nombre.contains('chocolate') && !nombre.contains('nutella')) {
      return 5500;
    } else if (nombre.contains('nutella')) {
      return 5500;
    } else if (nombre.contains('queso')) {
      return 6000;
    } else if (nombre.contains('arequipe')) {
      return 4500;
    }
    
    // Default
    return 4500;
  }
  ObleaDefaults _getDefaultsByPrice(double precio) {
    // Mapear según el precio que viene del producto
    if (precio >= 4000 && precio <= 4500) {
      return ObleaDefaults(
        precio: precio,
        ingredientesFijos: ['Arequipe'],
        ingredientesPersonalizables: {'Chispitas': 'Chispitas'},
      );
    } else if (precio >= 4900 && precio <= 5100) {
      return ObleaDefaults(
        precio: precio,
        ingredientesFijos: ['Crema', 'Maní'],
        ingredientesPersonalizables: {'Chispitas': 'Chispitas', 'Maní': 'Maní'},
      );
    } else if (precio >= 5100 && precio <= 5300) {
      return ObleaDefaults(
        precio: precio,
        ingredientesFijos: ['Coco', 'Leche Condensada'],
        ingredientesPersonalizables: {'Chispitas': 'Chispitas'},
      );
    } else if (precio >= 5400 && precio <= 5600) {
      return ObleaDefaults(
        precio: precio,
        ingredientesFijos: ['Chocolate', 'Arequipe'],
        ingredientesPersonalizables: {'Chips de Chocolate': 'Chips de Chocolate', 'Maní': 'Maní'},
      );
    } else if (precio >= 5900 && precio <= 6100) {
      return ObleaDefaults(
        precio: precio,
        ingredientesFijos: ['Arequipe', 'Queso', 'Crema de Leche'],
        ingredientesPersonalizables: {'Chispitas': 'Chispitas', 'Maní': 'Maní'},
      );
    }
    
    // Default si no coincide con ningún rango
    return ObleaDefaults(
      precio: precio,
      ingredientesFijos: ['Arequipe'],
      ingredientesPersonalizables: {'Chispitas': 'Chispitas'},
    );
  }
  
  void _initializeConfigurationsWithProduct() {
    // El nombre del producto ES el tipo de oblea (no se puede cambiar)
    String tipoObleaFijo = widget.product.nombreProducto;
    double precioProducto = _getPrecioProducto();
    
    print('🎯 Producto seleccionado: "$tipoObleaFijo"');
    print('💰 Precio del producto: \$precioProducto');
    
    obleaConfigurations = List.generate(
      quantity,
      (index) {
        final config = ObleaConfiguration();
        config.tipoOblea = tipoObleaFijo;
        
        // Obtener defaults según el precio
        final defaults = _getDefaultsByPrice(precioProducto);
        config.ingredientesPersonalizados.addAll(defaults.ingredientesPersonalizables);
        print('✅ Oblea ${index + 1} inicializada con ingredientes: ${defaults.ingredientesPersonalizables.keys}');
        
        return config;
      },
    );
  }

  Future<void> _fetchAdiciones() async {
    try {
      print('🌐 Iniciando petición a la API de adiciones...');
      final response = await http.get(
        Uri.parse('https://deliciasoft-backend-i6g9.onrender.com/api/catalogo-adiciones'),
      );

      print('📡 Respuesta recibida - Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (mounted) {
          setState(() {
            adiciones = (data as List)
                .map((json) => AdicionModel.fromJson(json))
                .toList();
            isLoadingAdiciones = false;
          });
          
          // Debug detallado
          print('✅ Adiciones cargadas: ${adiciones.length}');
          print('📊 Listado completo de adiciones:');
          for (var adicion in adiciones) {
            print('  - ID: ${adicion.idAdicion}, Nombre: "${adicion.nombreAdicion}", Tipo: "${adicion.tipo}", Precio: \$${adicion.precio}');
          }
          print('🏷️ Tipos únicos encontrados: ${adiciones.map((a) => '"${a.tipo}"').toSet().join(", ")}');
        }
      } else {
        throw Exception('Error al cargar adiciones: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error cargando adiciones: $e');
      if (mounted) {
        setState(() => isLoadingAdiciones = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar adiciones: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: _fetchAdiciones,
            ),
          ),
        );
      }
    }
  }

  List<String> _getOpcionesReemplazo(String ingredienteOriginal) {
    print('\n🔎 Buscando opciones de reemplazo para: "$ingredienteOriginal"');
    print('📊 Total de adiciones disponibles: ${adiciones.length}');
    
    if (adiciones.isEmpty) {
      print('⚠️ No hay adiciones cargadas todavía!');
      return [];
    }
    
    // TODAS las adiciones son válidas como toppings (SIN DUPLICADOS)
    final opciones = adiciones
        .where((adicion) => adicion.nombreAdicion.isNotEmpty)
        .map((adicion) => adicion.nombreAdicion)
        .toSet() // Eliminar duplicados
        .toList();
    
    print('📋 Total opciones encontradas: ${opciones.length}');
    print('🎯 Opciones: ${opciones.join(", ")}');
    
    if (opciones.isEmpty) {
      print('⚠️ NO SE ENCONTRARON TOPPINGS!');
    }
    
    return opciones;
  }

  double _getUnitPrice(ObleaConfiguration config) {
    if (config.tipoOblea.isEmpty) return 0;
    // Usar el precio del producto directamente
    return widget.product.precioProducto;
  }

  double get totalPrice {
    double total = 0;
    for (var config in obleaConfigurations) {
      total += _getUnitPrice(config);
    }
    return total;
  }

  void _handleAddToCart() async {
    final cartService = Provider.of<CartService>(context, listen: false);

    for (var config in obleaConfigurations) {
      config.precio = _getUnitPrice(config);
    }

    try {
      await cartService.addToCart(
        producto: widget.product,
        cantidad: quantity,
        configuraciones: obleaConfigurations,
      );

      _showSuccessAlert();
    } catch (e) {
      _showErrorAlert('Error al agregar al carrito: $e');
    }
  }

  void _resetForm() {
    setState(() {
      quantity = 1;
      _initializeConfigurationsWithProduct();
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
            final newConfig = ObleaConfiguration();
            newConfig.tipoOblea = widget.product.nombreProducto;
            final defaults = _getDefaultsByPrice(widget.product.precioProducto);
            newConfig.ingredientesPersonalizados.addAll(defaults.ingredientesPersonalizables);
            obleaConfigurations.add(newConfig);
          });
        }
      });
      return Container();
    }

    final config = obleaConfigurations[index];
    final defaults = _getDefaultsByPrice(widget.product.precioProducto);

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
            
            // Tipo de oblea FIJO (no editable)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.pinkAccent, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cookie, color: Colors.pinkAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tipo de Oblea',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          config.tipoOblea,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (defaults.ingredientesFijos.isNotEmpty) ...[
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

            if (defaults.ingredientesPersonalizables.isNotEmpty) ...[
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
    
    // Validar que el valor actual existe en las opciones disponibles
    final valorValido = (valorActual == ingredienteOriginal || opciones.contains(valorActual)) 
        ? valorActual 
        : ingredienteOriginal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cambiar $ingredienteOriginal:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pinkAccent.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: valorValido,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.pinkAccent),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                menuMaxHeight: 300, // LÍMITE DE ALTURA DEL MENÚ
                items: [
                  DropdownMenuItem(
                    value: ingredienteOriginal,
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$ingredienteOriginal (Original)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...opciones.map((opcion) =>
                      DropdownMenuItem(
                        value: opcion,
                        child: Row(
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              color: Colors.orange[700],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                opcion,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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
                  final newConfig = ObleaConfiguration();
                  newConfig.tipoOblea = widget.product.nombreProducto;
                  final defaults = _getDefaultsByPrice(widget.product.precioProducto);
                  newConfig.ingredientesPersonalizados.addAll(defaults.ingredientesPersonalizables);
                  obleaConfigurations.add(newConfig);
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
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('Añadir'),
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

  void _showSuccessAlert() {
    final String successMessage = 'Se ${quantity == 1 ? 'ha' : 'han'} añadido $quantity ${quantity == 1 ? 'oblea' : 'obleas'} al carrito';

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
              colors: [Colors.green[50]!, const Color.fromARGB(255, 230, 200, 227)],
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
      idAdicion: json['idadiciones'] ?? json['idAdicion'] ?? 0,
      nombreAdicion: json['nombre'] ?? json['nombreAdicion'] ?? '',
      tipo: json['nombre'] ?? json['tipo'] ?? 'Topping', // Usar nombre como tipo si no existe tipo
      precio: double.tryParse(json['precioadicion']?.toString() ?? json['precio']?.toString() ?? '0') ?? 0,
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