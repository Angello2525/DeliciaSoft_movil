class Constants {
  // API Configuration
  static const String baseUrl = 'http://deliciasoft.somee.com/api';

  // API Endpoints ORIGINALES
  static const String loginClientEndpoint = '$baseUrl/Clientes';
  static const String loginUserEndpoint = '$baseUrl/Usuarios'; 
  static const String registerClientEndpoint = '$baseUrl/Clientes';
  static const String registerUserEndpoint = '$baseUrl/Usuarios';
  static const String getClientEndpoint = '$baseUrl/Clientes';
  static const String getUserEndpoint = '$baseUrl/Usuarios';
  static const String getRolesEndpoint = '$baseUrl/rols';

  
  // NUEVOS ENDPOINTS DE AUTH
  static const String sendVerificationCodeEndpoint = '$baseUrl/Auth/send-verification-code';
  static const String verifyCodeAndLoginEndpoint = '$baseUrl/Auth/verify-code-and-login';
  static const String requestPasswordResetEndpoint = '$baseUrl/Auth/request-password-reset';
  static const String resetPasswordEndpoint = '$baseUrl/Auth/reset-password';
  static const String verifyEmailEndpoint = '$baseUrl/Auth/verify-email';
  static const String refreshTokenEndpoint = '$baseUrl/Auth/refresh-token';

  // Email Configuration
  static const String emailPassword = 'xska kvfs wscx dris';


  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String userTypeKey = 'user_type';
  static const String verificationCodeKey = 'verification_code';

  // User Types
  static const String adminType = 'admin';
  static const String clientType = 'client';

  // Validation Messages
  static const String requiredField = 'Este campo es requerido';
  static const String invalidEmail = 'Ingrese un correo válido';
  static const String passwordTooShort = 'La contraseña debe tener al menos 6 caracteres';
  static const String passwordsDoNotMatch = 'Las contraseñas no coinciden';
  static const String invalidPhone = 'Ingrese un número de teléfono válido';
  static const String invalidDocument = 'Ingrese un documento válido';

  // Success Messages
  static const String loginSuccess = 'Inicio de sesión exitoso';
  static const String registerSuccess = 'Registro exitoso';
  static const String verificationSuccess = 'Verificación exitosa';
  static const String passwordResetSuccess = 'Contraseña restablecida exitosamente';

  // Error Messages
  static const String loginError = 'Error al iniciar sesión';
  static const String registerError = 'Error al registrarse';
  static const String verificationError = 'Error en la verificación';
  static const String networkError = 'Error de conexión';
  static const String serverError = 'Error del servidor';
  static const String unauthorizedError = 'No autorizado';

  // Document Types
  static const List<String> documentTypes = [
    'Cédula de Ciudadanía',
    'Tarjeta de Identidad',
    'Cédula de Extranjería',
    'Pasaporte',
  ];

  // Colombian Cities
  static const List<String> colombianCities = [
    'Bogotá',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Cúcuta',
    'Bucaramanga',
    'Pereira',
    'Santa Marta',
    'Ibagué',
    'Pasto',
    'Manizales',
    'Neiva',
    'Villavicencio',
    'Armenia',
  ];

  // Formato de fecha (dd/mm/yyyy)
  static String formatDate(DateTime? date) {
    if (date == null) return 'No especificada';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}