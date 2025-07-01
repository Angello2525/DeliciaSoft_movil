import 'package:flutter/material.dart';
import 'Detail/PostresDetailScreen.dart';
import '../../models/product_model.dart';

class PostreScreen extends StatefulWidget {
  final String categoryTitle;

  const PostreScreen({super.key, required this.categoryTitle});

  @override
  State<PostreScreen> createState() => _PostreScreenState();
}

class _PostreScreenState extends State<PostreScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> allProductos = [
    {
      'nombre': 'Gelatina Especial',
      'imagen': 'https://i.pinimg.com/736x/a1/83/d8/a183d8d4c60a681db2dd64c22186029f.jpg',
    },
    {
      'nombre': 'Flan Casero',
      'imagen': 'https://i.pinimg.com/736x/03/bf/b8/03bfb818f04409868fbaeb265596d80d.jpg',
    },
    {
      'nombre': 'Mousse Chocolate',
      'imagen': 'https://i.pinimg.com/736x/64/cb/90/64cb904dde46a244566e542d5730da0a.jpg',
    },
    {
      'nombre': 'Tiramisú Clásico',
      'imagen': 'https://i.pinimg.com/736x/48/75/21/487521cae96ca0103fb4caaa0b1efa28.jpg',
    },
  ];

  List<Map<String, String>> filteredProductos = [];

  @override
  void initState() {
    super.initState();
    filteredProductos = allProductos;

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredProductos = allProductos.where((producto) {
          return producto['nombre']!.toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  ProductModel _createProductModel(Map<String, String> producto) {
    return ProductModel(
      title: producto['nombre']!,
      description: 'Delicioso ${producto['nombre']!.toLowerCase()} personalizable con diferentes sabores y presentaciones.',
      imageUrl: producto['imagen']!,
      price: 0.0,
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB3BA),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Toca cualquier postre para personalizarlo',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(Map<String, String> producto) {
    return GestureDetector(
      onTap: () {
        final productModel = _createProductModel(producto);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostreDetailScreen(
              product: productModel,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4, 
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  producto['imagen']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(
                          Icons.cake,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2, 
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      producto['nombre']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Personalizable',
                        style: TextStyle(
                          color: Color(0xFFE91E63),
                          fontSize: 11, 
                          fontWeight: FontWeight.w500,
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
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
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
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar en ${widget.categoryTitle.toLowerCase()}...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          

          _buildInfoBanner(),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: filteredProductos.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
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