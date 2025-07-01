import 'package:flutter/material.dart';
import '../screens/products/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/verification_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_profile.dart';
import '../screens/client/client_dashboard.dart';
import '../screens/client/client_profile.dart';
import '../screens/home_navigation.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verification = '/verification';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminProfile = '/admin-profile';
  static const String clientDashboard = '/client-dashboard';
  static const String clientProfile = '/client-profile';
  static const String homeNavigation = '/home-navigation';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    adminDashboard: (context) => const AdminDashboard(),
    adminProfile: (context) => const AdminProfile(),
    clientDashboard: (context) => const ClientDashboard(),
    clientProfile: (context) => const ClientProfile(),
    homeNavigation: (context) => const HomeNavigation(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case verification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => VerificationScreen(
            email: args?['email'] ?? '',
            password: args?['password'],
            userType: args?['userType'],
            isPasswordReset: args?['isPasswordReset'] ?? false,
            isLogin: args?['isLogin'] ?? false,
          ),
        );

      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: args?['email'] ?? '',
            verificationCode: args?['verificationCode'] ?? '',
          ),
        );

      default:
        return null;
    }
  }
}
