import 'package:flutter/material.dart';
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

  @override
void initState() {
  super.initState();

  // Mueve la inicialización a una función separada
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

  // Llama a la función para refrescar los datos del perfil
  Future.microtask(() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
   await authProvider.refreshCurrentClientProfile();
    // Después de cargar, reinicializa los controladores con los datos frescos.
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

  // EN client_profile.dart, dentro de _ClientProfileState

  void _initializeControllers() {
    final client = Provider.of<AuthProvider>(context, listen: false).currentClient;

    _nameController.text = client?.nombre ?? '';
    _lastNameController.text = client?.apellido ?? '';
    _emailController.text = client?.correo ?? '';
    _documentTypeController.text = client?.tipoDocumento ?? '';
    _documentNumberController.text = client?.numeroDocumento ?? '';
    _addressController.text = client?.direccion ?? '';
    _neighborhoodController.text = client?.barrio ?? '';
    _cityController.text = client?.ciudad ?? '';
    _selectedDate = client?.fechaNacimiento;
    _birthDateController.text = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '';
    _phoneNumberController.text = client?.celular ?? '';

    if(mounted) setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
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
        const SnackBar(content: Text('No se pudo obtener la información del cliente.')),
      );
      return;
    }

    // Crear cliente actualizado manteniendo el ID original
    final updatedClient = currentClient.copyWith(
      nombre: _nameController.text.trim(),
      apellido: _lastNameController.text.trim(),
      correo: _emailController.text.trim(),
      direccion: _addressController.text.trim(),
      barrio: _neighborhoodController.text.trim(),
      ciudad: _cityController.text.trim(),
      fechaNacimiento: _selectedDate,
      celular: _phoneNumberController.text.trim(),
    );

    // Convertir a Map manteniendo el ID
    final updatedClientData = updatedClient.toJson();

    final errorMessage = await authProvider.updateUserProfile(updatedClientData);

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
      appBar: AppBar(title: const Text('Mi Perfil (Cliente)')),
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
                      readOnly: true, // Not editable
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _documentNumberController,
                      labelText: 'Número de Documento',
                      readOnly: true, // Not editable
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _addressController,
                      labelText: 'Dirección',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Constants.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _neighborhoodController,
                      labelText: 'Barrio',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Constants.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Cambiado de CustomTextField a DropdownButtonFormField para ciudad
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Ciudad',
                        border: OutlineInputBorder(),
                      ),
                      value: _cityController.text.isNotEmpty ? _cityController.text : null,
                      items: Constants.colombianCities.map((city) {
                        return DropdownMenuItem(value: city, child: Text(city));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _cityController.text = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Constants.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _birthDateController,
                      labelText: 'Fecha de Nacimiento',
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Constants.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _phoneNumberController,
                      labelText: 'Número de Celular',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Constants.requiredField;
                        }
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return Constants.invalidPhone;
                        }
                        return null;
                      },
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
                        Navigator.of(context).pushNamed('/change-password');
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