import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha
import '../../providers/auth_provider.dart';
import '../../models/cliente.dart';
import '../../models/usuario.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _documentNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  String? _selectedDocumentType;
  String? _selectedCity;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _documentNumberController.dispose();
    _addressController.dispose();
    _neighborhoodController.dispose();
    _phoneNumberController.dispose();
    _birthDateController.dispose();
    super.dispose();
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

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // La lógica ahora es mucho más simple
      final cliente = Cliente(
        idCliente: 0,
        tipoDocumento: _selectedDocumentType!,
        numeroDocumento: _documentNumberController.text.trim(),
        nombre: _nameController.text.trim(),
        apellido: _lastNameController.text.trim(),
        correo: _emailController.text.trim(),
        contrasena: _passwordController.text, // El backend debe encargarse del hashing
        direccion: _addressController.text.trim(),
        barrio: _neighborhoodController.text.trim(),
        ciudad: _selectedCity!,
        fechaNacimiento: _selectedDate!,
        celular: _phoneNumberController.text.trim(),
        estado: true,
      );
      
      // Ya no hay 'if' para el tipo de usuario
      final errorMessage = await authProvider.registerClient(cliente);

      if (!mounted) return;

      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Constants.registerSuccess)),
        );
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
      appBar: AppBar(title: const Text('Registrar Cliente')), // Título más específico
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
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Documento',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedDocumentType,
                      items: Constants.documentTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDocumentType = value;
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
                      controller: _documentNumberController,
                      labelText: 'Número de Documento',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Constants.requiredField;
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return Constants.invalidDocument;
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
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirmar Contraseña',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Constants.requiredField;
                        }
                        if (value != _passwordController.text) {
                          return Constants.passwordsDoNotMatch;
                        }
                        return null;
                      },
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
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Ciudad',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCity,
                      items: Constants.colombianCities.map((city) {
                        return DropdownMenuItem(value: city, child: Text(city));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
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
                      text: 'Registrarse',
                      onPressed: _register,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                      },
                      child: const Text('¿Ya tienes una cuenta? Iniciar Sesión'),
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