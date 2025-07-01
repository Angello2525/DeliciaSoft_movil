import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'Detail/product_detail_screen.dart';

class FresaScreen extends StatefulWidget {
  final String categoryTitle;

  const FresaScreen({super.key, required this.categoryTitle});

  @override
  State<FresaScreen> createState() => _FresaScreenState();
}

class _FresaScreenState extends State<FresaScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> allProductos = [
    {
      'nombre': 'Fresas con crema y durazno',
      'imagen': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQJRgaWK3KE0qSW4G-IfYopSJzneQX-qxm-zQ&s',
    },
    {
      'nombre': 'Fresas con crema y cereza',
      'imagen': 'https://i.pinimg.com/736x/b2/2f/23/b22f231315abb506e4dc9185492f3d22.jpg',
    },
    {
      'nombre': 'Fresas con crema y mango',
      'imagen': 'https://i.pinimg.com/736x/37/90/0a/37900a728ccd21cd8d0c1b573d2cad92.jpg',
    },
    {
      'nombre': 'Fresas con crema y banano',
      'imagen': 'https://i.pinimg.com/736x/fd/ff/fd/fdfffde65922346c40c3e60893f4d05d.jpg',
    },
  ];

  List<Map<String, String>> filteredProductos = [];

  @override
  void initState() {
    super.initState();
    filteredProductos = List.from(allProductos);
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredProductos = List.from(allProductos);
      } else {
        filteredProductos = allProductos.where((producto) {
          final nombre = producto['nombre']?.toLowerCase() ?? '';
          return nombre.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetail(Map<String, String> producto) {
    final nombre = producto['nombre'];
    final imagen = producto['imagen'];

    if (nombre == null || imagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Datos del producto incompletos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final productModel = ProductModel(
      title: nombre,
      description: 'Deliciosa combinación personalizada con fresas y toppings a tu gusto.',
      imageUrl: imagen,
      price: 3.5,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: productModel),
      ),
    );
  }

  Widget buildCard(Map<String, String> producto) {
    final nombre = producto['nombre'] ?? 'Sin nombre';
    final imagen = producto['imagen'] ?? '';

    return GestureDetector(
      onTap: () => _navigateToDetail(producto),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(30, 0, 0, 0),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: imagen.isNotEmpty
                    ? Image.network(
                        imagen,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 50, color: Colors.pinkAccent),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.pinkAccent),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'Personalizable',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.pinkAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F6),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Seleccionaste: ${widget.categoryTitle}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar en ${widget.categoryTitle.toLowerCase()}...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, child) {
                    return value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pink[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.pink[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Toca cualquier producto para personalizarlo',
                    style: TextStyle(
                      color: Colors.pink[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: filteredProductos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron resultados',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intenta con otro término de búsqueda',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredProductos.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        return buildCard(filteredProductos[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
