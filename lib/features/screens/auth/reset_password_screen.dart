import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String verificationCode;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.verificationCode,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
  });
}


  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'La contraseña debe contener al menos una letra minúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'La contraseña debe contener al menos un carácter especial';
    }
    return null;
  }

  Widget _buildPasswordRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showSuccessAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green[400], size: 24),
            const SizedBox(width: 8),
            const Text('¡Éxito!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
              'Continuar',
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

  void _showProcessingDialog() {
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
                'Guardando contraseña...',
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

  Future<void> _resetPassword() async {
  if (_formKey.currentState!.validate()) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final password = _passwordController.text.trim();

    // Mostrar cargando
    _showProcessingDialog();

    final errorMessage = await authProvider.resetPassword(
      widget.email,
      widget.verificationCode,
      password,
    );

    if (mounted) Navigator.of(context).pop(); // Cerrar loading

    if (!mounted) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isChangePassword = args?['isChangePassword'] ?? false;

    if (errorMessage == null) {
      _showSuccessAlert(
        isChangePassword
            ? 'Contraseña cambiada correctamente.'
            : 'Contraseña restablecida correctamente.',
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      // 🔒 Siempre cerrar sesión y mandar a login
      await authProvider.logout();

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } else {
      _showErrorAlert(errorMessage);
    }
  }
}

  void _onPopInvoked(bool didPop) async {
    if (didPop) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isChangePassword = args?['isChangePassword'] ?? false;

    if (isChangePassword) {
      // 🔧 Para cambio de contraseña, permitir regresar sin confirmación
      Navigator.of(context).pop();
      return;
    }

    // 🔧 Para reset de contraseña, mostrar confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cancelar cambio de contraseña?'),
        content: const Text('¿Estás seguro de que quieres cancelar el cambio de contraseña?'),
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
    );
    if (confirm == true) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isChangePassword = args?['isChangePassword'] ?? false;

    return PopScope(
      canPop: false,
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            isChangePassword ? 'Cambiar Contraseña' : 'Nueva Contraseña',
            style: const TextStyle(
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
                      // 🔧 Solo mostrar indicador de progreso si NO es cambio de contraseña
                      if (!isChangePassword) ...[
                        // Indicador de progreso
                        Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Row(
                            children: [
                              _buildProgressStep(1, true, 'Correo'),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: const Color(0xFFE91E63),
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                              _buildProgressStep(2, true, 'Código'),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: const Color(0xFFE91E63),
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                              _buildProgressStep(3, true, 'Nueva Contraseña'),
                            ],
                          ),
                        ),
                      ],

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
                            Icons.lock_open,
                            size: 40,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        isChangePassword ? 'Cambiar Contraseña' : 'Nueva Contraseña',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C2C2C),
                            ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        isChangePassword
                            ? 'Ingresa tu nueva contraseña'
                            : 'Ingresa tu nueva contraseña para ${widget.email}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 40),

                      // Campo de nueva contraseña
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Nueva Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFE91E63)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: _validatePassword,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campo de confirmar contraseña
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFE91E63)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Botón de guardar
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE91E63).withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Guardar Contraseña',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Texto informativo
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE4EC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE91E63).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFFE91E63),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Requisitos de contraseña:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFE91E63),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildPasswordRequirement('• Al menos 8 caracteres'),
                            _buildPasswordRequirement('• Una letra mayúscula'),
                            _buildPasswordRequirement('• Una letra minúscula'),
                            _buildPasswordRequirement('• Un número'),
                            _buildPasswordRequirement('• Un carácter especial (!@#\$%^&*...)'),
                          ],
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