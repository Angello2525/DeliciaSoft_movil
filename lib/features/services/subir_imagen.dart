import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para subir imágenes por lote a tu API
class ImagenBulkUploadService {
  final String apiUrl = 'http://deliciasoft.somee.com/api/Imagenes';

  Future<void> subirImagenes(List<String> urls) async {
    for (final url in urls) {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'urlImg': url}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final id = data['idImagen'];
        print('✅ Imagen registrada con id: $id');
      } else {
        print('❌ Error al subir la imagen: $url');
      }
    }
  }
}