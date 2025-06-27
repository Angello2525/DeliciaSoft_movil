import 'package:flutter/material.dart';

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
      'imagen': 'https://www.recetasnestle.com.co/sites/default/files/styles/recipe_detail_desktop/public/srh_recipes/e6de12b75d2c3839a9a902d389c8d75f.jpg',
    },
    {
      'nombre': 'Fresas con crema y mango',
      'imagen': 'https://cdn7.kiwilimon.com/recetaimagen/18858/960x640/37184.jpg.webp',
    },
    {
      'nombre': 'Fresas con crema y banano',
      'imagen': 'https://cdn7.kiwilimon.com/recetaimagen/18858/960x640/37184.jpg.webp',
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

  Widget buildCard(Map<String, String> producto) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(30, 0, 0, 0),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                producto['imagen']!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              producto['nombre']!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F6),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Seleccionaste: ${widget.categoryTitle}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar en ${widget.categoryTitle.toLowerCase()}...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🧁 Grid de productos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
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
