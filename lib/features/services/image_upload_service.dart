import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../models/imagene.dart';
import 'api_constants.dart';

class ImageUploadService {
  
  // Subir imagen individual
  static Future<Imagene> uploadImage(XFile imageFile) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.imagesEndpoint}');
      var request = http.MultipartRequest('POST', uri);
      
      // Validar archivo
      final fileName = path.basename(imageFile.path);
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      
      if (!_isValidImageType(fileExtension)) {
        throw Exception('Tipo de archivo no válido. Solo se permiten: jpg, jpeg, png, gif, webp');
      }
      
      // Adjuntar archivo
      request.files.add(await http.MultipartFile.fromPath(
        'archivo', // Ajusta según el parámetro de tu API
        imageFile.path,
        filename: fileName,
      ));
      
      // Headers
      request.headers.addAll(ApiConstants.multipartHeaders);
      
      print('📤 Subiendo imagen: $fileName');
      print('📍 URL: ${uri.toString()}');
      
      // Enviar solicitud
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📥 Respuesta: ${response.statusCode}');
      print('📄 Cuerpo: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Imagene.fromJson(responseData);
      } else {
        throw Exception('Error del servidor: ${response.statusCode} - ${response.body}');
      }
      
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on FormatException {
      throw Exception('Respuesta del servidor inválida');
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }
  
  // Obtener todas las imágenes
  static Future<List<Imagene>> getImages() async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getImagesEndpoint}');
      final response = await http.get(uri, headers: ApiConstants.jsonHeaders);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Imagene.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener imágenes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener imágenes: $e');
    }
  }
  
  // Eliminar imagen
  static Future<bool> deleteImage(int imageId) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/Imagenes/$imageId');
      final response = await http.delete(uri, headers: ApiConstants.jsonHeaders);
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error al eliminar imagen: $e');
    }
  }
  
  // Seleccionar y subir imagen en un paso
  static Future<Imagene?> pickAndUploadImage({
    ImageSource source = ImageSource.gallery,
    int? imageQuality,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );
      
      if (pickedFile != null) {
        return await uploadImage(pickedFile);
      }
      return null;
    } catch (e) {
      throw Exception('Error al seleccionar y subir imagen: $e');
    }
  }
  
  // Validar tipos de archivo
  static bool _isValidImageType(String extension) {
    const validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return validExtensions.contains(extension);
  }
}