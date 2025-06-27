import 'package:email_validator/email_validator.dart';
import 'constants.dart';

class Validators {
  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return Constants.requiredField;
    }
    if (!EmailValidator.validate(value)) {
      return Constants.invalidEmail;
    }
    return null;
  }
  
  // Password validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return Constants.requiredField;
    }
    if (value.length < 6) {
      return Constants.passwordTooShort;
    }
    return null;
  }
  
  // Confirm password validator
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return Constants.requiredField;
    }
    if (value != password) {
      return Constants.passwordsDoNotMatch;
    }
    return null;
  }
  
  // Required field validator
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null 
          ? '$fieldName es requerido' 
          : Constants.requiredField;
    }
    return null;
  }
  
  // Name validator
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZÁáÉéÍíÓóÚúÑñ\s]+$').hasMatch(value)) {
      return 'El nombre solo puede contener letras';
    }
    return null;
  }
  
  // Phone validator
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número de teléfono es requerido';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Ingrese un número de teléfono válido (10 dígitos)';
    }
    return null;
  }
  
  // Document validator
  static String? validateDocument(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número de documento es requerido';
    }
    if (!RegExp(r'^[0-9]{6,12}$').hasMatch(value)) {
      return 'Ingrese un número de documento válido (6-12 dígitos)';
    }
    return null;
  }
  
  // Age validator (must be at least 18 years old)
  static String? validateAge(DateTime? birthDate) {
    if (birthDate == null) {
      return 'La fecha de nacimiento es requerida';
    }
    
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    
    if (age < 18) {
      return 'Debe ser mayor de 18 años';
    }
    
    return null;
  }
  
  // Verification code validator
  static String? validateVerificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese el código de verificación';
    }
    if (value.length != 6) {
      return 'El código debe tener 6 dígitos';
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'El código solo puede contener números';
    }
    return null;
  }
  
  // Address validator
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La dirección es requerida';
    }
    if (value.trim().length < 5) {
      return 'La dirección debe tener al menos 5 caracteres';
    }
    return null;
  }
  
  // Real-time email validation (returns validation state)
  static bool isEmailValid(String email) {
    return email.isNotEmpty && EmailValidator.validate(email);
  }
  
  // Real-time password validation
  static bool isPasswordValid(String password) {
    return password.length >= 6;
  }
  
  // Real-time phone validation
  static bool isPhoneValid(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }
  
  // Real-time document validation
  static bool isDocumentValid(String document) {
    return RegExp(r'^[0-9]{6,12}$').hasMatch(document);
  }
  
  // Real-time name validation
  static bool isNameValid(String name) {
    return name.trim().length >= 2 && 
           RegExp(r'^[a-zA-ZÁáÉéÍíÓóÚúÑñ\s]+$').hasMatch(name);
  }
}