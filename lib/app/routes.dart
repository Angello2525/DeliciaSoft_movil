import 'package:flutter/material.dart';
import '../features/screens/products/home_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomeScreen(),
};
