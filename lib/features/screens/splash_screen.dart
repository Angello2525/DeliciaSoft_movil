import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import './home_navigation.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

 Future<void> _checkAuthStatus() async {
  await Future.delayed(const Duration(seconds: 2));
  if (!mounted) return;

  // Puedes dejar esto si el AuthProvider hace algo necesario al iniciar
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  await authProvider.initialize();

  if (!mounted) return;


    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeNavigation()), 
    );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Puedes añadir un logo o un indicador de carga
            Image.asset('assets/logo.png', height: 150), // Asegúrate de tener un logo en assets
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Cargando...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}