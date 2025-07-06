class ApiConstants {
  static const String baseUrl = 'http://deliciasoft.somee.com';
  
  // Endpoints (ajusta según tu Swagger)
  static const String imagesEndpoint = '/api/Imagenes/subir';
  static const String getImagesEndpoint = '/api/Imagenes';
  
  // Headers comunes
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static const Map<String, String> multipartHeaders = {
    'Accept': 'application/json',
  };
}