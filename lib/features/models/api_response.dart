// api_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'data')
  final T? data;

  @JsonKey(name: 'errors')
  final List<String>? errors;

  @JsonKey(name: 'statusCode')
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  // Factory constructors for common responses
  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      message: message ?? 'Éxito',
      data: data,
      statusCode: 200,
    );
  }

  factory ApiResponse.error(String message, {List<String>? errors, int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode ?? 400,
    );
  }
}

// Nueva AuthResponse consolidada
@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'success') // Añadido
  final bool success; // Añadido

  @JsonKey(name: 'message') // Añadido
  final String message; // Añadido

  @JsonKey(name: 'token')
  final String token;

  @JsonKey(name: 'refreshToken')
  final String? refreshToken;

  @JsonKey(name: 'user')
  final Map<String, dynamic>? user; // Podría ser Cliente o Usuario, o un mapa genérico

  @JsonKey(name: 'userType')
  final String userType;

  @JsonKey(name: 'expiresIn')
  final int? expiresIn; // Opcional: si tu API devuelve un tiempo de expiración

  AuthResponse({
    required this.success, // Añadido
    required this.message, // Añadido
    required this.token,
    this.refreshToken,
    this.user,
    required this.userType,
    this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

// TokenResponse - si aún la necesitas para un endpoint específico de token
@JsonSerializable()
class TokenResponse {
  final bool success;
  final String message;
  final String? token;

  TokenResponse({
    required this.success,
    required this.message,
    this.token,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => _$TokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);
}

// PasswordResetResponse - si aún la necesitas para el endpoint de reseteo de contraseña
@JsonSerializable()
class PasswordResetResponse {
  final bool success;
  final String message;

  PasswordResetResponse({
    required this.success,
    required this.message,
  });

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
  return PasswordResetResponse(
    success: json['success'] as bool? ?? false,
    message: json['message']?.toString() ?? '',
  );
}

  Map<String, dynamic> toJson() => _$PasswordResetResponseToJson(this);
}