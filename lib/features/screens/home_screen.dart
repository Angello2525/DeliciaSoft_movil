import 'package:flutter/material.dart';
import '../models/category.dart';
import '../widgets/category_card.dart';
import 'fresa_screen.dart'; 
import 'oblea_screen.dart';
import 'tortas_screen.dart';


class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Category> categories = [
    Category(
      title: "Fresas con crema",
      imageUrl: "https://i.pinimg.com/736x/d7/b6/e9/d7b6e956da64a77e3ee67ab653df57a6.jpg",
    ),
    Category(
      title: "Obleas",
      imageUrl: "https://previews.123rf.com/images/lukpedclub/lukpedclub2104/lukpedclub210400223/167565331-wafer-icon-bakery-and-baking-related-vector-illustration.jpg",
    ),
    Category(
      title: "Tortas",
      imageUrl: "https://img.freepik.com/psd-gratis/delicioso-pastel-cumpleanos-chocolate-velas_632498-24980.jpg?uid=R202211906&ga=GA1.1.1880085198.1748478013&semt=ais_items_boosted&w=740",
    ),
    Category(
      title: "Postres",
      imageUrl: "https://cdn-icons-png.flaticon.com/256/7297/7297266.png",
    ),
    Category(
      title: "Mini Donas",
      imageUrl: "https://img.freepik.com/vector-gratis/vector-colorido-icono-rosquilla-rosa-aislado-sobre-fondo-blanco_134830-1096.jpg?semt=ais_hybrid&w=740",
    ),
    Category(
      title: "Cupcakes",
      imageUrl: "https://st4.depositphotos.com/18672748/20964/v/450/depositphotos_209642320-stock-illustration-cupcake-icon-vector-isolated-white.jpg",
    ),
    Category(
      title: "Arroz con leche",
      imageUrl: "https://cdn-icons-png.flaticon.com/512/2579/2579301.png",
    ),
    Category(
      title: "Sandwiches",
      imageUrl: "https://cdn-icons-png.flaticon.com/512/1046/1046784.png",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias Delicias Darsy'),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
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
            return CategoryCard(
              title: category.title,
              imageUrl: category.imageUrl,
              onTap: () {
                // Navega a la pantalla correspondiente según el título
                switch (category.title) {
                  case "Fresas con crema":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FresaScreen(categoryTitle: category.title),
                      ),
                    );
                    break;
                  case "Obleas":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ObleaScreen(categoryTitle: category.title),
                      ),
                    );
                    break;
                    case "Tortas":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            tortaScreen(categoryTitle: category.title),
                      ),
                    );
                    break;
                  // Aquí puedes seguir agregando más pantallas:
                  // case "Tortas":
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => TortaScreen(categoryTitle: category.title),
                  //     ),
                  //   );
                  //   break;
                  default:
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Pantalla para "${category.title}" aún no implementada.',
                        ),
                      ),
                    );
                }
              },
            );
          },
        ),
      ),
    );
  }
}