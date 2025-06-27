import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../models/usuario.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _documentTypeController;
  late TextEditingController _documentNumberController;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    _nameController = TextEditingController(text: user?.nombre ?? '');
    _lastNameController = TextEditingController(text: user?.apellido ?? '');
    _emailController = TextEditingController(text: user?.correo ?? '');
    _documentTypeController = TextEditingController(text: user?.tipoDocumento ?? '');
    _documentNumberController = TextEditingController(text: user?.documento.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _documentTypeController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener la información del usuario.')),
        );
        return;
      }

      final updatedUserData = currentUser.copyWith(
        nombre: _nameController.text.trim(),
        apellido: _lastNameController.text.trim(),
        correo: _emailController.text.trim(),
        // Document type and number are typically not updated via profile edit
        // If they can be updated, you'll need to add fields for them
      ).toJson(); // Convertir a Map<String, dynamic>

      final errorMessage = await authProvider.updateUserProfile(updatedUserData);

      if (!mounted) return;

      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado exitosamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil (Administrador)')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          if (user == null && !authProvider.isLoading) {
            return const Center(child: Text('No se pudo cargar el perfil del administrador.'));
          }
          return LoadingWidget(
            isLoading: authProvider.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.account_circle, size: 100, color: Colors.grey),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Nombre',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Constants.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _lastNameController,
                      labelText: 'Apellido',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Constants.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
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
                      controller: _documentTypeController,
                      labelText: 'Tipo de Documento',
                      readOnly: true, // Typically not editable
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _documentNumberController,
                      labelText: 'Número de Documento',
                      readOnly: true, // Typically not editable
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      text: 'Actualizar Perfil',
                      onPressed: _updateProfile,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Cambiar Contraseña',
                      onPressed: () {
                        // Navegar a una pantalla de cambio de contraseña o mostrar un diálogo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de cambio de contraseña no implementada.')),
                        );
                      },
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