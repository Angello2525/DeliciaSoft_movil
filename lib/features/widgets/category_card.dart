// Importa el paquete base de Flutter para poder usar widgets como Container, Text, etc.
import 'package:flutter/material.dart';

// Clase que representa una tarjeta de categoría individual
class CategoryCard extends StatelessWidget {
  // Título que se mostrará debajo del ícono
  final String title;

  // URL de la imagen o ícono que se mostrará
  final String imageUrl;

  // Función que se ejecuta cuando el usuario toca la tarjeta
  final VoidCallback onTap;

  // Constructor para inicializar la tarjeta con los datos necesarios
  const CategoryCard({
    required this.title,       // título de la categoría
    required this.imageUrl,    // imagen/icono de la categoría
    required this.onTap,       // función que se ejecuta al tocar
    super.key,                 // clave opcional para identificación del widget
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Detecta el toque en la tarjeta y ejecuta la función onTap
      onTap: onTap,

      // Contenedor principal de la tarjeta
      child: Container(
        // Decoración del contenedor: color, bordes y sombra
        decoration: BoxDecoration(
          color: Colors.white,                    // color de fondo blanco
          borderRadius: BorderRadius.circular(16),// bordes redondeados
          boxShadow: const [                      // sombra suave
            BoxShadow(
              color: Colors.black12,              // color de la sombra
              blurRadius: 8,                      // desenfoque de la sombra
              offset: Offset(2, 4),               // dirección de la sombra
            ),
          ],
        ),

        // Espaciado interno (padding) de la tarjeta
        padding: const EdgeInsets.all(12),

        // Organiza el contenido en una columna vertical
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // centra verticalmente
          children: [
            // Imagen redondeada (ícono o ilustración de la categoría)
            ClipRRect(
              borderRadius: BorderRadius.circular(50), // forma circular
              child: Image.network(
                imageUrl,        // URL de la imagen a mostrar
                height: 60,      // alto de la imagen
                width: 0,       // ancho corregido (antes estaba en 0)
                fit: BoxFit.cover, // cómo encajar la imagen
              ),
            ),

            // Espaciado entre la imagen y el texto
            const SizedBox(height: 12),

            // Texto que representa el título de la categoría
            Text(
              title,                        // texto a mostrar
              textAlign: TextAlign.center,  // alineación centrada
              style: const TextStyle(
                fontWeight: FontWeight.w600, // peso del texto (semi negrita)
                fontSize: 14,                // tamaño de fuente
              ),
            ),
          ],
        ),
      ),
    );
  }
}
