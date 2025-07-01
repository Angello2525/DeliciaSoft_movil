import 'package:flutter/material.dart';
import 'Detail/ObleaDetailScreen.dart';
import '../../models/product_model.dart';

class ObleaScreen extends StatefulWidget {
  final String categoryTitle;

  const ObleaScreen({super.key, required this.categoryTitle});

  @override
  State<ObleaScreen> createState() => _ObleaScreenState();
}

class _ObleaScreenState extends State<ObleaScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> allProductos = [
    {
      'nombre': 'Oblea Tradicional',
      'imagen': 'https://i.pinimg.com/736x/f6/3d/4f/f63d4f58a292442b7c5f2793f5fba429.jpg',
      'descripcion': 'Deliciosa oblea tradicional con ingredientes frescos y la opción de personalizar algunos elementos.',
    },
    {
      'nombre': 'Oblea Especial',
      'imagen': 'https://i.pinimg.com/736x/04/d4/ba/04d4babf1381ce02336a0e315cf31e8d.jpg',
      'descripcion': 'Oblea especial con ingredientes premium y opciones de personalización limitada.',
    },
    {
      'nombre': 'Oblea de la Casa',
      'imagen': 'https://i.pinimg.com/736x/69/48/a3/6948a33d397ceae97eba36af7e050f16.jpg',
      'descripcion': 'Nuestra oblea insignia con la receta de la casa y posibilidad de cambiar algunos ingredientes.',
    },
    {
      'nombre': 'Oblea Grande',
      'imagen': 'https://i.pinimg.com/736x/6a/f0/87/6af087245db6a2089e6660f1c6290f74.jpg',
      'descripcion': 'Oblea de tamaño generoso perfecta para compartir, con opciones de personalización.',
    },
  ];

  List<Map<String, String>> filteredProductos = [];
  bool isLoading = false;

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
          final descripcion = producto['descripcion']?.toLowerCase() ?? '';
          return nombre.contains(query) || descripcion.contains(query);
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
    final descripcion = producto['descripcion'];
    final imagen = producto['imagen'];

    if (nombre == null || descripcion == null || imagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Datos del producto incompletos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final productModel = ProductModel(
        title: nombre,
        description: descripcion,
        imageUrl: imagen,
        price: 0.0,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ObleaDetailScreen(product: productModel),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al navegar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Icon(Icons.cookie, size: 50, color: Colors.pinkAccent),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(Icons.cookie, size: 50, color: Colors.pinkAccent),
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
                enabledBorder: OutlineInputBorder(
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
                    'Toca cualquier oblea para personalizarla',
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
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron obleas',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intenta con otro término de búsqueda',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
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