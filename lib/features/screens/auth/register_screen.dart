import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../models/cliente.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/loading_widget.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();

  // Controllers para todos los campos
  final TextEditingController _documentNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  String? _selectedDocumentType;
  String? _selectedCity;
  DateTime? _selectedDate;
  int _currentStep = 0;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  static const String googleApiKey = 'AIzaSyChcaitO44DwrtStITwPnMCNLI89JoIA4M';

  bool _isPasswordValid = false;
  bool _isEmailValid = false;
  bool _isPhoneValid = false;
  bool _isDocumentValid = false;
  bool _isNameValid = false;
  bool _isLastNameValid = false;

  @override
  void initState() {
    super.initState();
    _setupRealTimeValidation();
  }

  void _setupRealTimeValidation() {
    _passwordController.addListener(() {
      setState(() {
        _isPasswordValid = _validatePasswordStrength(_passwordController.text);
      });
    });

    _emailController.addListener(() {
      setState(() {
        _isEmailValid = _validateEmail(_emailController.text);
      });
    });

    _phoneNumberController.addListener(() {
      setState(() {
        _isPhoneValid = _validatePhone(_phoneNumberController.text);
      });
    });

    _documentNumberController.addListener(() {
      setState(() {
        _isDocumentValid = _validateDocument(_documentNumberController.text);
      });
    });

    _nameController.addListener(() {
      setState(() {
        _isNameValid = _validateName(_nameController.text);
      });
    });

    _lastNameController.addListener(() {
      setState(() {
        _isLastNameValid = _validateName(_lastNameController.text);
      });
    });
  }

  bool _validatePasswordStrength(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;
    return true;
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool _validatePhone(String phone) {
    return phone.startsWith('3') && phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone);
  }

  bool _validateDocument(String document) {
    return document.length <= 10 && RegExp(r'^[0-9]+$').hasMatch(document);
  }

  bool _validateName(String name) {
    return name.trim().length >= 2 && RegExp(r'^[a-zA-ZÁáÉéÍíÓóÚúÑñ\s]+$').hasMatch(name);
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.pink.shade400, size: 28),
            const SizedBox(width: 12),
            const Text('¿Salir del registro?'),
          ],
        ),
        content: const Text('¿Quieres salir sin terminar de crear la cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Continuar', style: TextStyle(color: Colors.pink.shade400)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessAlert(String message) {
    if (!mounted) return; 
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.pink.shade400, size: 28),
            const SizedBox(width: 12),
            const Text('¡Éxito!'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Continuar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorAlert(String message) {
    if (!mounted) return; 
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade400, size: 28),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Entendido', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink.shade400,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      final age = DateTime.now().year - picked.year;
      if (age < 13) {
        _showErrorAlert('Debes ser mayor de 13 años para registrarte');
        return;
      }

      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  String? _parseCityFromPrediction(String? description) {
    if (description == null || description.isEmpty) {
      return null;
    }
    final parts = description.split(',').map((s) => s.trim()).toList();
    for (var part in parts) {
      if (Constants.colombianCities.any((city) => city.toLowerCase() == part.toLowerCase())) {
        return part;
      }
    }
    if (parts.length >= 2) {
      return parts[parts.length - 2];
    }
    return null;
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _selectedDocumentType != null && _isDocumentValid;
      case 1:
        return _isNameValid && _isLastNameValid;
      case 2:
        return _isEmailValid;
      case 3:
        return _isPasswordValid && _passwordController.text == _confirmPasswordController.text;
      case 4:
        return _addressController.text.isNotEmpty && _neighborhoodController.text.isNotEmpty && _selectedCity != null;
      case 5:
        return _isPhoneValid && _selectedDate != null;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_canProceedToNextStep()) {
      if (_currentStep < 5) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _register();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _register() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final cliente = Cliente(
      idCliente: 0,
      tipoDocumento: _selectedDocumentType!,
      numeroDocumento: _documentNumberController.text.trim(),
      nombre: _nameController.text.trim(),
      apellido: _lastNameController.text.trim(),
      correo: _emailController.text.trim(),
      contrasena: _passwordController.text,
      direccion: _addressController.text.trim(),
      barrio: _neighborhoodController.text.trim(),
      ciudad: _selectedCity!,
      fechaNacimiento: _selectedDate!,
      celular: _phoneNumberController.text.trim(),
      estado: true,
    );

    final errorMessage = await authProvider.registerClient(cliente);

    if (!mounted) return; 

    if (errorMessage == null) {
      _showSuccessAlert(Constants.registerSuccess);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) { 
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } else {
      _showErrorAlert(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope( 
      canPop: false, 
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        if (_currentStep > 0) {
          final shouldExit = await _showExitDialog();
          if (shouldExit == true) {
            if (mounted) Navigator.of(context).pop();
          }
        } else {
          if (mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.pink.shade400),
            onPressed: () async {
              if (_currentStep > 0) {
                final shouldExit = await _showExitDialog();
                if (shouldExit == true) {
                  if (mounted) Navigator.of(context).pop();
                }
              } else {
                if (mounted) Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'Crear Cuenta',
            style: TextStyle(
              color: Colors.pink.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return LoadingWidget(
              isLoading: authProvider.isLoading,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: List.generate(6, (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 4,
                            decoration: BoxDecoration(
                              color: index <= _currentStep
                                  ? Colors.pink.shade400
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildDocumentStep(),
                        _buildNameStep(),
                        _buildEmailStep(),
                        _buildPasswordStep(),
                        _buildAddressStep(),
                        _buildPhoneAndDateStep(),
                      ],
                    ),
                  ),

                  // Botones de navegación
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.pink.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: Text(
                                'Anterior',
                                style: TextStyle(color: Colors.pink.shade400, fontSize: 16),
                              ),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _canProceedToNextStep() ? _nextStep : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade400,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              _currentStep == 5 ? 'Crear Cuenta' : 'Siguiente',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocumentStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de Identificación',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Necesitamos verificar tu identidad',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),

          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Tipo de Documento',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
              ),
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
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _documentNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              labelText: 'Número de Documento',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
              ),
              suffixIcon: _documentNumberController.text.isNotEmpty
                  ? Icon(
                      _isDocumentValid ? Icons.check_circle : Icons.error,
                      color: _isDocumentValid ? Colors.green : Colors.red,
                    )
                  : null,
            ),
          ),
          if (_documentNumberController.text.isNotEmpty && !_isDocumentValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Máximo 10 dígitos, solo números',
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Personal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuéntanos cómo te llamas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),

          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
              ),
              suffixIcon: _nameController.text.isNotEmpty
                  ? Icon(
                      _isNameValid ? Icons.check_circle : Icons.error,
                      color: _isNameValid ? Colors.green : Colors.red,
                    )
                  : null,
            ),
          ),
          if (_nameController.text.isNotEmpty && !_isNameValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Mínimo 2 caracteres, solo letras',
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              ),
            ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: 'Apellido',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
              ),
              suffixIcon: _lastNameController.text.isNotEmpty
                  ? Icon(
                      _isLastNameValid ? Icons.check_circle : Icons.error,
                      color: _isLastNameValid ? Colors.green : Colors.red,
                    )
                  : null,
            ),
          ),
          if (_lastNameController.text.isNotEmpty && !_isLastNameValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Mínimo 2 caracteres, solo letras',
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmailStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correo Electrónico',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Usaremos este correo para enviarte actualizaciones',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo Electrónico',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
              ),
              suffixIcon: _emailController.text.isNotEmpty
                  ? Icon(
                      _isEmailValid ? Icons.check_circle : Icons.error,
                      color: _isEmailValid ? Colors.green : Colors.red,
                    )
                  : null,
            ),
          ),
          if (_emailController.text.isNotEmpty && !_isEmailValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Ingresa un correo válido',
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contraseña Segura',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea una contraseña fuerte para proteger tu cuenta',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),

          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_passwordController.text.isNotEmpty)
                    Icon(
                      _isPasswordValid ? Icons.check_circle : Icons.error,
                      color: _isPasswordValid ? Colors.green : Colors.red,
                    ),
                  IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          if (_passwordController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requisitos de la contraseña:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirement(
                    'Mínimo 8 caracteres',
                    _passwordController.text.length >= 8,
                  ),
                  _buildPasswordRequirement(
                    'Al menos una mayúscula',
                    RegExp(r'[A-Z]').hasMatch(_passwordController.text),
                  ),
                  _buildPasswordRequirement(
                    'Al menos un número',
                    RegExp(r'[0-9]').hasMatch(_passwordController.text),
                  ),
                  _buildPasswordRequirement(
                    'Al menos un carácter especial',
                    RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Confirmar Contraseña',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_confirmPasswordController.text.isNotEmpty)
                    Icon(
                      _passwordController.text == _confirmPasswordController.text
                          ? Icons.check_circle
                          : Icons.error,
                      color: _passwordController.text == _confirmPasswordController.text
                          ? Colors.green
                          : Colors.red,
                    ),
                  IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          if (_confirmPasswordController.text.isNotEmpty &&
              _passwordController.text != _confirmPasswordController.text)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Las contraseñas no coinciden',
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.remove_circle,
          color: isValid ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.red,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

Widget _buildAddressStep() {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dirección de Residencia',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.pink.shade400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Empieza a escribir tu dirección y selecciónala de la lista.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 40),

        GooglePlaceAutoCompleteTextField(
          textEditingController: _addressController,
          googleAPIKey: googleApiKey,
          inputDecoration: InputDecoration(
            labelText: 'Dirección',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
            ),
          ),
          debounceTime: 800,
          itemClick: (prediction) {
            setState(() {
              _addressController.text = prediction.description ?? '';
              _selectedCity = _parseCityFromPrediction(prediction.description);
            });
          },
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _neighborhoodController,
          decoration: InputDecoration(
            labelText: 'Barrio',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Ciudad',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
            ),
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
        ),
      ],
    ),
  );
}

  Widget _buildPhoneAndDateStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contacto y Fecha de Nacimiento',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completa tu información de contacto y fecha de nacimiento.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),

          TextFormField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              labelText: 'Número de Celular',
              hintText: 'Ej. 3001234567',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
              ),
              suffixIcon: _phoneNumberController.text.isNotEmpty
                  ? Icon(
                      _isPhoneValid ? Icons.check_circle : Icons.error,
                      color: _isPhoneValid ? Colors.green : Colors.red,
                    )
                  : null,
            ),
          ),
          if (_phoneNumberController.text.isNotEmpty && !_isPhoneValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Número debe iniciar con 3 y tener 10 dígitos',
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              ),
            ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _birthDateController,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              labelText: 'Fecha de Nacimiento',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
              ),
              suffixIcon: _selectedDate != null
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
          ),
          if (_selectedDate == null && _birthDateController.text.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Selecciona tu fecha de nacimiento',
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}