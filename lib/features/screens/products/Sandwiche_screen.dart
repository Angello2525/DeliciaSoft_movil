import 'package:flutter/material.dart';

class SandwicheScreen extends StatefulWidget {
  final String categoryTitle;

  const SandwicheScreen({super.key, required this.categoryTitle});

  @override
  State<SandwicheScreen> createState() => _SandwicheScreenState();
}

class _SandwicheScreenState extends State<SandwicheScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> allProductos = [
    {
      'nombre': 'Oblea Tradicional',
      'imagen': 'https://i.pinimg.com/736x/f6/3d/4f/f63d4f58a292442b7c5f2793f5fba429.jpg',
    },
    {
      'nombre': 'Oblea Especial',
      'imagen': 'https://i.pinimg.com/736x/04/d4/ba/04d4babf1381ce02336a0e315cf31e8d.jpg',
    },
    {
      'nombre': 'Oblea de la Casa',
      'imagen': 'https://i.pinimg.com/736x/69/48/a3/6948a33d397ceae97eba36af7e050f16.jpg',
    },
    {
      'nombre': 'Oblea Grande',
      'imagen': 'https://i.pinimg.com/736x/6a/f0/87/6af087245db6a2089e6660f1c6290f74.jpg',
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
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                producto['imagen']!,
                fit: BoxFit.cover,
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
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
