import 'package:flutter/material.dart';
import 'home_screen.dart'; // Importa tu pantalla original

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(), // Tu pantalla principal con categorías
    const Center(child: Text('Perfil')),
    const Center(child: Text('Usuarios')),
    const Center(child: Text('Productos')),
    const Center(child: Text('Pedidos')),
  ];

  void _onItemTapped(int index) {
    if (index == 5) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de cerrar sesión?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Sí, cerrar'),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cerrada')),
                );
              },
            ),
          ],
        ),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Usuarios'),
          BottomNavigationBarItem(icon: Icon(Icons.cake), label: 'Productos'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Cerrar'),
        ],
      ),
    );
  }
}
