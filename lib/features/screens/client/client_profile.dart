import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../models/cliente.dart';

class ClientProfile extends StatefulWidget {
  const ClientProfile({super.key});

  @override
  State<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _documentTypeController;
  late TextEditingController _documentNumberController;
  late TextEditingController _addressController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _birthDateController;
  late TextEditingController _phoneNumberController;

  DateTime? _selectedDate;
  String? _selectedDocumentType;
  String? _selectedCity;

  // Estados para controlar qué secciones están expandidas
  bool _personalInfoExpanded = true;
  bool _documentInfoExpanded = false;
  bool _locationInfoExpanded = false;
  bool _additionalInfoExpanded = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _documentTypeController = TextEditingController();
    _documentNumberController = TextEditingController();
    _addressController = TextEditingController();
    _neighborhoodController = TextEditingController();
    _cityController = TextEditingController();
    _birthDateController = TextEditingController();
    _phoneNumberController = TextEditingController();

    Future.microtask(() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshCurrentClientProfile();
      if (mounted) {
        _initializeControllers();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _documentTypeController.dispose();
    _documentNumberController.dispose();
    _addressController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _birthDateController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final client = Provider.of<AuthProvider>(context, listen: false).currentClient;

    _nameController.text = client?.nombre ?? '';
    _lastNameController.text = client?.apellido ?? '';
    _emailController.text = client?.correo ?? '';
    _selectedDocumentType = client?.tipoDocumento ?? '';
    _documentTypeController.text = client?.tipoDocumento ?? '';
    _documentNumberController.text = client?.numeroDocumento ?? '';
    _addressController.text = client?.direccion ?? '';
    _neighborhoodController.text = client?.barrio ?? '';
    _selectedCity = client?.ciudad ?? '';
    _cityController.text = client?.ciudad ?? '';
    _selectedDate = client?.fechaNacimiento;
    _birthDateController.text = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '';
    _phoneNumberController.text = client?.celular ?? '';

    if (mounted) setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    // Calcular la fecha máxima permitida (13 años desde hoy)
    final DateTime maxDate = DateTime.now().subtract(const Duration(days: 365 * 13));
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? maxDate,
      firstDate: DateTime(1900),
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.pink,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentClient = authProvider.currentClient;

      if (currentClient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la información del cliente.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final updatedClient = currentClient.copyWith(
        nombre: _nameController.text.trim(),
        apellido: _lastNameController.text.trim(),
        correo: _emailController.text.trim(),
        tipoDocumento: _selectedDocumentType ?? '',
        numeroDocumento: _documentNumberController.text.trim(),
        direccion: _addressController.text.trim(),
        barrio: _neighborhoodController.text.trim(),
        ciudad: _selectedCity ?? '',
        fechaNacimiento: _selectedDate,
        celular: _phoneNumberController.text.trim(),
      );

      final updatedClientData = updatedClient.toJson();
      final errorMessage = await authProvider.updateUserProfile(updatedClientData);

      if (!mounted) return;

      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Perfil actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
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
          final client = authProvider.currentClient;
          if (client == null && !authProvider.isLoading) {
            return const Center(child: Text('No se pudo cargar el perfil del cliente.'));
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
                              Icons.person,
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
                                  'Perfil de Cliente',
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
                                    'CLIENTE',
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
                            if (value.trim().length < 2) {
                              return 'El nombre debe tener al menos 2 caracteres';
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
                            if (value.trim().length < 2) {
                              return 'El apellido debe tener al menos 2 caracteres';
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
                        _buildDocumentTypeDropdown(),
                        const SizedBox(height: 16),
                        _buildCustomTextField(
                          controller: _documentNumberController,
                          labelText: 'Número de Documento',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Constants.requiredField;
                            }
                            if (value.length < 6) {
                              return 'El documento debe tener al menos 6 dígitos';
                            }
                            if (value.length > 10) {
                              return 'El documento no puede tener más de 10 dígitos';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    // Acordeón - Ubicación
                    _buildAccordionSection(
                      title: '📍 Ubicación',
                      isExpanded: _locationInfoExpanded,
                      onToggle: () => setState(() => _locationInfoExpanded = !_locationInfoExpanded),
                      children: [
                        _buildCustomTextField(
                          controller: _addressController,
                          labelText: 'Dirección',
                          icon: Icons.home_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Constants.requiredField;
                            }
                            if (value.trim().length < 10) {
                              return 'La dirección debe ser más específica';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildCustomTextField(
                          controller: _neighborhoodController,
                          labelText: 'Barrio',
                          icon: Icons.location_city_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Constants.requiredField;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildCityDropdown(),
                      ],
                    ),

                    // Acordeón - Información Adicional
                    _buildAccordionSection(
                      title: '📅 Información Adicional',
                      isExpanded: _additionalInfoExpanded,
                      onToggle: () => setState(() => _additionalInfoExpanded = !_additionalInfoExpanded),
                      children: [
                        _buildCustomTextField(
                          controller: _birthDateController,
                          labelText: 'Fecha de Nacimiento',
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Constants.requiredField;
                            }
                            if (_selectedDate != null) {
                              final age = DateTime.now().difference(_selectedDate!).inDays ~/ 365;
                              if (age < 13) {
                                return 'Debe ser mayor de 13 años';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildCustomTextField(
                          controller: _phoneNumberController,
                          labelText: 'Número de Celular',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Constants.requiredField;
                            }
                            if (!value.startsWith('3')) {
                              return 'El celular debe comenzar con 3';
                            }
                            if (value.length != 10) {
                              return 'El celular debe tener exactamente 10 dígitos';
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
    List<TextInputFormatter>? inputFormatters,
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
        inputFormatters: inputFormatters,
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

 Widget _buildDocumentTypeDropdown() {
  // ✅ Lista de tipos válidos
  final validTypes = [
    'Cédula de Ciudadanía',
    'Cédula de Extranjería',
    'Pasaporte',
    'Tarjeta de Identidad'
  ];

  // ✅ Normalizar el valor seleccionado
  String? normalizedValue;
  if (_selectedDocumentType != null && validTypes.contains(_selectedDocumentType)) {
    normalizedValue = _selectedDocumentType;
  }

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
    child: DropdownButtonFormField<String>(
      value: normalizedValue, // ✅ Usar valor normalizado
      decoration: InputDecoration(
        labelText: 'Tipo de Documento',
        prefixIcon: Icon(Icons.assignment_outlined, color: Colors.pink[400]),
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
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.pink[600]),
      ),
      items: validTypes
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedDocumentType = value;
          _documentTypeController.text = value ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return Constants.requiredField;
        }
        return null;
      },
    ),
  );
}

  Widget _buildCityDropdown() {
    // ✅ Normalizar el valor seleccionado
    String? normalizedCity;
    if (_selectedCity != null && Constants.colombianCities.contains(_selectedCity)) {
      normalizedCity = _selectedCity;
    }

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
      child: DropdownButtonFormField<String>(
        value: normalizedCity, // ✅ Usar valor normalizado
        decoration: InputDecoration(
          labelText: 'Ciudad',
          prefixIcon: Icon(Icons.location_city, color: Colors.pink[400]),
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
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.pink[600]),
        ),
        items: Constants.colombianCities.map((city) {
          return DropdownMenuItem(value: city, child: Text(city));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCity = value;
            _cityController.text = value ?? '';
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return Constants.requiredField;
          }
          return null;
        },
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