
import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../widgets/category_card.dart';
import '../../services/categoria_api_service.dart';
import 'package:provider/provider.dart'; 
import '../../services/cart_services.dart'; 
import '../cart_screen.dart'; 
import 'fresa_screen.dart';
import 'oblea_screen.dart';
import 'tortas_screen.dart';
import 'cupcake_screen.dart';
import 'minidona_screen.dart';
import 'postre_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Llamada futura a la API para obtener las categorías
  late Future<List<Category>> _futureCategorias;

  @override
  void initState() {
    super.initState();
    // Se llama el servicio GET desde la API de Somee para obtener las categorías
    _futureCategorias = CategoriaApiService().obtenerCategorias();
  }

  // Determina qué pantalla mostrar según el nombre de la categoría
  Widget? _getCategoryScreen(String title) {
    switch (title.toLowerCase()) {
      case "fresas con crema":
        return FresaScreen(categoryTitle: title);
      case "obleas":
        return ObleaScreen(categoryTitle: title);
      case "tortas":
        return TortasScreen(categoryTitle: title);
      case "cupcakes":
        return CupcakeScreen(categoryTitle: title);
      case "postres":
        return PostreScreen(categoryTitle: title);
      case "mini donas":
        return MinidonaScreen(categoryTitle: title);
      default:
        return null;
    }
  }

  // Asigna una imagen predeterminada según el nombre si no llega desde la API
  String _obtenerImagenRespaldo(String nombreCategoria) {
    final nombre = nombreCategoria.toLowerCase();
    if (nombre.contains('fresa')) {
      return 'https://res.cloudinary.com/dedsserh6/image/upload/fresas_gm4fex.jpg';
    } else if (nombre.contains('oblea')) {
      return 'https://res.cloudinary.com/dedsserh6/image/upload/obleas_ie5nia.jpg';
    } else if (nombre.contains('torta')) {
      return 'https://res.cloudinary.com/dedsserh6/image/upload/tortas_aiguxm.jpg';
    } else if (nombre.contains('postre')) {
      return 'https://res.cloudinary.com/dedsserh6/image/upload/postres_mq8dhl.jpg';
    } else if (nombre.contains('dona')) {
      return 'https://res.cloudinary.com/dedsserh6/image/upload/donas_rntqry.jpg';
    } else if (nombre.contains('cupcake')) {
      return 'https://res.cloudinary.com/dedsserh6/image/upload/cupcakes_ijcml2.jpg';
    } else {
      return 'https://i.imgur.com/ZOEa1Yy.png'; // Imagen genérica de respaldo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: const Text('Categorías de Productos'), // O el título que desees
        actions: [
          // Ícono del carrito con contador
          Consumer<CartService>(
            builder: (context, cartService, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      // Navega a la pantalla del carrito al tocar el icono
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  if (cartService.totalQuantity > 0) // Solo muestra el badge si hay ítems
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartService.totalQuantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder<List<Category>>(
        future: _futureCategorias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay categorías disponibles"));
          }

          final categories = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];

                // Imagen: usa la de la API si viene, si no, una por defecto
                final imageUrl = (category.urlImg?.isNotEmpty ?? false)
                    ? category.urlImg!
                    : _obtenerImagenRespaldo(category.nombreCategoria);

                return CategoryCard(
                  title: category.nombreCategoria,
                  imageUrl: imageUrl,
                  onTap: () {
                    final screen =
                        _getCategoryScreen(category.nombreCategoria);
                    if (screen != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => screen),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'No hay pantalla para "${category.nombreCategoria}".',
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}