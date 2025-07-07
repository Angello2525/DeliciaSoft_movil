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

  // Estados para controlar qué secciones están expandidas
  bool _personalInfoExpanded = true;
  bool _documentInfoExpanded = false;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores vacíos
    _nameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _documentTypeController = TextEditingController();
    _documentNumberController = TextEditingController();
    
    // Cargar datos frescos desde la API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadProfileFromApi();
    
    // Actualizar controladores con los datos frescos
    final user = authProvider.currentUser;
    if (user != null) {
      _nameController.text = user.nombre;
      _lastNameController.text = user.apellido;
      _emailController.text = user.correo;
      _documentTypeController.text = user.tipoDocumento;
      _documentNumberController.text = user.documento.toString();
    }
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

  // REEMPLAZAR el método _updateProfile en admin_profile.dart
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

    // ✅ Incluir TODOS los campos editables
    final updatedUser = currentUser.copyWith(
      nombre: _nameController.text.trim(),
      apellido: _lastNameController.text.trim(),
      correo: _emailController.text.trim(),
      tipoDocumento: _documentTypeController.text.trim(),
       documento: int.tryParse(_documentNumberController.text.trim()) ?? 0,
    );

    final errorMessage = await authProvider.updateProfile(updatedUser);

    if (!mounted) return;

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // Regresar con éxito
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.pink[100],
        foregroundColor: Colors.pink[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          return LoadingWidget(
            isLoading: authProvider.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header compacto con avatar y información
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink[200]!, Colors.pink[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar más pequeño
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.pink[300],
                            child: Icon(
                              Icons.admin_panel_settings,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Información del perfil
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Perfil de Administrador',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.pink[50],
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.pink[300]!),
                                  ),
                                  child: Text(
                                    'ADMINISTRADOR',
                                    style: TextStyle(
                                      color: Colors.pink[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Acordeón - Información Personal
                    _buildAccordionSection(
                      title: '👤 Información Personal',
                      isExpanded: _personalInfoExpanded,
                      onToggle: () => setState(() => _personalInfoExpanded = !_personalInfoExpanded),
                      children: [
                        _buildCustomTextField(
                          controller: _nameController,
                          labelText: 'Nombre',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Constants.requiredField;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildCustomTextField(
                          controller: _lastNameController,
                          labelText: 'Apellido',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Constants.requiredField;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildCustomTextField(
                          controller: _emailController,
                          labelText: 'Correo Electrónico',
                          icon: Icons.email_outlined,
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
                      ],
                    ),

                    // Acordeón - Documento
                    _buildAccordionSection(
                      title: '📄 Documento de Identidad',
                      isExpanded: _documentInfoExpanded,
                      onToggle: () => setState(() => _documentInfoExpanded = !_documentInfoExpanded),
                      children: [
                        _buildCustomTextField(
                          controller: _documentTypeController,
                          labelText: 'Tipo de Documento',
                          icon: Icons.assignment_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Constants.requiredField;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildCustomTextField(
                          controller: _documentNumberController,
                          labelText: 'Número de Documento',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Constants.requiredField;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Botones
                    _buildGradientButton(
                      text: 'Actualizar Perfil',
                      onPressed: _updateProfile,
                      icon: Icons.save_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildOutlineButton(
                      text: 'Cambiar Contraseña',
                      onPressed: () {
                        Navigator.of(context).pushNamed('/change-password');
                      },
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header del acordeón
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[700],
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: isExpanded ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.pink[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Contenido expandible
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isExpanded ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: children,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.pink[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.pink[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.pink[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.pink[400]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.pink[600]),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink[400]!, Colors.pink[600]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pink[400]!, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.pink[600]),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.pink[600],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}