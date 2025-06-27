import 'package:flutter/material.dart';

class tortaScreen extends StatelessWidget {
  final String categoryTitle;

  const tortaScreen({super.key, required this.categoryTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seleccionaste la categoría\n$categoryTitle',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text(
          'Aquí irán los productos de "$categoryTitle"',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
