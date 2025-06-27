import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class EmailService {
  static const String _baseUrl = Constants.baseUrl;
  
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<bool> sendVerificationEmail(String email, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/email/send-verification'),
        headers: _headers,
        body: jsonEncode({
          'to': email,
          'token': token,
          'type': 'verification'
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error sending verification email: $e');
      return false;
    }
  }

  static Future<bool> sendPasswordResetEmail(String email, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/email/send-password-reset'),
        headers: _headers,
        body: jsonEncode({
          'to': email,
          'token': token,
          'type': 'password_reset'
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }

  static Future<bool> sendWelcomeEmail(String email, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/email/send-welcome'),
        headers: _headers,
        body: jsonEncode({
          'to': email,
          'name': name,
          'type': 'welcome'
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error sending welcome email: $e');
      return false;
    }
  }

  static Future<bool> sendLoginNotificationEmail(String email, String name, String deviceInfo) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/email/send-login-notification'),
        headers: _headers,
        body: jsonEncode({
          'to': email,
          'name': name,
          'deviceInfo': deviceInfo,
          'loginTime': DateTime.now().toIso8601String(),
          'type': 'login_notification'
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error sending login notification email: $e');
      return false;
    }
  }

  static Future<bool> resendVerificationEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/email/resend-verification'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error resending verification email: $e');
      return false;
    }
  }

  // Check email service status
  static Future<bool> checkEmailServiceStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/email/status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'active';
      }
      return false;
    } catch (e) {
      print('Error checking email service status: $e');
      return false;
    }
  }
}