import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = '162465781678427';
  static const String uploadPreset = 'delicias_preset'; // Asegúrate de crear este preset en Cloudinary

  static Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final resJson = jsonDecode(resStr);
        return resJson['secure_url'];
      } else {
        print('Error Cloudinary: \${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al subir imagen: \$e');
      return null;
    }
  }
}
