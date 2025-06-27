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
  
  @JsonKey(name: 'hashContraseña')
  final String? hashContrasena;
  
  @JsonKey(name: 'idRol')
  final int idRol;
  
  @JsonKey(name: 'estado')
  final bool estado;
  
  @JsonKey(name: 'idRolNavigation')
  final Rol? idRolNavigation;

  Usuario({
    required this.idUsuario,
    required this.tipoDocumento,
    required this.documento,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.hashContrasena,
    required this.idRol,
    required this.estado,
    this.idRolNavigation,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioToJson(this);

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

  String get fullName => '$nombre $apellido';
  String get roleName => idRolNavigation?.rol1 ?? '';
  bool get isAdmin => roleName.toLowerCase().contains('admin');
}