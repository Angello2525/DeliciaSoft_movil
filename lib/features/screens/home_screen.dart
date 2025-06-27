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
      imageUrl: "https://cdn0.recetasgratis.net/es/posts/5/6/3/postre_dulce_con_fresas_47365_600_square.jpg", 
    ),
    Category(
      title: "Obleas",
      imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQJdzsqQ1-H38WviqPwc3G-VejdZMXYdHYZhg&s", 
    ),
    Category(
      title: "Tortas",
      imageUrl: "https://images.unsplash.com/photo-1578985545062-69928b1d9587", 
    ),
    Category(
      title: "Postres",
      imageUrl: "https://i.blogs.es/e90432/vasitos/450_1000.jpg", 
    ),
    Category(
      title: "Mini Donas",
      imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSDnwct0mRhag-39CMD2wpajrIBeAC99R_Yng&s",
    ),
    Category(
      title: "Cupcakes",
      imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTuiczKbyAE9tByw7ylrBP78SVtrbaCyjFuWg&s",
    ),
    Category(
      title: "Arroz con leche",
      imageUrl: "https://www.recetasnestle.com.pe/sites/default/files/styles/recipe_detail_desktop_new/public/srh_recipes/6458c5dfff3606c63d0212a0b6b7a738.jpg?itok=f8CNJKSe", 
    ),
    Category(
      title: "Sandwiches",
      imageUrl: "https://www.recetasnestlecam.com/sites/default/files/srh_recipes/c5ad0cfe9d4beb9d633c9709113a1452.jpg",
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
