import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/loading_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendVerificationCode();
    });
  }

  Future<void> _sendVerificationCode() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.currentUser?.correo;
    final userType = authProvider.userType?.toLowerCase(); 
    // 🔧 O si no tienes userType, usa:
    // final userType = authProvider.currentUser?.idRolNavigation?.rol1?.toLowerCase();

    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo obtener el correo del usuario.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    print('🔄 Enviando código de verificación para cambio de contraseña a: $userEmail');

    final errorMessage = await authProvider.forgotPassword(userEmail);

    if (!mounted) return;

    if (errorMessage == null) {
      print('✅ Código enviado correctamente para cambio de contraseña');
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.verification,
        arguments: {
          'email': userEmail,
          'isPasswordReset': true,
          'isChangePassword': true,
          'userType': userType, // ✅ pasamos el tipo de usuario para saber dónde ir después
        },
      );
    } else {
      print('⚠️ Error enviando código: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error enviando código: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userEmail = authProvider.currentUser?.correo ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
      ),
      body: LoadingWidget(
        isLoading: authProvider.isLoading,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 30),
              Text(
                'Enviando código de verificación',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Text(
                'Se está enviando un código de verificación a:\n$userEmail',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'Por favor espera mientras se envía el código...',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
