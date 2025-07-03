import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final String? password;
  final String? userType;
  final bool isPasswordReset;
  final bool isLogin;

  const VerificationScreen({
    super.key,
    required this.email,
    this.password,
    this.userType,
    this.isPasswordReset = false,
    this.isLogin = false,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
void initState() {
  super.initState();
  // Enviar código automáticamente al inicializar la pantalla
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _sendInitialCode();
  });
}

Future<void> _sendInitialCode() async {
  if (widget.userType != null && !widget.isPasswordReset) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final response = await authProvider.sendVerificationCode(
      widget.email,
      widget.userType!,
    );

    if (mounted && response != null && response['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error enviando código inicial: ${response['error']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  void _showDebugInfo() {
  print('=== DEBUG VERIFICATION SCREEN ===');
  print('Email: ${widget.email}');
  print('UserType: ${widget.userType}');
  print('IsLogin: ${widget.isLogin}');
  print('IsPasswordReset: ${widget.isPasswordReset}');
  print('Password existe: ${widget.password != null}');
  print('Código ingresado: ${_codeController.text}');
  print('================================');
}

Future<void> _verifyCode() async {
  if (_formKey.currentState!.validate()) {
    _showDebugInfo();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final verificationCode = _codeController.text.trim();

    if (!mounted) return;

    String? errorMessage;

    if (widget.isLogin) {
      if (widget.password != null && widget.userType != null) {
        print('=== INICIANDO VERIFICACIÓN Y LOGIN ===');

        errorMessage = await authProvider.verifyCodeAndLogin(
          widget.email,
          widget.password!,
          widget.userType!,
          verificationCode,
        );

        if (!mounted) return;

        if (errorMessage == null && authProvider.isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(Constants.loginSuccess),
              backgroundColor: Colors.green,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 100));

          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(AppRoutes.homeNavigation);
        } else {
          final displayMessage = errorMessage ?? 'Error desconocido en la verificación';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(displayMessage), backgroundColor: Colors.red),
          );

          if (displayMessage.toLowerCase().contains('código') &&
              (displayMessage.toLowerCase().contains('inválido') ||
               displayMessage.toLowerCase().contains('expirado'))) {
            _codeController.clear();
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error interno: faltan datos para el inicio de sesión.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (widget.isPasswordReset) {
      // Nuevo: revisamos si venimos desde cambio de contraseña
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final isChangePassword = args?['isChangePassword'] ?? false;

      if (isChangePassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código validado. Ingresa tu nueva contraseña...')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código validado. Redirigiendo para restablecer contraseña...')),
        );
      }

      if (!mounted) return;
     Navigator.of(context).pushNamed(
      AppRoutes.resetPassword,
      arguments: {
        'email': widget.email,
        'verificationCode': verificationCode,
        'isChangePassword': isChangePassword,
        'userType': widget.userType, // pasa el tipo de usuario!
      },
    );


    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flujo de verificación no manejado para registro u otros casos.')),
      );
    }
  }
}


 Future<void> _resendCode() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  if (!mounted) return;

  if (widget.userType != null) {
    final response = await authProvider.sendVerificationCode(
      widget.email,
      widget.userType!,
    );

    if (!mounted) return;

    if (response != null && response['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código reenviado exitosamente')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se puede reenviar el código: tipo de usuario no definido.')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isLogin
            ? 'Verificar Login'
            : widget.isPasswordReset
                ? 'Restablecer Contraseña'
                : 'Verificar Correo'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // El LoadingWidget se activará/desactivará automáticamente
          // si los métodos de authProvider (como verifyCodeAndLogin, sendVerificationCode)
          // actualizan la propiedad 'isLoading' de AuthProvider.
          return LoadingWidget(
            isLoading: authProvider.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Se ha enviado un código de verificación a ${widget.email}. Por favor, ingrésalo a continuación.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 30),
                   CustomTextField(
                      controller: _codeController,
                      labelText: 'Código de Verificación',
                      keyboardType: TextInputType.number,
                      maxLength: 6, 
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return Constants.requiredField;
                          }
                          final trimmedValue = value.trim();
                          if (trimmedValue.length != 6) {
                            return 'El código debe tener exactamente 6 dígitos';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(trimmedValue)) {
                            return 'El código debe contener solo números';
                          }
                          return null;
                        },
                    ),

                    const SizedBox(height: 30),
                    CustomButton(
                      text: widget.isLogin
                          ? 'Verificar y Entrar'
                          : widget.isPasswordReset
                              ? 'Verificar Código'
                              : 'Verificar',
                      onPressed: _verifyCode,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _resendCode,
                      child: const Text('¿No recibiste el código? Reenviar'),
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
