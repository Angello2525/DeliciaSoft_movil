import 'package:json_annotation/json_annotation.dart';
import 'rol.dart';

part 'usuario.g.dart';

@JsonSerializable()
class Usuario {
  @JsonKey(name: 'idUsuario')
  final int idUsuario;

  @JsonKey(name: 'tipoDocumento')
  final String tipoDocumento;

  @JsonKey(name: 'documento')
  final int documento;

  @JsonKey(name: 'nombre')
  final String nombre;

  @JsonKey(name: 'apellido')
  final String apellido;

  @JsonKey(name: 'correo')
  final String correo;

  @JsonKey(name: 'hashContrasena')
  final String? hashContrasena;

  @JsonKey(name: 'idRol')
  final int idRol;

  @JsonKey(name: 'estado')
  final bool estado;

  @JsonKey(name: 'idRolNavigation')
  final Rol? idRolNavigation;

  Usuario({
    this.idUsuario = 0,
    this.tipoDocumento = '',
    this.documento = 0,
    this.nombre = '',
    this.apellido = '',
    this.correo = '',
    this.hashContrasena,
    this.idRol = 2,
    this.estado = true,
    this.idRolNavigation,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'] as int? ?? json['idusuario'] as int? ?? 0,
      tipoDocumento: json['tipoDocumento']?.toString() ?? json['tipodocumento']?.toString() ?? '',
      documento: _parseDocumento(json),
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      hashContrasena: json['hashContrasena']?.toString() ?? json['hashcontrasena']?.toString(),
      idRol: _parseIdRol(json),
      estado: json['estado'] is bool
          ? json['estado'] as bool
          : json['estado']?.toString() == 'true',
      idRolNavigation: json['idRolNavigation'] != null
          ? Rol.fromJson(json['idRolNavigation'] as Map<String, dynamic>)
          : null,
    );
  }

  static int _parseDocumento(Map<String, dynamic> json) {
    final docValue = json['documento'];
    if (docValue is int) return docValue;
    return int.tryParse(docValue?.toString() ?? '') ?? 0;
  }

  static int _parseIdRol(Map<String, dynamic> json) {
    final idRolValue = json['idRol'] ?? json['idrol'];
    if (idRolValue is int) return idRolValue;
    return int.tryParse(idRolValue?.toString() ?? '') ?? 2;
  }

  Map<String, dynamic> toJson() => _$UsuarioToJson(this);

  Map<String, dynamic> toJsonWithoutId() {
    return {
      'idUsuario': idUsuario,
      'tipoDocumento': tipoDocumento,
      'documento': documento,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'hashContrasena': hashContrasena ?? "",
      'idRol': idRol != 0 ? idRol : 2,
      'estado': estado,
    };
  }

  Usuario copyWith({
    int? idUsuario,
    String? tipoDocumento,
    int? documento,
    String? nombre,
    String? apellido,
    String? correo,
    String? hashContrasena,
    int? idRol,
    bool? estado,
    Rol? idRolNavigation,
  }) {
    return Usuario(
      idUsuario: idUsuario ?? this.idUsuario,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      documento: documento ?? this.documento,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      hashContrasena: hashContrasena ?? this.hashContrasena,
      idRol: idRol ?? this.idRol,
      estado: estado ?? this.estado,
      idRolNavigation: idRolNavigation ?? this.idRolNavigation,
    );
  }

  String get fullName => '$nombre $apellido'.trim();
  String get roleName => idRolNavigation?.rol1 ?? '';
  bool get isAdmin => roleName.toLowerCase().contains('admin');
}