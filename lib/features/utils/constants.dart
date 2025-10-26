class Constants {

  // API Configuration - ✅ CAMBIO PRINCIPAL
  static const String baseUrl = 'https://deliciasoft-backend-i6g9.onrender.com/api';

  // API Endpoints (todos usan baseUrl, así que se actualizarán automáticamente)
  static const String loginClientEndpoint = '$baseUrl/clientes';
  static const String loginUserEndpoint = '$baseUrl/usuarios'; 
  static const String registerClientEndpoint = '$baseUrl/clientes';
  static const String registerUserEndpoint = '$baseUrl/usuarios';
  static const String getClientEndpoint = '$baseUrl/clientes';
  static const String getAdminEndpoint = '$baseUrl/usuarios';
  static const String getUserEndpoint = '$baseUrl/usuarios';
  static const String getRolesEndpoint = '$baseUrl/rol';

  static const String sendVerificationCodeEndpoint = '$baseUrl/Auth/send-verification-code';
  static const String verifyCodeAndLoginEndpoint = '$baseUrl/Auth/verify-code-and-login';
  static const String requestPasswordResetEndpoint = '$baseUrl/Auth/request-password-reset';
  static const String resetPasswordEndpoint = '$baseUrl/Auth/reset-password';
  static const String verifyEmailEndpoint = '$baseUrl/Auth/verify-email';
  static const String refreshTokenEndpoint = '$baseUrl/Auth/refresh-token';

  // ✅ ENDPOINTS DE VENTAS Y ABONOS CORREGIDOS
  static const String ventasEndpoint = '$baseUrl/venta';
  static const String ventasListadoEndpoint = '$baseUrl/venta/listado-resumen';
  static const String ventaDetallesEndpoint = '$baseUrl/venta'; // + /{id}/detalles
  static const String estadosVentaEndpoint = '$baseUrl/estado-venta';
  
  // ✅ ENDPOINTS DE PEDIDOS (singular, no plural)
  static const String pedidosEndpoint = '$baseUrl/pedido';
  static const String pedidoByVentaEndpoint = '$baseUrl/pedido/by-venta'; // + /{idVenta}
  
  // ✅ IMPORTANTE: Todos los endpoints de abonos en MINÚSCULA
  static const String abonosEndpoint = '$baseUrl/abonos';
  static const String abonosByPedidoEndpoint = '$baseUrl/abonos/pedido'; // + /{idVenta}
  static const String anularAbonoEndpoint = '$baseUrl/abonos'; // + /{idAbono}/anular
  
  // ✅ ENDPOINTS DE DETALLE VENTA
  static const String detalleVentaEndpoint = '$baseUrl/detalleventa';
  static const String detalleVentaByVentaEndpoint = '$baseUrl/detalleventa/by-venta'; // + /{idVenta}
  
  // Otros endpoints
  static const String sedesEndpoint = '$baseUrl/sede';
  static const String productosEndpoint = '$baseUrl/productogeneral';
  static const String categoriasEndpoint = '$baseUrl/categoriaproducto';
  static const String imagenesEndpoint = '$baseUrl/Imagenes';
  static const String clientesEndpoint = '$baseUrl/Clientes';


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
  static const String clientType = 'cliente';

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

  // Fecha en formato dd/mm/yyyy
  static String formatDate(DateTime? date) {
    if (date == null) return 'No especificada';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
