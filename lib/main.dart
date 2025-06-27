import 'package:delicias_darsy_movil/features/screens/home_navigation.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Postres App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const HomeNavigation(),
    );
  }
}
