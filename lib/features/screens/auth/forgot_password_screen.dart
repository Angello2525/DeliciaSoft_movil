import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text.trim();

      // Mostrar ventana de "Enviando código..."
      _showSendingDialog();

      // Pedimos el reset
      final errorMessage = await authProvider.forgotPassword(email);

      // Cerrar el diálogo de envío
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      if (errorMessage == null) {
        // Si todo salió bien, navegamos
        Navigator.of(context).pushNamed(
          AppRoutes.verification,
          arguments: {
            'email': email,
            'isPasswordReset': true,
          },
        );
      } else {
        // Mostrar alerta moderna de error
        _showErrorAlert(errorMessage);
      }
    }
  }

  void _showSendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
              ),
              const SizedBox(height: 16),
              Text(
                'Enviando código...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 24),
            const SizedBox(width: 8),
            const Text('Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cancelar recuperación?'),
        content: const Text('¿Estás seguro de que quieres cancelar la recuperación de contraseña?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFE91E63)),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
            title: const Text(
              'Recuperar Contraseña',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFFE91E63)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return LoadingWidget(
              isLoading: authProvider.isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                     Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Row(
                        children: [
                          _buildProgressStep(1, true, 'Correo'),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Colors.grey[300],
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                          _buildProgressStep(2, false, 'Código'),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Colors.grey[300],
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                          _buildProgressStep(3, false, 'Nueva Contraseña'),
                        ],
                      ),
                    ),

                      // Icono y título
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFCE4EC),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            size: 40,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Recuperar Contraseña',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Ingresa tu correo electrónico para enviarte un código de verificación',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),

                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Correo Electrónico',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
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
                      const SizedBox(height: 40),

                    CustomButton(
                        text: 'Enviar Código',
                        onPressed: _requestPasswordReset,
                      ),

                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            // Limpiar el campo de correo y enfocar
                            _emailController.clear();
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE91E63)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Correo incorrecto',
                            style: TextStyle(
                              color: Color(0xFFE91E63),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Volver al inicio de sesión',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressStep(int step, bool isActive, String label) {
  return Column(
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? const Color(0xFFE91E63) : Colors.grey[300],
        ),
        child: Center(
          child: Text(
            step.toString(),
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? const Color(0xFFE91E63) : Colors.grey[500],
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
        ),
      ],
    );
  }
}