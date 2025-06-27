import 'package:flutter/material.dart';
import '../features/screens/home_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomeScreen(),
};
