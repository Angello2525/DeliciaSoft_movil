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
  final String documento;

  @JsonKey(name: 'nombre')
  final String nombre;

  @JsonKey(name: 'apellido')
  final String apellido;

  @JsonKey(name: 'correo')
  final String correo;

  @JsonKey(name: 'hashContraseña')
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
    this.documento = '',
    this.nombre = '',
    this.apellido = '',
    this.correo = '',
    this.hashContrasena,
    this.idRol = 0,
    this.estado = true,
    this.idRolNavigation,
  });

  /// fromJson defensivo
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'] as int? ?? 0,
      tipoDocumento: json['tipoDocumento']?.toString() ?? '',
      documento: json['documento']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      hashContrasena: json['hashContraseña']?.toString(),
      idRol: json['idRol'] as int? ?? 0,
      estado: json['estado'] as bool? ?? true,
      idRolNavigation: json['idRolNavigation'] != null
          ? Rol.fromJson(json['idRolNavigation'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => _$UsuarioToJson(this);

  Usuario copyWith({
    int? idUsuario,
    String? tipoDocumento,
    String? documento,
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
