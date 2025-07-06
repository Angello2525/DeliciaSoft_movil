import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/adicionModels.dart';

class CatalogoAdicionesService {
  static const String baseUrl = 'http://deliciasoft.somee.com';
  static const Duration timeoutDuration = Duration(seconds: 30);

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'FresasApp/1.0',
  };

  Future<List<AdicionModel>> obtenerAdiciones() async {
    try {
      final uri = Uri.parse('$baseUrl/api/CatalogoAdiciones');
      final response = await http.get(uri, headers: _headers).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(responseBody);

        return jsonData
            .map((item) => AdicionModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(
          'Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw const HttpException('Sin conexión a internet. Verifica tu red.');
    } on TimeoutException {
      throw const HttpException('Tiempo de espera agotado. Intenta más tarde.');
    } on FormatException catch (e) {
      throw HttpException('Error de formato: ${e.message}');
    } catch (e) {
      throw HttpException('Error inesperado: ${e.toString()}');
    }
  }
}
