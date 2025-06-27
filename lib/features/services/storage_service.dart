// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  
  // ==================== TOKEN METHODS ====================
  
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.refreshTokenKey, refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.refreshTokenKey);
  }

  // ==================== USER DATA METHODS ====================

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.userKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(Constants.userKey);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  // ==================== USER TYPE METHODS ====================

  static Future<void> saveUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.userTypeKey, userType);
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.userTypeKey);
  }

  // ==================== LOGIN STATUS METHODS ====================

  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.isLoggedInKey, isLoggedIn);
  }

  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Constants.isLoggedInKey) ?? false;
  }

  // ==================== VERIFICATION CODE METHODS ====================

  static Future<void> saveVerificationCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.verificationCodeKey, code);
  }

  static Future<String?> getVerificationCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.verificationCodeKey);
  }

  // ==================== CLEAR METHODS ====================

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    await prefs.remove(Constants.refreshTokenKey);
    await prefs.remove(Constants.userKey);
    await prefs.remove(Constants.userTypeKey);
    await prefs.remove(Constants.isLoggedInKey);
    await prefs.remove(Constants.verificationCodeKey);
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    await prefs.remove(Constants.refreshTokenKey);
    await prefs.remove(Constants.userKey);
    await prefs.remove(Constants.userTypeKey);
    await prefs.remove(Constants.isLoggedInKey);
  }

  // ==================== UTILITY METHODS ====================

  static Future<bool> hasValidSession() async {
    final token = await getToken();
    final userData = await getUserData();
    final userType = await getUserType();
    
    return token != null && 
           userData != null && 
           userType != null;
  }

  static Future<void> printStoredData() async {
    print('=== STORED DATA DEBUG ===');
    print('Token: ${await getToken()}');
    print('RefreshToken: ${await getRefreshToken()}');
    print('UserType: ${await getUserType()}');
    print('UserData: ${await getUserData()}');
    print('LoginStatus: ${await getLoginStatus()}');
    print('========================');
  }
}