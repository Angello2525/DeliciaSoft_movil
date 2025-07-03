import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Primero verificar que el usuario existe y obtener el tipo (puede ser "admin", "usuario" o "cliente")
    final userTypeFromBackend = await authProvider.checkUserType(email);

    if (!mounted) return;

    if (userTypeFromBackend == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El correo electrónico no está registrado en el sistema')),
      );
      return;
    }

    // Mapear admin → usuario para la API; cliente se mantiene
    String userTypeForApi;
    if (userTypeFromBackend == Constants.adminType) {
      userTypeForApi = "usuario";
    } else if (userTypeFromBackend == Constants.clientType) {
      userTypeForApi = "cliente";
    } else {
      // Fallback: si no es admin ni cliente, usamos el que venga
      userTypeForApi = userTypeFromBackend;
    }

    // Validar credenciales antes de enviar el código
    final loginResult = await authProvider.validateCredentials(email, password, userTypeForApi);

    if (!mounted) return;

    if (loginResult == null) {
      // Login correcto, ahora navegar a la verificación
      Navigator.of(context).pushNamed(
        AppRoutes.verification,
        arguments: {
          'email': email,
          'password': password,
          'userType': userTypeForApi,
          'isLogin': true,
        },
      );
    } else {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loginResult),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return LoadingWidget(
            isLoading: authProvider.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/logo.png', height: 120),
                    const SizedBox(height: 40),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Correo Electrónico',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Constants.requiredField;
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return Constants.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Contraseña',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Constants.requiredField;
                        }
                        if (value.length < 6) {
                          return Constants.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      text: 'Iniciar Sesión',
                      onPressed: _login,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
                      },
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.register);
                      },
                      child: const Text('¿No tienes una cuenta? Regístrate'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
